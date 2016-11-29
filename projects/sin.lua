canvas.setpoint(0, 100)

for x=0, canvas.width, 5 do
    s = math.cos(x  / 100) * 100
    canvas.line(x, 100 + s)
end