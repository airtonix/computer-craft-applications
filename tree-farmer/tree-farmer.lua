Manifest = function()
	--[[
		meta data used by the computer craft github client.
	]]
	return {
		-- human readable name and description, shown in `github list` or github search `app`
		name = 'Tree Farmer',
		description = "Single Tree Farmer",
		-- moreinfo: google "semver"
		version = '0.0.1',
		-- used by github client, used to rename this file
		command = 'twigs',
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

      function app:getSaplingCount()
        self.saplingCount = turtle.getItemCount(self.options.slotSapling)
        return self.saplingCount
      end

      function app:doWork()

        while true do

          turtle.select(self.options.slotSapling)

          if self:getSaplingCount() > 0 and turtle.compareTo(self.options.slotSaplingReference) then
            -- place

            turtle.place()
            turtle.select(self.options.slotWoodReference)

            -- wait for the block in front to match our wood reference
            while not turtle.compare() do
              os.queueEvent("loop")
              os.pullEvent()
            end

            -- select
            turtle.select(self.options.slotStorageStart)
            turtle.dig()
            turtle.forward()

            while turtle.compareUp() do
             turtle.digUp()
             turtle.up()
            end

            while turtle.detectDown() do turtle.down() end

            turtle.back()
            turtle.turnRight()
            turtle.turnRight()
            turtle.refuel(1)
            turtle.drop()
            turtle.turnRight()
            turtle.turnRight()

          else

            -- re-supply or complain about no saplings
            turtle.turnRight()
            turtle.suck()
            turtle.turnLeft()
          end

          -- pause ?
          os.queueEvent("Loop")
          os.pullEvent()
        end
      end

app:init({...})
