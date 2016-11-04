function input()
	s = io.read()
    x = tonumber(s)
    if x == nil then
    	return s
    else
    	return x
    end
end

function write(s)
	io.write(s)
end

function writeln(s)
	io.write(s.."\n")
end

function int(x)
  return math.floor(x)
end