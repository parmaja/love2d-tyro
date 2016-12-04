canvas.backcolor(colors.Black)
canvas.freeze(0.001)
while true do
--		canvas.freeze()
--    for i = 0, 50 do
        r = math.random(5) + 2 --size of circle
        c = math.random(3, colors.count) --todo: use #colors insdead when LOVE2D use >5.2
        canvas.color(colors[c])
        x = math.random(canvas.width)
        y = math.random(canvas.height)
        canvas.fill = true
        canvas.circle(x, y, r)
--    end
    if key() == "s" then
        canvas.save("1.png")
    elseif key() == "q" then
        quit()
    end
--    canvas.defreeze()
end