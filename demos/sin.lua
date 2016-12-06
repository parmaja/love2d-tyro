canvas.setpoint(0, 100) --set start point

--for x = 0, canvas.width, 10 do
--    y = math.cos(x  / 50) * 50
--      canvas.line(x,  y + 200) --drawing line to this point
--end

length = 0.1
pitch = 440
local overtime = 1.5
for i = 0, length * 44100 * overtime - 1 do
  local sample = math.sin((i * pitch * math.pi * 2) / 44100) * length
  canvas.line(i, sample * 100 + 100)
end

canvas.print("END", 10, 10)