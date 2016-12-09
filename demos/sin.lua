canvas.setpoint(0, 100) --set start point

canvas.color(colors.Red)
canvas.freeze()
for i = 0, canvas.width do
    y = math.sin(i * 440 / 44100) * 100
    canvas.line(i,  200 + y) --drawing line to this point
end
canvas.defreeze()

canvas.setpoint(0, 100) --set start point
canvas.color(colors.Green)

local rate = 44100
local length = 0.01
local pitch = 440
local amplitude = 1
local samples = length * rate
for index = 0, samples - 1 do
    local c = math.exp(index * 10 / rate)
    local sample = math.sin((index * pitch) * ((2 * math.pi) / rate)) + c
    canvas.line(index, sample * 100 + 200)
end

canvas.text("END", 10, 10)