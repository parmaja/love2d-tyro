c1 = objects.square(100, 100, 50)
--c1 = objects.circle(100, 100, 50)
--c1 = objects.image("richard-say.png")

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
        c1:show()
    elseif key() == "h" then
        c1:hide()
    end
--    local c = math.random(2, colors.count)
--    self.color =  colors[c]
end

c1.color = colors.Pink

c2 = objects.circle(200, 500, 50)
c2.prepare = c1.prepare
c2.update = c1.update

c2.color = {0,155,187}
