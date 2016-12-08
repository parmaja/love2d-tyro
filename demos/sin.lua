canvas.setpoint(0, 100) --set start point

canvas.color(colors.Red)

--for i = 0, canvas.width do
--    y = math.sin(i * 440 / 8000) * 100
--      canvas.line(i,  y + 200) --drawing line to this point
--end

canvas.setpoint(0, 100) --set start point
canvas.color(colors.Green)

local rate = 8000
local length = 0.1
local pitch = 440
for i = 0, length * rate - 1 do
	local sample = math.sin((i * pitch) * ((math.pi * 2) / rate)) * 10
  	canvas.line(i, sample + 200)
end

canvas.print("END", 10, 10)