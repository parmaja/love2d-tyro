
canvas.setpoint(0, 100) --set start point
for x=0, canvas.width, 5 do
    y = math.cos(x  / 50) * 50
    canvas.line(x,  y + 200) --drawing line to this point
end