x, y = 0, 0
c = 0

function canvas.draw()
    love.graphics.circle("line", x + 200, y, 50)
    love.graphics.rectangle("line", x + 200 + 0.5, y, 100, 100)
end

humster = images.new("projects/hamster.png")

for i = 0, 50 do
    --print(i)
    --pause(0.2)
    x = x + 5
    y = y + 5
    canvas.lock()
    canvas.clear()
    canvas.setcolor(255, 0, 0)
    canvas.rectangle(x, y, 100, 100)
    canvas.circle(x, y, 50)
    canvas.text("Hello", x, y)
    humster.move(x, y)
    canvas.unlock()
    pause(0.01)
end
--quit()