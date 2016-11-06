function write(...)
    local args = {...}
    for i, v in ipairs(args) do
        io.write(v)
    end
end

function writeln(...)
	write(...)
    io.write("\n")
end

function input(s)
	if s then
    	write(s)
    end
    io.flush();
	s = io.read()
    x = tonumber(s)
    if x == nil then
    	return s
    else
    	return x
    end
end

function int(x)
	return math.floor(x)
end

text = 0
graphic = 1

local currentmode = text

function SetMode(mode)
  currentmode = mode
end


if love2d then
	function setcolor(color)

    end

	function circle(x, y, radius)
       love.graphics.circle("line", x, y, radius)
    end
end