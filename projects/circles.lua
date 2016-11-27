x, y = 0, 0
c = 0

for i = 0, 50 do
    x = x + 5
    y = y + 5
    --canvas.lock()
    canvas.clear()
    canvas.setbackcolor(255, 255, 255)
    canvas.setcolor(Green)
    canvas.rectangle(x, y, 100, 100)
    canvas.setcolor(Red)
    canvas.circle(x, y, 50)
    canvas.text("Hello", x + 150, y)
    canvas.unlock()
    pause(0.005)  -- one second
end
--quit()