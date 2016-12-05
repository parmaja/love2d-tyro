star = shape:clone{
    x = 200,
    y = 200,
    size  = 50,
    fill = true,
}

canvas.fill = true

function star:draw()
    canvas.color(colors.Yellow, 50)
    for i = 0 , 10 do
        canvas.circle(self.x + math.random(-5, 5), self.y + math.random(-5, 5), self.size)
    end
    canvas.color(colors.Orange, 100)
    canvas.circle(self.x, self.y, self.size)
end