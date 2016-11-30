while true do
    graphics.setPointSize(math.random(5) + 2) --size of point
    r = math.random(colors.count) --todo: use #colors insdead when LOVE2D use >5.2
    canvas.color(colors[r])
    canvas.point(math.random(canvas.width), math.random(canvas.height))
end