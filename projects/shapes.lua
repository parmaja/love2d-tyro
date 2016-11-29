x, y = 0, 0
c = 0

humster = images.new("hamster.png")

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

r1 = rectangles.new(50, 50, 100, 100)
r1.color = Yellow

function r1:update()
    self.width = self.width + 2
    self.height = self.height + 2
end

for i = 0, 50 do
    x = x + 5
    y = y + 5
    canvas.lock()
    canvas.clear()
    canvas.backcolor(0, 0, 0)
    canvas.color(Green)
    canvas.rectangle(x, y, 100, 100)
    canvas.color(Red)
    canvas.circle(x, y, 50)
    canvas.text("Hello", x + 150, y)
    humster.move(x, y)
    c1.move(x + 2, y)
    canvas.unlock()
    --pause(0.005)
end
--quit()
reset()