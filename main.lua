canvas = {}

--load_module = require "main_load"
--love.load = load_module.load

run_file = arg[#arg]
run = assert(loadfile(run_file))
local paused = nil --a end time to finish, and resume run coroutine

function love.load()
-- create buffer
    buffer = love.graphics.newCanvas()
    love.graphics.setCanvas(buffer)
    love.graphics.setBlendMode("replace")
--	love.graphics.setColor(255,255,255)
    love.graphics.setCanvas()
    if run then
    	co = coroutine.create(run)
        coroutine.resume(co)
    end
end

function love.draw()
    --love.graphics.setColor(255,255,255)
    love.graphics.draw(buffer)
    if canvas.draw then
    	canvas.draw()
    end

    if co then
    	if paused and (paused < os.clock()) then
        	paused = nil
    	end

        if not paused then
    	    if not coroutine.resume(co) then
                co = nil
    	    end
        end
	end
end

-----------------------------------------------------
--
--
-----------------------------------------------------

function refresh()
    if co then
		coroutine.yield()
	end
end

text = 0
graphic = 1

local screenmode = text

function screen(mode)
  screenmode = mode
  --todo check if locked
  refresh()
end

function canvas.setcolor(r, b, g)
	love.graphics.setColor(r, b, g)
    --no need to referesh
end

function canvas.circle(x, y, r)
    love.graphics.setCanvas(buffer)
	love.graphics.circle("line", x, y, r)
    love.graphics.setCanvas()
    refresh()
end

function canvas.rectangle(x, y, size)
    love.graphics.setCanvas(buffer)
    love.graphics.rectangle('line',x, y, size, size)
    love.graphics.setCanvas()
    refresh()
end

function canvas.clear()
    love.graphics.setCanvas(buffer)
    love.graphics.clear();
    love.graphics.setCanvas()
    refresh()
end

--------------------------
-- Freeze your program
--------------------------

function sleep(seconds)
    love.timer.sleep(seconds)
    --refresh()
end

function pause(seconds)
	paused = os.clock() + seconds
    refresh()
end