
Manifest = function()
  --[[
    meta data used by the computer craft github client.
  ]]
  return {
    name = 'Tubes',
    description = "Create Tunnels & Stairs. forked from aTunnel by Andre L Noel",
    version = '0.0.2',
    command = 'tube',
    author = "Zenobius Jiricek <airtonix@gmail.com>",
    contributors = {},
    license = "CCA 3.0 Unported License. <http://creativecommons.org/licenses/by/3.0/deed.en_US>"
  }
end

local app = {}
      app.manifest = Manifest()
      app.arguments = {
        { name = 'length', value = 1 },
        { name = 'width', value = 3 },
        { name = 'height', value = 3 },
        { name = 'torches', value = 0 },
        --[[
          false: No vertical shift
          up: move up one block each forward frame
          down: move down one block each forward frame
        ]]
        { name = 'stairs', value = false },
        { name = 'fill', value = false },
        { name = 'floorFillSlot', value = false },
        { name = 'wallFillSlot', value = false },
        { name = 'ceilingFillSlot', value = false }
      }
      app.options = {}
      app.coordinates = {
        x = 0,
        y = 0,
        z = 0,
      }

      function app:showUsage()
        print(self.manifest.name, " ", self.manifest.version)
        print "Usage: "
        print "> tube L D [H] [W] [Ti] "
        print " L [int]: blocks forward to mine"
        print " D [up/down]: stairs up or down"
        print " H [int]: blocks up to mine"
        print " W [int]: blocks wide to mine"
        print "Ti [int]: Torch interval"
        print ""

        print "Requirements: "
        print " * Filler in slot 1"
        print " * Torches in slot 16"
        print " * Fuel in any other slot"

        print "Examples:"
        print "> stairs --length=28 --torches=6"

      end

      function app:showOptions()
        for key,value in pairs(self.options) do
          print(key, ": ", value)
        end
      end

      function app:parse_args(args)
        local flags = {}
        local name, value, item
        for i = #self.arguments, 1, -1 do
          item = self.arguments[i]
          self.options[item.name] = item.value
        end

        for i = #args, 1, -1 do
          -- match something like : --word
          local flag = args[i]:match("^%-%-(.*)")
          if flag then
            -- match something like : key=value
            local name, _, value = flag:match("([a-z_%-]*)(=?(.*))")
            if not value or value == "" then value = true end
            self.options[name] = value
          end

          -- match word or number
          local arg = args[i]:match("^[a-zA-z0-9]+")
          if arg then
            for ii = 0, 1, 1 do
              if i == ii then
                self.options[self.arguments[ii].name] = arg
              end
            end
          end
          table.remove(args, i)
        end
      end

      function app:init(args)
        self:parse_args(args)

        if self.options.help~=nil then
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

      function  app:getItemSlot( slot )
        local slot = slot and tonumber(slot)
        if type(slot) == "number" then
          turtle.select(slot)
          return slot
        end
        for i=2, 15 do
          turtle.select(i)
          if turtle.getItemCount(i) >0 then
            return i
          end
        end
        return false
      end

      function app:hasStorageSpace()
        for i=2, 15 do
          turtle.select(i)
          if turtle.getItemCount(i) < 1 then
            return i
          end
        end
        return false
      end

      function app:invenCheck()
        local torches = self.options.torches
        local fill = self.options.fill

        -- check torches
        if tonumber(torches) > 0 then
          turtle.select(16)
          while ( turtle.getItemCount(16) < 1 ) do
            print " "
            print "More torches are needed."
            print "Please add torches to slot 16"
            print "Press Enter when done."
            x = read();
          end
        end

        -- check filler
        if fill then
          turtle.select(1)
          while turtle.getItemCount(1) < 1 do
            print " "
            print "Cobblestone or other filler blocks are needed."
            print "Please add them to slot 1"
            print "Press Enter when done."
            x = read()
          end
        end

        -- check inventory space
        if not self:hasStorageSpace() then
          print " "
          print "Turtle inventory has no free slots."
          print "Please remove items except for"
          print "filler blocks in slot 1 and"
          print "torches in slot 16 and"
          print "any needed fuel such as coal."
          turtle.select(2)
          print "Press Enter when done."
          x = read()
        end
        turtle.select(1)
      end

      function app:fuelup(...)
        result = true
        while self:needsFuel() do
          result = false
          for i=1,15 do
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

      function app:digForward()
        self:invenCheck()
        while turtle.dig() do
          turtle.suck()
          turtle.suckUp()
          turtle.suckDown()
        end
      end

      function app:digUp() -- dig up
        self:invenCheck()
        while turtle.digUp() do
          turtle.suckUp()
          turtle.suck()
          turtle.suckDown()
        end
      end

      function app:digDown() -- dig down
        self:invenCheck()
        while turtle.digDown() do
          turtle.suckDown()
          turtle.suck()
          turtle.suckUp()
        end
      end

      function app:turnAround()
          turtle.turnLeft();
          turtle.turnLeft();
      end

      function app:moveForward() -- turtle move forwards
        self:fuelup()
        while not turtle.forward() do
          self:digForward()
          turtle.attack()
          turtle.attack()
        end
      end

      function app:moveBackward() -- turtle move backwards
        self:fuelup()
        while not turtle.back() do
          self:turnAround()
          self:digForward()
          turtle.attack()
          turtle.attack()
          self:turnAround()
        end
      end

      function app:moveUp() -- turtle move up
        self:fuelup()
        while not turtle.up() do
          self:digUp()
          turtle.attackUp()
          turtle.attackUp()
        end
      end

      function app:moveDown() -- turtle move down
        self:fuelup()
        while not turtle.down() do
          self:digDown()
          turtle.attackDown()
          turtle.attackDown()
        end
      end

      function app:setHeading(heading)
        self.coordinates.heading = heading
      end
      function app:getHeading(heading)
        return self.coordinates.heading
      end

      function app:setX(x)
        local current = self.coordinates.x
        if x > current then self:setHeading('right') end
        if x < current then self:setHeading('left') end
        self.coordinates.x = x
      end
      function app:getX() return self.coordinates.x end

      function app:setY(y) self.coordinates.y=y end
      function app:getY() return self.coordinates.y end

      function app:setZ(z) self.coordinates.z=z end
      function app:getZ() return self.coordinates.z end

      function app:setCoords(x,y,z)
        self:setX(x)
        self:setY(y)
        self:setZ(z)
      end

      function app:getCoords()
        print(string.format("%s.%s.%s", self.coordinates.x, self.coordinates.y, self.coordinates.z ))
      end

      function app:placeTorch()
        turtle.dig()
        turtle.select(1)
        turtle.place()
      end


      function app:torchDecision(distance)
        local torchInterval = tonumber(self.options.torches)
        local currentX = self:getX()
        if torchInterval == 0 then return end
        if distance % torchInterval == 0 then
          if currentX == self.options.width then
            turtle.turnRight()
            self:placeTorch()
            turtle.turnLeft()
          end
          if currentX == 1 then
            turtle.turnLeft()
            self:placeTorch()
            turtle.turnRight()
          end
        end
      end

      function app:doStairStep(reverse)
        local stairs = self.options.stairs
        if type(stairs) == "string" then
          if stairs == "down" then
            if not reverse then self:moveDown() else self:moveUp() end
          end
          if stairs == "up" then
            if not reverse then self:moveUp() else self:moveDown() end
          end
        end
      end

      function app:fillFloor()
        if not self.options.fill then return end
        local y = self:getY()
        if y ~= 1 then return end
        if not turtle.detectDown() then
          print("placing floor")
          app:getItemSlot(app.options.floorFillSlot)
          turtle.placeDown()
        end
      end

      function app:fillCeiling()
        if not self.options.fill then return end
        local y = self:getY()
        if y ~= tonumber(self.options.height) then return end
        if not turtle.detectUp() then
          print("placing ceiling")
          app:getItemSlot(app.options.ceilingFillSlot)
          turtle.placeUp()
        end
      end
      function app:fillWall()
        if not self.options.fill then return end
        local x = self:getX()
        if x ~= 1 and x ~= tonumber(self.options.width) then return end
        if not turtle.detect() then
          print("placing wall")
          app:getItemSlot(self.options.wallFillSlot)
          turtle.place()
        end
      end

      function app:digFrame()
          local desiredWidth = tonumber(self.options.width)
          local desiredHeight = tonumber(self.options.height)

          local incrementX, targetX = 1, desiredWidth
          local incrementY, targetY = 1, desiredHeight
          if self:getY() == desiredHeight then
            -- move from top to bottom
            incrementY, targetY = -1, 1
          end

          print(string.format("Digging a %s x %s frame", desiredWidth, desiredHeight))
          for y=self:getY(), targetY, incrementY do
            self:setY(y)

            if self:getX() == desiredWidth then
              -- move from right to left
              incrementX, targetX = -1, 1
            else
              incrementX, targetX = 1, desiredWidth
            end

            for x=self:getX(), targetX, incrementX do
              self:setX(x)
              self:fillFloor()
              self:fillCeiling()
              if x ~= targetX then self:moveForward() 
              else self:fillWall() end
            end
            print("row done", y)

            --[[ only move up to next row if turtle
                 is not already at the ceiling ]]
            if self:getY() ~= targetY then
              if incrementY > 0 then self:moveUp() end
              if incrementY < 0 then self:moveDown() end
              self:fillWall()
              self:turnAround()
            end
          end
          print("heading: ", self:getHeading())
      end

      function app:alignForNextFrame(direction)
          local x = self:getX()
          local width = self.options.width

          if x == 1 then
            turtle.turnRight()
            self:moveForward()
            turtle.turnLeft()
          else
            turtle.turnLeft()
            self:moveForward()
            turtle.turnRight()
          end
          self:fillWall()
          self:turnAround()
      end

      function app:returnToDeploymentZone()
        -- local reverseStepDirection = true

        -- while self:getX() > 1 do
        --   self:setX(self:getX()-1)
        --   self:moveForward()
        -- end

        -- turtle.turnLeft()

        -- while self:getY() > 1 do
        --   self:setY(self:getY()-1)
        --   self:doStairStep(reverseStepDirection)
        --   self:moveDown()
        -- end

        -- while self:getZ() > 1 do
        --   self:setZ(self:getZ()-1)
        --   self:doStairStep(reverseStepDirection)
        --   self:moveForward()
        -- end

      end

      function app:doWork()
        local targetLength, z = tonumber(self.options.length)
        print(string.format("Creating Tunnel: %s long, %s wide, %s high", 
          targetLength, self.options.width, self.options.height))
        self:setX(1)
        self:setY(1)
        self:setZ(1)
        print("starting tunnel")
        self:getCoords()
        self:moveForward()
        self:fillFloor()
        turtle.turnLeft()
        self:fillWall()
        self:turnAround()

        for z=self:getZ(), targetLength, 1 do -- main loop
          print(string.format("Step %d/%d", z, targetLength))
          self:setZ(z)
          self:doStairStep()
          self:digFrame()
          if z ~= targetLength then
            self:alignForNextFrame()
          end
        end
        self:returnToDeploymentZone()

        print "Done."
      end


app:init({...})