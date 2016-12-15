canvas.color(colors.Black)
centerY = canvas.height / 2
canvas.setpoint(0, centerY) --set start point
for i = 0, canvas.width do
    y = math.sin(i / 10) * 100
    canvas.line(i,  centerY + y) --drawing line to this point
end
canvas.text("END", 10, 10)