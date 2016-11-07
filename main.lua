require("basic")

draw = {}

--load_module = require "main_load"
--love.load = load_module.load

function game()
	local g = require(game_file)
end

function love.load()
-- create canvas
	game_file = arg[2]
    canvas = love.graphics.newCanvas()

--    love.graphics.setCanvas(canvas)
--    love.graphics.setCanvas()
    if game_file then
    	co = coroutine.create(game)
        print(coroutine.status)
        coroutine.resume(co)
        print(coroutine.status)
    end
end

function love.draw()
    love.graphics.setColor(255,255,255)
    love.graphics.draw(canvas)
    if co then
        print(coroutine.status(co))
    	if not coroutine.resume(co) then
        	print "not resumed"
            co = nil
    	end
	end
end

-----------------------------------------------------
--
--
-----------------------------------------------------

function refresh()
   --coroutine.yield()
end

text = 0
graphic = 1

local screenmode = text

function screen(mode)
  screenmode = mode
  refresh()
end

function draw.setcolor(r, b, g)
	love.graphics.setColor(r, b, g)
    refresh()
end

function draw.circle(x, y, r)
    love.graphics.setCanvas(canvas)
	love.graphics.circle("line", x, y, r)
    love.graphics.setCanvas()
    refresh()
end

function draw.rectangle(x, y, size)
    love.graphics.setCanvas(canvas)
    love.graphics.rectangle('line',x, y, size, size)
    love.graphics.setCanvas()
    refresh()
end

function draw.clear()
    love.graphics.setCanvas(canvas)
    love.graphics.clear();
    love.graphics.setCanvas()
    refresh()
end

function pause(ms)
    love.timer.sleep(ms)
    refresh()
end