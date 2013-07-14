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


app:init({...})
