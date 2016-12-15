canvas.backcolor(colors.Black)
canvas.freeze(0.01)
while true do
--		canvas.freeze()
--    for i = 0, 50 do
        r = math.random(1, 10) --size of circle
        c = math.random(3, colors.count) --todo: use #colors insdead when LOVE2D use >5.2
        canvas.color(colors[c], 100)
        x = math.random(canvas.width)
        y = math.random(canvas.height)
        canvas.fill = true
        canvas.circle(x, y, r)
--    end
--    canvas.defreeze()
end