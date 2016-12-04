--------------------------
-- Shape/Image Objects
--------------------------
objects = {
}

object = {
    class = "object", --class name
    visible = true,
    x = 0,
    y = 0,
}

function object:inherite(values)
    local o = setmetatable({}, getmetatable(self))
    for k, v in pairs(self) do
        o[k] = v
    end

    if values then
        for k, v in pairs(values) do
            o[k] = v
        end
    end

    return o
end

function object:clone(values)
    o = self:inherite(values)
    canvas.add(o)
    return o
end

function object:move(new_x, new_y)
    self.x, self.y = new_x, new_y
end

function object.finish() --TODO finish it and remove it from objects list

end

--------------------------
-- Images
--------------------------

images = {
}

function images.new(filename)

    local self = object:clone()

    self.img = love.graphics.newImage(filename)

    function self.draw()
        love.graphics.push("all")
        love.graphics.setColor(colors.White)
        love.graphics.setBlendMode("alpha", "premultiplied")
        love.graphics.draw(self.img, self.x, self.y)
        love.graphics.pop()
    end
    return self
end

--------------------------
-- Background
--------------------------

backgrounds = {
}

function backgrounds.new(filename)
    local self = object:clone()

    self.img = love.graphics.newImage(filename)

    function self:scroll(dx, dy)
    end

    function self.draw()
        love.graphics.push("all")
        love.graphics.setColor(colors.White)
        love.graphics.setBlendMode("alpha", "premultiplied")
        love.graphics.draw(self.img, self.x, self.y)
        love.graphics.pop()
    end

    return self
end


--------------------------
-- Shapes
--------------------------

shape = object:inherite{
    fill = false,
    color = colors.White,
}

--------------------------
-- Circles
--------------------------

circles = {
}

function circles.new(new_x, new_y, new_r)
    local self = shape:clone{
        r = 0,
    }

    self.x =  new_x
    self.y = new_y
    self.r = new_r

    function self.draw()
        love.graphics.setColor(self.color)
        love.graphics.circle(fillmode(self.fill), self.x, self.y, self.r)
    end

    return self
end

--------------------------
-- Circles
--------------------------

rectangles = {
}

function rectangles.new(new_x, new_y, new_width, new_height)
    local self = shape:clone{
        width = new_width,
        height = new_height,
    }

    self.x =  new_x
    self.y = new_y

    function self.draw()
        love.graphics.setColor(self.color)
        love.graphics.rectangle(fillmode(self.fill), self.x, self.y, self.width, self.height)
    end

    return self
end

--todo:

turtles = {
}