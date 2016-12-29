canvas.color(colors.Yellow)
center = {
    x = canvas.width / 2,
    y = canvas.height / 2,
}
canvas.line(0, center.y, canvas.width, center.y)

local tie = false
local height = 100
local rate = 22050
local length = 0.1
local pitch = 440
local amplitude = 50
local samples = length * rate
local scalex = 2

canvas.line(0, center.y - height / 2, canvas.width, center.y - height / 2)
canvas.line(0, center.y + height / 2, canvas.width, center.y + height / 2)
canvas.color(colors.Red)
--canvas.line(0, (2 * math.pi) / rate, canvas.width, (2 * math.pi) / rate)

canvas.color(colors.Black)
canvas.setpoint(0, center.y) --set start point
wf = melody.waveforms["gb"]

for index = 0, samples - 1 do
    sample = wf(index, samples, pitch, rate, tie) * amplitude
    canvas.line(index * scalex, center.y + sample)
end