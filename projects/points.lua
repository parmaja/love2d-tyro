while true do
    --canvas.freeze()
    for i = 0, 50 do
        r = math.random(5) + 2 --size of circle
        c = math.random(3, colors.count) --todo: use #colors insdead when LOVE2D use >5.2
        canvas.color(colors.Pink)
        x = math.random(canvas.width)
        y = math.random(canvas.height)
        canvas.fillmode = true

        --canvas.polygon(x, y, x + 10, y - 5, x + 5, y - 5)

        canvas.square(x, y, 5)
    end
    if key() == "s" then
        quit()
    end
    --canvas.defreeze()
end