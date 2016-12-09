canvas.setpoint(0, 100) --set start point

canvas.color(colors.Red)
for i = 0, canvas.width do
    y = math.sin(i * 440 / 44100) * 100
    canvas.line(i,  200 + y) --drawing line to this point
end

canvas.text("END", 10, 10)