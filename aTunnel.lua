Manifest = function()
  --[[
    meta data used by the computer craft github client.
  ]]
  return {
    name = 'aTunneler',
    description = "Short for Andre's Tunneler",
    readme = "",
    version = '1.0.5',
    command = 'at',
    author = 'Andre L Noel',
    contributors = {
      "Zenobius Jiricek <airtonix@gmail.com>",
    },
    license = "CCA 3.0 Unported License. <http://creativecommons.org/licenses/by/3.0/deed.en_US>"
  }
end


local app = {}
      app.manifest = Manifest()
      app.arguments = {
        { name = 'length', value = 0},
        { name = 'width', value =3},
        { name = 'height', value = 3},
        { name = 'torches', value = 8}
      }
      app.options = {}

      function app:showUsage()
        print(app.manifest.name, " ", app.manifest.version)
        print "Usage: $ at L [H] [W] [Ti]"
        print " L [int]: blocks forward to mine"
        print " H [int]: blocks up to mine"
        print " W [int]: blocks wide to mine"
        print "Ti [int]: Torch interval"
        print ""
        print "Requirements: "
        print " * Filler in slot 1"
        print " * Torches in slot 16"
        print " * Fuel in any other slot"
      end

      function app:showOptions()
        for key,value in pairs(app.options) do
          print(key, ": ", value)
        end
        -- if filltop then
        --   print("Estimated fuel need : " .. ((howfar*(5+howtall-1))+howfar+2) )
        -- else
        --   print("Estimated fuel need : " .. ((howfar*(1+howtall-1))+howfar+2) )
        -- end
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


      --[ logic ]

      function app:doWork()
        print("Creating Tunnel")
        local fwsteps, bwsteps, torchspaces, tall = 0,0,0,0

        for fwsteps=1, app.options.length do -- main loop
          print( fwsteps .. " of " .. app.options.length .. " ...")
          torchspaces = torchspaces + 1
          if torchspaces > (app.options.torches - 1) then
            self:turnAround()
            turtle.select(16)
            turtle.place()
            torchspaces = 0
            self:turnAround()
          end
          self:moveForwards()
          turtle.select(1) -- cobble or filler block
          turtle.placeDown()

          for tall=2, app.options.height do
            self:tup()
          end

          if filltop then
            turtle.placeUp()
            turtle.turnLeft()
            self:moveForwards()
            turtle.placeUp()
            self:moveBackwards()
            self:turnAround()
            self:moveForwards()
            turtle.placeUp()
            self:moveBackwards() -- facing right
          else
            turtle.turnLeft()
            turtle.place() -- anti lava and water
            self:digForward()
            self:turnAround()
            turtle.place() -- anti lava and water
            self:digForward() -- facing right
          end

          for tall=2, app.options.height do
            self:moveDown()
            turtle.place() -- anti lava and water
            self:digForward()
            self:turnAround()
            turtle.place() -- anti lava and water
            self:digForward()
            self:turnAround() -- facing right
          end

          -- redundant check for gravel and dug out floor
          self:digForward()
          self:turnAround()
          self:digForward()
          turtle.turnRight() -- facing forward again
          self:digUp()
          turtle.placeDown()
        end -- main loop
        print "Tunnel complete."
        print "Returning to deployment zone."

        self:tup()
        for bwsteps=1, app.options.length do
          self:moveBackwards()
        end

        self:moveDown()
        print "Done."
      end

      function app:invenCheck()
        -- check torches
        turtle.select(16)
        while ( turtle.getItemCount(16) < 1 ) do
          print " "
          print "More torches are needed."
          print "Please add torches to slot 16"
          print "Press Enter when done."
          x = read();
        end
        -- check filler
        turtle.select(1)
        while turtle.getItemCount(1) < 1 do
          print " "
          print "Cobblestone or other filler blocks are needed."
          print "Please add them to slot 1"
          print "Press Enter when done."
          x = read()
        end
        -- check inventory space
        freespaces = false
        while not freespaces do
          for i=2,15 do
              turtle.select(i)
            if turtle.getItemCount(i) < 1 then
              freespaces = true
              break
            end
          end
          if not freespaces then
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
      end


app:init({...})