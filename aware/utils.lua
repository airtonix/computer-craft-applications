function termwrite(message)
  cx, cy = term.getCursorPos()
  mx, my = term.getSize()
  term.write(message)
  if(cy == my) then
    term.scroll(1)
    term.setCursorPos(1, cy)
  else
    term.setCursorPos(1, cy + 1)
  end  
end

function copytable(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function download(source, destination)
  local tmpF = http.get(source)
  sleep(5)
  local txt = tmpF:readAll()
  local file = io.open(destination, "w")
  file:write(txt)
  file:close()
end

function vartofile(variable, filename)
  file = fs.open(filename, "w")
  file.write(textutils.serialize(variable))
  file:close()
end

function varfromfile(filename)
  if(fs.exists(filename)) then
    file = fs.open(filename, "r")
    contentsu = textutils.unserialize(file.readLine())
    file:close()
    return contentsu
  else
    return nil
  end
end