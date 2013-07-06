local installed = false;

local tDaemons = {}

-- checks if the daemon manager is installed and returns true/false as appropriate
function isInstalled()
 return installed
end

-- installs the daemon manager
-- required before the rest of the daemon api is used
-- ideally called from startup
-- returns true if successful
function install()
 if installed then error("daemon.install: daemon manager already installed", 2) end

 -- use a weak reference to the parent coroutine to allow it to be destroyed
 -- we will detect when that happens and uninstall automatically
 local currentco = setmetatable({co=coroutine.running()}, {__mode="v"})
 local currentfilter = nil
 local old_coroutine_resume = coroutine.resume

 local function new_coroutine_resume(co, event, ...)
  -- uninstall automatically if parent co gets deleted
  if installed and not currentco.co then
   uninstall()
  end
  -- complete pending uninstall
  if not installed and coroutine.resume == new_coroutine_resume then
   coroutine.resume = old_coroutine_resume
  end

  -- inject calls to daemons when someone tries to resume our parent co
  if installed and co == currentco.co then
   local ok, param = true, nil

   -- first run parent co...
   if currentfilter == nil or currentfilter == event or event == "terminate" then
    ok, param = old_coroutine_resume(currentco.co, event, ...)
    --if not ok then
    -- error(param)
    --end
    -- uninstall automatically if parent co terminates
    if coroutine.status(currentco.co) == "dead" then
     uninstall()
     return ok, param
    end
   end

   -- ...then run daemons
   -- ignore the terminate event as it should be handled by terminating the parent co which will result in calling uninstall() above
   -- and if the terminate event doesn't halt the parent co it shouldn't halt daemons either
   if event ~= "terminate" then
    local tDead = {}
    for key,value in pairs(tDaemons) do
     if value.filter == nil or value.filter == event then
      ok, param = old_coroutine_resume(value.coroutine, event, ...)
      if not ok then
       print("Daemon ("..tostring(key)..") ended with error:\n"..param)
      end
      -- delete daemon automatically if it terminates
      if coroutine.status(value.coroutine) == "dead" then
       tDead[key] = value
      else
       value.filter = param
      end
     end
    end
    for key,value in pairs(tDead) do
     tDaemons[key] = nil
    end
   end

   -- always return ok if we make it this far
   -- and no filter so that different daemons can have different filters active
   return true, nil
  else
   -- if not installed or not resuming our parent co, forward the call...
   -- pass all params and return all results so we don't break any interesting uses of coroutines
   return old_coroutine_resume(co, event, ...)
  end
 end
 coroutine.resume = new_coroutine_resume

 installed = true
 --sleep(0)

 return true
end

-- uninstalls the daemon handler
-- I don't know why you'd want to do this manually
function uninstall()
 if not installed then error("daemon.uninstall: daemon manager not installed", 2) end

 installed = false
 for key,value in pairs(tDaemons) do
  kill(key, true)
 end
 tDaemons = {}
end

-- adds a daemon, with the given extra args being passed to the function as params
-- will run the daemon function once to get it to its first os.pullEvent
function add(_name, _function, ...)
 if type(_name) ~= "string" then error("daemon.add: daemon name must be a string", 2) end
 if type(_function) ~= "function" then error("daemon.add: daemon function must be a function", 2) end
 if not installed then error("daemon.add: daemon manager not installed", 2) end
 if tDaemons[_name] then error("daemon.add: daemon ("..tostring(_name)..") already running", 2) end

 -- resume coroutine once so that we can pass it the program args
 local co = coroutine.create(_function)
 local ok, param = coroutine.resume(co, ...)
 if not ok then
  print("Daemon ("..tostring(key)..") ended with error:\n"..param)
 end

 -- if the daemon terminates immediately then don't add it, we're done here
 if coroutine.status(co) ~= "dead" then
  tDaemons[_name] = {}
  tDaemons[_name].coroutine = co
  tDaemons[_name].filter = param
 end

 return true
end

-- kills a daemon by name
-- first sends a terminate event, then (if force) deletes it
-- returns true if successfully killed or false if not
function kill(_name, _force)
 if type(_name) ~= "string" then error("daemon.kill: daemon name must be a string", 2) end
 if not installed then error("daemon.kill: daemon manager not installed", 2) end
 if not tDaemons[_name] then error("daemon.kill: daemon ("..tostring(_name)..") not running", 2) end

 local ok, param = coroutine.resume(tDaemons[_name].coroutine, "terminate")
 if not ok and param ~= "Terminated" then
  print("Daemon ("..tostring(key)..") ended with error:\n"..param)
 end

 if coroutine.status(tDaemons[_name].coroutine) == "dead" or _force then
  tDaemons[_name] = nil
  return true
 else
  return false
 end
end

-- sends an event to a daemon through os.pullEvent
-- returns true if successful or false if the event was ignored due to current filter
function sendEvent(_name, event, ...)
 if type(_name) ~= "string" then error("daemon.sendEvent: daemon name must be a string", 2) end
 if not installed then error("daemon.sendEvent: daemon manager not installed", 2) end
 if not tDaemons[_name] then error("daemon.sendEvent: daemon ("..tostring(_name)..") not running", 2) end

 if tDaemons[_name].filter == nil or tDaemons[_name].filter == event or event == "terminate" then
  local ok, param = coroutine.resume(tDaemons[_name].coroutine, event, ...)
  if not ok and not (event == "terminate" and param == "Terminated") then
   print("Daemon ("..tostring(key)..") ended with error:\n"..param)
  end
  if coroutine.status(tDaemons[_name].coroutine) == "dead" then
   tDaemons[_name] = nil
  end
  return true
 end

 return false
end

-- gets the status of a daemon
-- active if ok
-- nil if not found
function getStatus(_name)
 if type(_name) ~= "string" then error("daemon.getStatus: daemon name must be a string", 2) end
 if not installed then error("daemon.getStatus: daemon manager not installed", 2) end

 if tDaemons[_name] then
  return "active"
 end

 return nil
end

-- gets a list of all daemons and their status
function list()
 if not installed then error("daemon.list: daemon manager not installed", 2) end

 local tReturn = {}
 for key,value in pairs(tDaemons) do
  tReturn[key] = {}
  tReturn[key].status = getStatus(key)
  --tReturn[key].filter = value.filter
 end

 return tReturn
end