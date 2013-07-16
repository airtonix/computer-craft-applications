os.loadAPI('aware')

local settings = {
    slotStorageStart = 1,
    slotStorageEnd = 13,
    slotSapling = 14,
    slotWood = 15,
    slotDirt = 16
}


--utilities
local log = {}
    function log:msg(level, msg)
        print(string.format("<%s> %s: %s", os.time(), level, msg))
    end
    function log:debug(msg) self:msg('debug', msg) end
    function log:info(msg) self:msg('info', msg) end
    function log:warn(msg) self:msg('warn', msg) end
    function log:error(msg) self:msg('error', msg) end


function needsFuel()
    local result = false
    local fuelLevel = turtle.getFuelLevel()
    local fuelType = type(fuelLevel)
    if fuelType == "number" then result = fuelLevel < 1 end
    if fuelType == "string" then result = fuelLevel ~= "unlimited" end
    return result
end

function collect()
    turtle.suck()
    turtle.suckUp()
    turtle.suckDown()
end

function deposit()
    -- empty slots slotStorageStart through slotStorageEnd
    for i=settings.slotStorageStart,settings.slotStorageEnd do
        turtle.select(i)
        print(string.format("Emptying slot %s (%s)",i, turtle.getItemCount(i)))
        while turtle.getItemCount(i) > 0 do
            turtle.dropDown()
        end
    end
end



function refuel()
    while needsFuel() do
        log:info("Refueling.")
        turtle.select(settings.slotStorageStart)
        turtle.refuel()
    end
end

function watchTreeGrow()
    log:info("watchTreeGrow: start")
    turtle.select(settings.slotWood)
    while not turtle.compare() do
        log:info("watchTreeGrow: watch")
        sleep(3)
    end
    log:info("watchTreeGrow: something changed")
end

function harvestTree()

end



local pointTreeDirt =    aware.getposition('treedirt')    --{  5, 5, 0, 2 }
local pointTreeSapling = aware.getposition('treesapling') --{  5, 5, 1, 2 }
local pointTreeTop =     aware.getposition('treetop')     --{  5, 4, 8, 2 }
local pointTreeRoot =    aware.getposition('treeroot')    --{  5, 4, 0, 2 }
local pointDropoff =     aware.getposition('dropoff')     --{ 10, 0, 0, 1 }
local pointPickup =      aware.getposition('pickup')      --{  0, 0, 0, 0 }

while not needsFuel() do
    turtle.select(settings.slotSapling)
    while turtle.getItemCount(settings.slotSapling) < 2 do collect() end

    -- move to the dirt block
    aware.goto(pointTreeDirt)
    turtle.select(settings.slotDirt)
    turtle.place()

    -- -- move to where we place the sapling
    aware.goto(pointTreeSapling)
    turtle.select(settings.slotSapling)
    turtle.place()

    turtle.select(settings.slotWood)
    while not turtle.compare() do sleep(1) end

    turtle.select(settings.slotStorageStart)
    aware.digmoveforward()
    aware.goto(pointTreeTop)
    refuel()

    turtle.select(settings.slotDirt)
    aware.goto(pointDropoff)
    deposit()

    aware.goto(pointPickup)
end
