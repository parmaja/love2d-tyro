canvas.setpoint(0, 100) --set start point

--for x = 0, canvas.width, 10 do
--    y = math.cos(x  / 50) * 50
--      canvas.line(x,  y + 200) --drawing line to this point
--end

local rate = 44100
local length = 0.1
local pitch = 440
local overtime = 1.5
for i = 0, length * rate * overtime - 1 do
  local sample = math.sin((i * pitch * math.pi * 2) / rate) * length
  canvas.line(i, sample * 100 + 100)
end

canvas.print("END", 10, 10)