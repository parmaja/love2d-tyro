canvas.color(colors.Yellow)
center = {
    x = canvas.width / 2,
    y = canvas.height / 2,
}
canvas.line(0, center.y, canvas.width, center.y)

local height = 100
local rate = 44100
local length = 0.1
local pitch = 440
local amplitude = 1
local samples = length * rate

canvas.line(0, center.y - height / 2, canvas.width, center.y - height / 2)
canvas.line(0, center.y + height / 2, canvas.width, center.y + height / 2)
canvas.color(colors.Red)
--canvas.line(0, (2 * math.pi) / rate, canvas.width, (2 * math.pi) / rate)

canvas.color(colors.Green)
canvas.setpoint(0, 100) --set start point
for index = 0, samples - 1 do
    local sample = math.sin((index * pitch) * ((2 * math.pi) / rate))
    --local sample = math.sin(index)
    local a = math.sin((index * pitch * 2) * ((2 * math.pi) / rate))
    sample = (sample - a) / 2
    canvas.line(index, sample* (height / 2) + center.y)
end