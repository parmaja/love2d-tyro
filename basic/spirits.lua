-------------------------------------------------------------------------------
--  This file is part of the "Lua LOVE Basic"
--
--   @license   The MIT License (MIT) Included in this distribution
--   @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------
--------------------------
-- Image
--------------------------

function objects.image(filename)
    local self = visual:clone()

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
    local self = visual:clone()

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

shape = visual:inherite{
    fill = false,
    color = colors.White,
}

--------------------------
-- Circle
--------------------------

function objects.circle(new_x, new_y, new_size)
    local self = shape:clone{
        size = 0,
    }

    self.x =  new_x
    self.y = new_y
    self.size = new_size

    function self:draw()
        love.graphics.setColor(self.color)
        love.graphics.circle(fillmode(self.fill), self.x, self.y, self.size)
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


function objects.turtle(new_x, new_y, new_width, new_height) --TODO
    local self = shape:clone{
        on = true,
        width = new_width,
        height = new_height,
    }

    self.x =  new_x
    self.y = new_y

    function self:pen(on)
        self.on = on
    end

    function self:forward(count)
    end

    function self:backward(count)
    end

    function self:draw()
        love.graphics.setColor(self.color)
        love.graphics.rectangle(fillmode(self.fill), self.x, self.y, self.width, self.height)
    end

    return self
end