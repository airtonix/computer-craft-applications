
Manifest = function()
	--[[
		meta data used by the computer craft github client.
	]]
	return {
		-- human readable name and description, shown in `github list` or github search `app`
		name = 'Staircases',
		description = "Creates 45 degree stair cases. forked from aTunnel by Andre L Noel",
		-- moreinfo: google "semver"
		version = '0.0.1',
		-- used by github client, used to rename this file
		command = 'stairs',
		-- attributation: author
		author = "Zenobius Jiricek <airtonix@gmail.com>",
    -- attributation: contributors
    contributors = {},
		-- attributation: license type
		license = "CCA 3.0 Unported License. <http://creativecommons.org/licenses/by/3.0/deed.en_US>"
	}
end

local app = {}
      app.manifest = Manifest()
      app.arguments = {
        { name = 'length', value = 16},
        { name = 'direction', value = 'up'},
        { name = 'width', value = 3},
        { name = 'height', value = 3},
        { name = 'torches', value = 4},
        { name = 'fill', value = false}
      }
      app.options = {}

      function app:showUsage()
        print(app.manifest.name, " ", app.manifest.version)
        print "Usage: "
        print "> stairs L D [H] [W] [Ti] "
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
        print "> stairs 28 --torches=6"
        print "> stairs 28 3 3 --torches=6"
        print "> stairs 28 3 3 6"
        print "> stairs 28 6 --width=3"

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


      function app:needsFuel(level)
        if type(level) == "number" then return level < 1 end
        if type(level) == "string" then return level ~= "unlimited" end
        return false
      end

      function app:hasStorageSpace()
        for i=2, 15 do
          turtle.select(i)
          if turtle.getItemCount(i) < 1 then
            return true
          end
        end
        return false
      end

      function app:invenCheck()
        local torches = app.options.torches
        local fill = app.options.fill
        -- check torches
        if torches ~= nil or tonumber(torches) > 0 then
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
        if fill ~= nil then
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
        while self:needsFuel(turtle.getFuelLevel()) do
          result = false
          for i=2,15 do
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

      function app:placeTorch()
        turtle.select(16)
        turtle.place()
      end



      function app:doWork()
        print("Creating Tunnel")
        local x,y,z,heading
        local targetHeight = tonumber(app.options.height)
        local targetWidth = tonumber(app.options.width)
        local targetLength = tonumber(app.options.length)
        local torchInterval = tonumber(app.options.torches)

        for z=1, targetLength do -- main loop
          print(string.format("Step %d/%d", z, targetLength))

          if z % torchInterval > 0 then
            self:turnAround()
            self:placeTorch()
            self:turnAround()
          end

          self:moveForward()
          self:moveDown()
          turtle.turnRight()

          for y=1, targetHeight+1 do

            for x=1, targetWidth-1 do
              -- dig rows
              self:moveForward()
            end

            --[[ only move up to next row if turtle
                 is not already at the ceiling ]]
            if y <= targetHeight then
              self:moveUp()
              self:turnAround()
            end
            --[[ determine odd or even row, means
                turtle is heading left or right ]]
            heading = y % 2
            print(y, heading)
          end

          --return to bottom row
          for y=app.options.height,1,-1  do
            --back down plus one
            self:moveDown()
          end

          --realign to left edge
          if heading == 0  then
            turtle.turnRight()
          else
            self:turnAround()
            self:moveForward()
            self:moveForward()
            turtle.turnLeft()
          end

        end -- main loop

        print "Tunnel complete."
        print "Returning to deployment zone."

        self:turnAround()
        for x=targetLength,1,-1 do
          turtle.up()
          turtle.forward()
        end
        print "Done."
      end


app:init({...})