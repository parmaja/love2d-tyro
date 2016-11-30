x, y = 0, 0
c = 0

canvas.clear()
for i = 0, 50 do
    x = x + 5
    y = y + 5
--    graphics.rotate(-30)
    canvas.fillmode = true
    canvas.lock()
    canvas.clear()
    canvas.backcolor(colors.White)
    canvas.color(colors.Green)
    canvas.rectangle(x, y, 100, 100)
    canvas.color(colors.Red)
    canvas.circle(x, y, 50)
    if key() == keys.Space then
        restart()
    elseif key() == keys.Escape then
        quit()
    elseif key() == "s" then
        stop()
    end
    canvas.text("Hello", x + 150, y)
    canvas.color(colors.Black)
    canvas.point(150, 150)
    canvas.line(200, 200)
    canvas.line(200, 150)
    canvas.unlock()
    --pause(0.05)
end
--quit()
restart()