require("basic")

draw = {}

--load_module = require "main_load"
--love.load = load_module.load

function love.load()
-- create canvas
    canvas = love.graphics.newCanvas()

--    love.graphics.setCanvas(canvas)
--    love.graphics.setCanvas()
    if arg[2] then
	    require(arg[2])
    end
end

function love.draw()
    love.graphics.setColor(255,255,255)
    love.graphics.draw(canvas)
end

-----------------------------------------------------
--
--
-----------------------------------------------------

function draw.setcolor(r, b, g)
	love.graphics.setColor(r, b, g)
end

function draw.circle(x, y, r)
    love.graphics.setCanvas(canvas)
	love.graphics.circle("line", x, y, r)
    love.graphics.setCanvas()
    love.update()
end

function draw.rectangle(x, y, size)
    love.graphics.setCanvas(canvas)
    love.graphics.rectangle('line',x, y, size, size)
    love.graphics.setCanvas()
    love.update()
end

function draw.clear()
    love.graphics.setCanvas(canvas)
    love.graphics.clear();
    love.graphics.setCanvas()
    love.update()
end

function pause(ms)
    love.timer.sleep(ms)
    love.update()
end