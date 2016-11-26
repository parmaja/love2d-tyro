-----------------------------------------
--
--
-----------------------------------------
require "utils"

--print(arg[1])
run_file = arg[#arg]
run = assert(loadfile(run_file))


canvas = {
    buffer = nil,
    lockbuffer = nil,
    lockCount = 0,
    objects = {}
}

--load_module = require "main_load"
--love.load = load_module.load


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

    for k, o in pairs(canvas.objects) do
        if o.visible then
            o.draw()
        end
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

local function present()
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

    present()
end

function canvas.unlock()
    canvas.lockbuffer = nil
    canvas.lockCount = canvas.lockCount - 1
    present()
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
  present()
end

function canvas.setcolor(r, b, g)
    love.graphics.setColor(r, b, g)
    --no need to referesh
end

function canvas.circle(x, y, r)
    love.graphics.circle("line", x, y, r)
    present()
end

function canvas.rectangle(x, y, size)
    love.graphics.rectangle('line',x, y, size, size)
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
--
--------------------------


--------------------------
--
--------------------------

images = {
}

function images.new(filename)
    local self = {
        x =0 , y = 0,
        visible = true,
        img = nil
    }

    function self.move(new_x, new_y)
        self.x, self.y = new_x, new_y
    end

    function self.draw()
        love.graphics.draw(self.img, self.x, self.y)
    end

    --filename = love.filesystem.getWorkingDirectory() .. "/".. filename
    print(filename)
    self.img = love.graphics.newImage(filename)
    canvas.objects[#canvas.objects] = self
    return self
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


-------------------------
--
--
-------------------------
