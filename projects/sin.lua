canvas.point(0, 100)
for x=0, 1000 do
    s = math.sin(x  /50) * 50
    canvas.line(x, 100 + s)
end