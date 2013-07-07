local function printUsage()
    print("Usages:")
    print("daemon install -- installs daemon manager")
    print("daemon list -- lists daemons")
    print("daemon add <program> -- runs <program> as a daemon")
    print("daemon kill <name> -- kills a daemon")
end

local tArgs = {...}

if #tArgs < 1 then
    printUsage()
    return
end

if not daemon then os.loadAPI("daemon") end

if tArgs[1] == "install" then
    daemon.install()
    return
elseif tArgs[1] == "list" then
    local format = "%-8s | %s"
    local w, h = term.getSize()
    print(string.format(format, "status", "name"))
    print(string.rep("-", w))
    for key,value in pairs(daemon.list()) do
        print(string.format(format, value.status, key))
    end
    return
elseif tArgs[1] == "add" then
    if #tArgs < 2 then error("Must give a program") end
    daemon.add(string.match(tArgs[2], "[^/\\]*$"), shell.run, unpack(tArgs, 2))
elseif tArgs[1] == "kill" then
    if #tArgs < 2 then error("Must give a name") end
    daemon.kill(tArgs[2], true)
end