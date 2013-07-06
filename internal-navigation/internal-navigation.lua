function createInternalNav()

        intab = {}

        intab.xpos = 0
        intab.ypos = 0
        intab.zpos = 0
        intab.dir  = 0

        function intab.forward()
                local moveworked = turtle.forward()
                if moveworked == true then
                        if intab.dir%4 == 0 then intab.xpos = intab.xpos+1
                        elseif intab.dir%4 == 1 then intab.zpos = intab.zpos+1
                        elseif intab.dir%4 == 2 then intab.xpos = intab.xpos-1
                        elseif intab.dir%4 == 3 then intab.zpos = intab.zpos-1
                        else print("Massive Error in intab.forward()") end
                end
                return moveworked
        end

        function intab.back()
                local moveworked = turtle.back()
                if moveworked == true then
                        if intab.dir%4 == 0 then intab.xpos = intab.xpos - 1
                        elseif intab.dir%4 == 1 then intab.zpos = intab.zpos - 1
                        elseif intab.dir%4 == 2 then intab.xpos = intab.xpos + 1
                        elseif intab.dir%4 == 3 then intab.zpos = intab.zpos + 1
                        else print("Massive Error in intab.back()") end
                end
                return moveworked
        end

        function intab.up()
                local moveworked = turtle.up()
                if moveworked == true then intab.ypos = intab.ypos + 1 end
                return moveworked
        end

        function intab.down()
                local moveworked = turtle.down()
                if moveworked == true then intab.ypos = intab.ypos - 1 end
                return moveworked
        end

        function intab.turnLeft()
                local turnworked = turtle.turnLeft()
                if turnworked == true then intab.dir = intab.dir - 1 end
                return turnworked
        end

        function intab.turnRight()
                local turnworked = turtle.turnRight()
                if turnworked == true then intab.dir = intab.dir + 1 end
                return turnworked
        end

        function intab.printPos()
                print("Current Location: ("..intab.xpos..","..intab.ypos..","..intab.zpos..","..intab.dir%4..")")
        end

        function intab.getPos()
                currentPos = {"x"=intab.xpos,"y"=intab.ypos,"z"=intab.zpos,"dir"=intab.dir%4}
                return currentPos
        end

        function intab.calibrate(x,y,z,d)
                if type(x) == "table" then
                        inputTable = x
                        x = inputTable.x
                        y = inputTable.y
                        z = inputTable.z
                        d = inputTable.d
                end

                if type(x) ~= "number" then x = 0 end
                if type(y) ~= "number" then y = 0 end
                if type(z) ~= "number" then z = 0 end
                if type(d) ~= "number" then d = 0 end

                intab.xpos = x
                intab.ypos = y
                intab.zpos = z
                intab.dpos = d
        end


        return intab
end