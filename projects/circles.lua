x, y = 0, 0
c = 0

humster = images.new("projects/hamster.png")

c1 = circles.new(10, 10, 5)
c1.color = Green

function c1:update()
    self.r = self.r + 2
end


c2 = circles.new(50, 50, 5)
c2.color = Blue

function c2:update()
    self.r = self.r + 2
    self.x = self.x + 10
end


for i = 0, 50 do
    --print(i)
    --pause(0.2)
    x = x + 5
    y = y + 5
    canvas.lock()
    canvas.clear()
    canvas.setcolor(255, 0, 0)
    --canvas.rectangle(x, y, 100, 100)
    --canvas.circle(x, y, 50)
    canvas.text("Hello", x, y)
    humster.move(x, y)
    c1.move(x + 2, y)
    canvas.unlock()
    --pause(0.01)
end
--quit()