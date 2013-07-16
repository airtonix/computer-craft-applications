os.loadAPI("utils")

local shaftmode=false
local positions = {}
local current = {0,0,0,0}

local function modposition(axis, value)
  if (axis == 4) then
    current[axis] = ((current[axis] + value) % 4)
  else
    current[axis] = (current[axis] + value)
  end
  setposition("current", current)
  reportpositions()
end

function setshaftmode(toggle)
  shaftmode=toggle
end

function moveforward()
  if turtle.forward() then
    if     (current[4] == 0) then modposition(2,1)
    elseif (current[4] == 1) then modposition(1,-1)
    elseif (current[4] == 2) then modposition(2,-1)
    elseif (current[4] == 3) then modposition(1,1)
    end
    return true
  else
    return false
  end
end

function moveback()
  if turtle.back() then
    if     (current[4] == 0) then modposition(2,-1)
    elseif (current[4] == 1) then modposition(1,1)
    elseif (current[4] == 2) then modposition(2,1)
    elseif (current[4] == 3) then modposition(1,-1)
    end
    return true
  else
    return false
  end
end

function moveup()
  if turtle.up() then
    modposition(3,1)
    return true
  else
    return false
  end
end

function movedown()
  if turtle.down() then
    modposition(3,-1)
    return true
  else
    return false
  end
end

function turnright()
  modposition(4,1)
  turtle.turnRight()
end

function turnleft()
  modposition(4,-1)
  turtle.turnLeft()
end

function turnto(direction)
  if (direction == nil) then
   return
  end
  while current[4] ~= direction do
    diff = current[4] - direction
    if ((diff == 1) or (diff == -3)) then
      turnleft()
    else
      turnright()
    end
  end
end

function digmoveforward()
  if turtle.detect() then
    turtle.dig()
  end
  if shaftmode then
    if turtle.detectUp() then
      turtle.digUp()
    end
  end
  if moveforward() then
    return true
  else
    return false
  end
end

function digmoveup()
  if turtle.detectUp() then
    turtle.digUp()
  end
  if shaftmode then
    if turtle.detect() then
      turtle.dig()
    end
  end
  if moveup() then
    return true
  else
    return false
  end
end

function digmovedown()
  if turtle.detectDown() then
    turtle.digDown()
  end
  if shaftmode then
    if turtle.detect() then
      turtle.dig()
    end
  end
  if movedown() then
    return true
  else
    return false
  end
end

function movetoz(tarz)
  if (tarz == nil) then
   return true
  end
  while(current[3] ~= tarz) do
    if current[3] < tarz then
      digmoveup()
    else
      digmovedown()
    end
  end
end

function movetox(tarx)
  while(current[1] ~= tarx) do
    if current[1] < tarx then
      turnto(3)
    else
      turnto(1)
    end
    digmoveforward()
  end
end

function movetoy(tary)
  while(current[2] ~= tary) do
    if current[2] < tary then
      turnto(0)
    else
      turnto(2)
    end
    digmoveforward()
  end
end

function moveto(targx, targy, targz, targo)
  if(targz == nil) then
    movetox(targx)
    movetoy(targy)
  elseif(current[3] > targz) then
    movetoz(targz)
    movetoy(targy)
    movetox(targx)
  else
    movetox(targx)
    movetoy(targy)
    movetoz(targz)
  end
  turnto(targo)
end

function goto(destination)
  utils.termwrite("going to"..textutils.serialize(destination))
  moveto(destination[1], destination[2], destination[3], destination[4])
end

function emptyslots()
  numslots = 0
  for i=1, 9 do
    if turtle.getItemCount(i) == 0 then
      numslots = numslots + 1
    end
  end
  return numslots
end

function dump()
  while (turtle.drop()) do
    sleep(.12)
  end
end

local function reportpositions()
  pushpos((os.getComputerID()+10000),"T",current)
  pushpos((os.getComputerID()+100),"H",getposition("home"))
end

function pushpos(id, class, position)
  fposition=textutils.serialize(position)
  formatted={id,class,fposition}
  rednet.broadcast(textutils.serialize(formatted))
end

function getaxis(axis)
  return current[axis]
end

function getposition(name)
  position = utils.varfromfile("aware."..name)
  if ( position == nil) then
    return {0, 0, 0, 0}
  else
	return position
  end
end

function setposition(name, coordinates)
  if (coordinates ~= nil) then
    position = coordinates
  else
    position = aware.getposition("current")
  end
  utils.vartofile(position, "aware."..name)
end

local function init()
  rednet.open("right")
  current = getposition("current")
end

init()