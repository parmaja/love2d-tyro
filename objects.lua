--------------------------
-- Shape/Image Objects
--------------------------
objects = {
}

object = {
    class = "object", --class name
    ascent = nil, --parent object/class
    visible = true,
    rotate = 0,
    x = 0,
    y = 0,
}

function object:copyfrom(o)
    if o then
        for k, v in pairs(o) do
            self[k] = v
        end
    end
end

function object:inherite(values)
    local o = setmetatable({}, getmetatable(self))

    o.ascent = self

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

function object:clone(...)
    o = self:inherite(...)
    canvas.add(o)
    return o
end

function object:_changed()
    if self.changed then
        self:changed()
    end
end

function object:move(new_x, new_y)
    self.x, self.y = new_x, new_y
    self:_changed()
end

function object:show()
    self.visible = true
    self:_changed()
end

function object:hide()
    self.visible = false
    self:_changed()
end

function object.finish() --TODO finish it and remove it from objects list

end

--------------------------
-- Image
--------------------------

function objects.image(filename)

    local self = object:clone()

    self.img = love.graphics.newImage(filename)

    function self:draw()
        love.graphics.push("all")
        love.graphics.setColor(colors.White)
        love.graphics.setBlendMode("alpha", "premultiplied")
        love.graphics.draw(self.img, self.x, self.y, self.rotate)
        love.graphics.pop()
    end
    return self
end

--------------------------
-- Background
--------------------------

function objects.background(filename)
    local self = object:clone()

    self.img = love.graphics.newImage(filename)

    function self:scroll(dx, dy)
    end

    function self:draw()
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
-- Circle
--------------------------

function objects.circle(new_x, new_y, new_r)
    local self = shape:clone{
        r = 0,
    }

    self.x =  new_x
    self.y = new_y
    self.r = new_r

    function self:draw()
        love.graphics.setColor(self.color)
        --love.graphics.circle(fillmode(self.fill), self.x, self.y, self.r)
    end

    return self
end

--------------------------
-- Rectangle
--------------------------

function objects.rectangle(new_x, new_y, new_width, new_height)
    local self = shape:clone{
        width = new_width,
        height = new_height,
    }

    self.x =  new_x
    self.y = new_y

    function self:draw()
        love.graphics.setColor(self.color)
        love.graphics.rectangle(fillmode(self.fill), self.x, self.y, self.width, self.height)
    end

    return self
end

function objects.square(new_x, new_y, new_size)  --x,y is center of rectangle
    local self = shape:clone{
        size = new_size,
    }

    self.x =  new_x
    self.y = new_y

    function self:draw()
        love.graphics.setColor(self.color)
        love.graphics.rectangle(fillmode(self.fill), self.x - self.size / 2, self.y - self.size / 2, self.size, self.size)
    end

    return self
end

--todo:


function objects.turtle(new_x, new_y, new_width, new_height)
    local self = shape:clone{
        width = new_width,
        height = new_height,
    }

    self.x =  new_x
    self.y = new_y

    function self:draw()
        love.graphics.setColor(self.color)
        love.graphics.rectangle(fillmode(self.fill), self.x, self.y, self.width, self.height)
    end

    return self
end