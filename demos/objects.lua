canvas.color(colors.White)
console = objects.console()

c1 = objects.square(100, 100, 50)
--c1 = objects.circle(100, 100, 50)

function c1:prepare()
    self.t = 10
    self.z = 10
    self.fill = true
--    self.color = colors.Pink
end

function c1:update()
    if self.x > canvas.width then
        self.t = -self.t
    end

    if self.x < 0 then
        self.t = -self.t
    end

    self.x = self.x + self.t

    if self.y > canvas.height then
        self.z = -self.z
    end

    if self.y < 0 then
        self.z = -self.z
    end

    self.y = self.y + self.z

    if key() == "s" then
        stop()
    elseif key() == "g" then
        self:show()
    elseif key() == "h" then
        self:hide()
    end
--    local c = math.random(2, colors.count)
--    self.color =  colors[c]
end

c1.color = colors.Pink

c2 = objects.circle(200, 500, 50)
c2.prepare = c1.prepare
c2.update = c1.update

c2.color = {0,155,187}


richard = objects.image("richard-say.png")
richard.prepare = c1.prepare
richard.oldupdate = c1.update

function richard:update()
    self:oldupdate()
       if key() == "left" then
        self.rotate = self.rotate + 0.1
    elseif key() == "right" then
        self.rotate = self.rotate - 0.1
    end
end

c3 = c1:clone()
c3.x = 500
c3.y = 500
c3.size = 100
c3.color = colors.Red

function c3:draw()
   self.ascent.draw(self) --<-- ewww
   love.graphics.setColor(colors.White)
   love.graphics.circle(fillmode(self.fill), self.x, self.y, 10)
end