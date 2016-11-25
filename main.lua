canvas = {
	lockCount = 0;
	function lock(){
    	lockCount++
    }

	function unlock(){
    	lockCount
    }
}

--load_module = require "main_load"
--love.load = load_module.load

run_file = arg[#arg]
run = assert(loadfile(run_file))
local paused = nil --a end time to finish, and resume run coroutine

function love.load()
    buffer = love.graphics.newCanvas()
    if run then
    	co = coroutine.create(run)
        coroutine.resume(co)
    end
end

function love.draw()
    --love.graphics.setColor(255,255,255)
    love.graphics.push("all")
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(buffer)
    love.graphics.pop()

    if canvas.draw then
    	canvas.draw()
    end

    if co then
    	if paused and (paused < os.clock()) then
        	paused = nil
    	end

        if not paused then
    		love.graphics.setCanvas(buffer)
    	    if not coroutine.resume(co) then
                co = nil
    	    end
            love.graphics.setCanvas()
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
	love.graphics.circle("line", x, y, r)
    refresh()
end

function canvas.rectangle(x, y, size)
    love.graphics.rectangle('line',x, y, size, size)
    refresh()
end

function canvas.clear()
    love.graphics.clear();
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