canvas = {
    buffer = nil,
    lockbuffer = nil,
    lockCount = 0,
}

--load_module = require "main_load"
--love.load = load_module.load

run_file = arg[#arg]
run = assert(loadfile(run_file))

local paused = nil --a end time to finish, and resume run coroutine

function love.load()
    canvas.buffer = love.graphics.newCanvas()
    --love.graphics.setBlendMode("screen")
    love.graphics.setLineWidth(1)

    if run then
        co = coroutine.create(run)
        assert(coroutine.resume(co))
    end
end

function love.draw()
    love.graphics.push("all")
    love.graphics.setColor(255,255,255)
    love.graphics.setBlendMode("alpha", "premultiplied")

    if canvas.lockbuffer then --locked
        love.graphics.draw(canvas.lockbuffer)
    else
        love.graphics.draw(canvas.buffer)
    end

    love.graphics.pop()

    if canvas.draw then
        canvas.draw()
    end

    if co then
        if paused and (paused < os.clock()) then
            paused = nil
        end

        if not paused then
            love.graphics.setCanvas(canvas.buffer)
            if coroutine.status(co) == "dead" then
                co = nil
            else
                assert(coroutine.resume(co))
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

function canvas.lock()
    canvas.lockCount = canvas.lockCount + 1
    canvas.lockbuffer, canvas.buffer = canvas.buffer, love.graphics.newCanvas()

    love.graphics.setCanvas(canvas.buffer)
    love.graphics.push("all")
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(canvas.lockbuffer)
    love.graphics.pop()
    love.graphics.setCanvas()

    refresh()
end

function canvas.unlock()
    canvas.lockbuffer = nil
    canvas.lockCount = canvas.lockCount - 1
    refresh()
end

function canvas.locked()
    return canvas.lockCount > 0
end

local text = 0
local graphic = 1

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