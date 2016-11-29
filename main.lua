-----------------------------------------
-- License: MIT
-- Author: Zaher Dirkey
-----------------------------------------
--
-- Do not put this file in your project older
-- create new main.lua and put require("basic.main")
-- Have fun
-----------------------------------------
require "basic.utils"

run_file = arg[#arg]
run = assert(loadfile(run_file))

canvas = {
    buffer = nil,
    lockbuffer = nil,
    lockCount = 0,
    objects = {},
    fillmode = false,
    last_x, last_y = 0, 0,
    width = 0,
    height = 0,
}

--todo
console = {
    buffer = nil,
    lockbuffer = nil,
    lockCount = 0,
    lines = {}
}

--load_module = require "main_load"
--love.load = load_module.load


local paused = nil --a end time to finish, and resume run coroutine

local function fillmode(b)
    if not b then
        b = canvas.fillmode
    end

    if b then
        return "fill"
    else
        return "line"
    end
end

local co = nil

function love.load()
    canvas.buffer = love.graphics.newCanvas()
    canvas.lockbuffer = love.graphics.newCanvas()
    canvas.width = canvas.buffer:getWidth()
    canvas.height = canvas.buffer:getHeight()

    love.graphics.setCanvas(canvas.buffer)
        --love.graphics.setBlendMode("screen")
        love.graphics.setBackgroundColor(0, 0, 0)
        love.graphics.setLineWidth(1)
        --love.graphics.setLine(1, "smooth")
        love.graphics.setPointSize(1)
    love.graphics.setCanvas()

    if run then
        co = coroutine.create(run)
        assert(coroutine.resume(co))
    end
end

-------------------------------------------------------

function love.update()
    for k, o in pairs(canvas.objects) do
        if o.update then
            o.update(o)
        end
    end
end

-------------------------------------------------------

function love.draw()
    love.graphics.push("all")
    love.graphics.setColor(255, 255, 255)
    love.graphics.setBlendMode("alpha", "premultiplied")
    if canvas.locked() then --locked
        love.graphics.draw(canvas.lockbuffer)
    else
        love.graphics.draw(canvas.buffer)
    end
    love.graphics.pop()

    for k, o in pairs(canvas.objects) do
        if o.visible then
            o.draw()
        end
    end

    if canvas.draw then
        canvas.draw()
    end

    if co then
        if paused and (paused < os.clock()) then
            paused = nil
        end

        if not paused then
            if coroutine.status(co) ~= "dead" then
                --love.graphics.push("all")
                love.graphics.setCanvas(canvas.buffer)
                assert(coroutine.resume(co))
                love.graphics.setCanvas()
                --love.graphics.pop()
            else
                co = nil
            end
        end
    end
end

local last_keypressed = nil

function love.keypressed(key, scancode, isrepeat)
    last_keypressed = key
end

-----------------------------------------------------
-- Colors
-----------------------------------------------------

Black = 0 --TODO make it as table of RGB { 0, 0, 0 }
Red = 1
Blue = 2
Green = 3
Yellow = 4
White = 5

function love.graphics.setColorByIndex(index)
--i will improve it, wait
    if index == Black then
        love.graphics.setColor(0, 0, 0)
    elseif index == Red then
        love.graphics.setColor(255, 0, 0)
    elseif index == Blue then
        love.graphics.setColor(0, 0, 255)
    elseif index == Yellow then
        love.graphics.setColor(255, 255, 0)
    elseif index == Green then
        love.graphics.setColor(0, 255, 0)
    elseif index == White then
        love.graphics.setColor(255, 255, 255)
    end
end

-----------------------------------------------------
--
-----------------------------------------------------

local function present()
    if co then
        if not canvas.locked() then
            coroutine.yield()
        end
    end
end

function canvas.reset()
    canvas.objects = {}
    canvas.lockCount = 0
    --canvas.buffer:clear()
    --canvas.lockbuffer.clear()
end

function canvas.lock()
    canvas.lockCount = canvas.lockCount + 1
    --canvas.lockbuffer = love.graphics.newCanvas()

    love.graphics.push("all")
    love.graphics.setCanvas(canvas.lockbuffer)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(canvas.buffer)
    love.graphics.setCanvas()
    love.graphics.pop()
    present()
end

function canvas.unlock()
    --canvas.lockbuffer = nil
    canvas.lockCount = canvas.lockCount - 1
    present()
end

function canvas.locked()
    return canvas.lockCount > 0
end

function canvas.backcolor(r, g, b) --todo: use color index
    love.graphics.setBackgroundColor(r, g, b)
    present()
end

function canvas.color(r, g, b)
    if b==nil and g==nil then
        love.graphics.setColorByIndex(r)
    else
        love.graphics.setColor(r, g, b)
    end
    --no need to present()
end

function canvas.circle(x, y, r)
    love.graphics.circle(fillmode(), x, y, r)
    present()
end

function canvas.rectangle(x, y, size)
    love.graphics.rectangle(fillmode(),x, y, size, size)
    present()
end

function canvas.line(x1, y1, x2, y2)
    if x2 == nil then
        x2, x1 = x1, canvas.last_x
    end
    if y2 == nil then
        y2, y1 = y1, canvas.last_y
    end

    love.graphics.line(x1, y1, x2, y2)
    canvas.last_x = x2
    canvas.last_y = y2
    present()
end

function canvas.point(x, y)
    love.graphics.points(x, y)
    canvas.last_x = x
    canvas.last_y = y
    present()
end

function canvas.clear()
    love.graphics.clear();
    present()
end

function canvas.text(s, x, y)
    love.graphics.print(s, x, y);
    present()
end


--------------------------
-- Objects
--------------------------
objects = {
}

object = {
}

function object.finish() --finish it and remove it from objects list
end

function inherite(object) --todo
    return {}
end

--------------------------
-- Images
--------------------------

images = {
}

function images.new(filename)
    local self = {
        visible = true,
        x =0 , y = 0,
        img = nil
    }

    function self.move(new_x, new_y)
        self.x, self.y = new_x, new_y
    end

    function self.draw()
        love.graphics.push("all")
        love.graphics.setColor(255,255,255)
        love.graphics.draw(self.img, self.x, self.y)
        love.graphics.pop()
    end

    --filename = love.filesystem.getWorkingDirectory() .. "/".. filename
    self.img = love.graphics.newImage(filename)
    canvas.objects[#canvas.objects + 1] = self
    return self
end

--------------------------
-- Circles
--------------------------

circles = {
}

function circles.new(new_x, new_y, new_r)
    local self = {
        visible = true,
        x =  new_x, y = new_y,
        r = new_r,
        color = Green,
        fillmode = false
    }

    function self.move(new_x, new_y)
        self.x, self.y = new_x, new_y
    end

    function self.draw()
        love.graphics.setColorByIndex(self.color)
        love.graphics.circle(fillmode(self.fillmode), self.x, self.y, self.r)
    end

    --self.x, self.y, self.r = new_x, new_y, new_r

    canvas.objects[#canvas.objects + 1] = self
    return self
end

--------------------------
-- Circles
--------------------------

rectangles = {
}

function rectangles.new(new_x, new_y, new_width, new_height)
    local self = {
        visible = true,
        x =  new_x, y = new_y,
        width = new_width,
        height = new_height,
        color = Green,
        fillmode = false
    }

    function self.move(new_x, new_y)
        self.x, self.y = new_x, new_y
    end

    function self.draw()
        love.graphics.setColorByIndex(self.color)
        love.graphics.rectangle(fillmode(self.fillmode), self.x, self.y, self.width, self.height)
    end

    --self.x, self.y, self.r = new_x, new_y, new_r

    canvas.objects[#canvas.objects + 1] = self
    return self
end

--todo:

turtles = {
}


function keypressed()
    local k = last_keypressed
    last_keypressed = nil
    return k
end

--------------------------
--
--------------------------

function sleep(seconds)
    love.timer.sleep(seconds)
    --present()
end

function pause(seconds)
    paused = os.clock() + seconds
    present()
end

function quit()
    love.event.quit()
    present()
end

function stop()  --End the coroutine but dont exit
    co = nil -- not sure, i want to kill coroutine
    coroutine.yield()
end

function reset()
    canvas.reset()
    co = coroutine.create(run)
    coroutine.yield()
end