local app = {}
      app.name = "Tree Farmer"
      app.version = '0.0.1'
      app.arguments = {
        { name = 'slotSapling', value = 1},                 -- sapling place slot
        { name = 'slotStorageStart', value = 2},                 -- sapling place slot
        { name = 'slotStorageEnd', value = 14},                 -- sapling place slot
        { name = 'slotWoodReference', value = 15},          -- wood reference slot
        { name = 'slotSaplingReference', value = 16},       -- sapling reference slot
        { name = 'refuelFromWood', value = true},
      }
      app.options = {}

      function app:showUsage()
        print(app.manifest.name, " ", app.manifest.version)
        print "Usage: "
        print "> twigs"
        print ""

        print "Requirements: "
        print " * saplings in slot 1"
        print " * wood type to cut in 2"
        print " * chest/obsidian pipe at rear"
      end

      function app:showOptions()
        for key,value in pairs(app.options) do
          print(key, ": ", value)
        end
      end

      function app:parse_args(args)
        local flags = {}
        local name, value, item
        for i = #app.arguments, 1, -1 do
          item = app.arguments[i]
          app.options[item.name] = item.value
        end


        for i = #args, 1, -1 do

          local flag = args[i]:match("^%-%-(.*)")
          if flag then
            local name, _, value = flag:match("([a-z_%-]*)(=?(.*))")
            if not value or value == "" then value = true end
            app.options[name] = value
          end

          local arg = args[i]:match("^[a-zA-z0-9]+")
          if arg then
            for ii = 0, 1, 1 do
              if i == ii then
                app.options[app.arguments[ii].name] = arg
              end
            end
          end
          table.remove(args, i)
        end
      end

      function app:init(args)
        self:parse_args(args)

        if app.options.help~=nil then
          self:showUsage()
          return
        end
        self:doWork()
      end

      function app:needsFuel()
        local fuelLevel = turtle.getFuelLevel()
        local fuelType = type(fuelLevel)
        if fuelType == "number" then return fuelLevel < 1 end
        if fuelType == "string" then return fuelLevel ~= "unlimited" end
        return false
      end

      function app:fuelup(...)
        result = true
        while self:needsFuel() do
          result = false
          for i=self.options.slotStorageStart, self.options.slotStorageEnd do
            turtle.select(i)
            if turtle.refuel(1) then
              result = true
              break
            end
          end
          if not result then
            print "Turtle fuel store empty."
            print "Resupply, Press Enter when done."
            x = read()
          end
        end
        return true
      end

      function app:turnAround()
          turtle.turnLeft();
          turtle.turnLeft();
      end

      function app:moveForward() -- turtle move forwards
        self:fuelup()
        while not turtle.forward() do
          turtle.attack()
          turtle.attack()
        end
      end

      function app:moveBackward() -- turtle move backwards
        self:fuelup()
        while not turtle.back() do
          self:turnAround()
          turtle.attack()
          turtle.attack()
          self:turnAround()
        end
      end

      function app:moveUp() -- turtle move up
        self:fuelup()
        while not turtle.up() do
          turtle.attackUp()
          turtle.attackUp()
        end
      end

      function app:moveDown() -- turtle move down
        self:fuelup()
        while not turtle.down() do
          turtle.attackDown()
          turtle.attackDown()
        end
      end

      function app:getSaplingCount()
        self.saplingCount = turtle.getItemCount(self.options.slotSapling)
        return self.saplingCount
      end

      function app:hasSaplings()
        return self:getSaplingCount() > 0
      end

      function app:holdingValidSapling()
        turtle.select(self.options.slotSapling)
        return turtle.compareTo(self.options.slotSaplingReference)
      end

      function app:lookingAtValidWood(direction)
        turtle.select(self.options.slotWoodReference)

        if direction == 'up' then
          return turtle.detectUp() and turtle.compareUp()
        elseif direction == 'down' then
          return turtle.detectDown() and turtle.compareDown()
        else
          return turtle.detect() and turtle.compare()
        end

      end

      function app:dwell()
        os.queueEvent("dwell-loop")
        os.pullEvent()
      end

      function app:refuel()
        if self:needsFuel() then
          -- refuel with 1 item
          turtle.refuel(1)
        end
      end

      function app:moveToLocation(location)
        if self.currentLocation == location then return end
        print("Moving to "..location)
        self:turnAround()
        print("rotating")
        while turtle.forward() do 
          print("moving")
          self:dwell() end
        self.currentLocation = location
      end


      function app:getMoreSaplings()
        os.queueEvent("re-supplying-saplings")
        print("sapling-resupply: start")
        self:moveToLocation('supplyStation')
        turtle.select(self.options.slotSapling)
        turtle.suck()
        print("sapling-resupply: done")
      end

      function app:cutDownTreeTrunk()
        -- select
        print("tree-harvest: start")

        turtle.dig()
        turtle.forward()
        while self:lookingAtValidWood('up') do
          turtle.digUp()
          turtle.up()
        end
        print "end of trunk"

        while turtle.detectDown() do turtle.down() end
        turtle.back()

        print("tree-harvest: done")

      end

      function app:depositWood()
        print("dump-wood: start")
        self:moveToLocation('supplyStation')
        turtle.turnRight()
        turtle.drop()
        turtle.turnLeft()
        print("dump-wood: done")
      end

      function app:doWork()

        while true do

          if not self:hasSaplings() then --or not self:holdingValidSapling() then
            self:getMoreSaplings()
            self:moveToLocation('tree')
          end

          -- place a sapling
          turtle.place()

          -- wait for the block in front to match our wood reference
          while not self:lookingAtValidWood() do self:dwell() end

          -- harvest the wood
          self:cutDownTreeTrunk()

          -- refuel if needed
          self:refuel()

          -- deposit the goodies
          self:depositWood()
          self:moveToLocation('tree')


          -- pause ?
          self:dwell()
        end
      end

app:init({...})
