x, y = 0, 0
c = 0

humster = objects.image("hamster.png")

c1 = objects.circle(10, 10, 5)
c1.color = colors.Green

function c1:update()
    self.size = self.size + 2
end

c2 = objects.circle(50, 50, 5)
c2.color = colors.Blue

function c2:update()
    self.size = self.size + 2
    self.x = self.x + 10
end

r1 = objects.rectangle(50, 50, 100, 100)
r1.color = colors.Yellow

function r1:update()
    self.width = self.width + 2
    self.height = self.height + 2
end

--canvas.freeze(0.01)

for i = 0, 50 do
    x = x + 5
    y = y + 5
    canvas.lock()
    canvas.clear()
    canvas.backcolor(colors.Black)
    canvas.color(colors.Green)
    canvas.rectangle(x, y, 100, 100)
    canvas.color(colors.Red)
    canvas.circle(x, y, 50)
    canvas.text("Hello", x + 150, y)
    humster:put(x, y)
    c1:put(x + 2, y)
    canvas.unlock()
    --pause(0.005)
end
--quit()
--restart()