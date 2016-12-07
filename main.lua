-------------------------------------------------------------------------------
--  This file is part of the "Lua LOVE Basic"
--
--   @license   The MIT License (MIT) Included in this distribution
--   @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------
--
-- Do not put this file in your project older
-- create new main.lua and put require("basic.main")
-- Have fun
-------------------------------------------------------------------------------
require "basic.utils"
require "basic.objects"
require "basic.colors"
require "basic.shaders"

require "basic.music"
require "basic.spirits"
require "basic.consoles"

debug_count = 0
local debugging = false
local stopped = false --stop updating objects

graphics = love.graphics

if #arg > 1 then
    for i = 2, #arg do
        local s = arg[i]
        if s == "-debug" then
            debugging = true
        elseif s:sub(1, 1) ~= "-" then
            program_file = s
            break
        end
    end
    program = assert(loadfile(program_file))
end

if debugging then
    require("mobdebug").start()
end

canvas = object:clone{
    shading = false,
    buffer = nil,
    lockbuffer = nil,
    lockCount = 0,
    objects = {},
    data = {
        color = nil,
        backcolor = nil
    },
    fill = false,
    last_x = 0,
    last_y = 0,
    width = 0,
    height = 0,
}

function canvas.add(o)
    canvas.objects[#canvas.objects + 1] = o
end

--todo
console = {
}

--load_module = require "main_load"
--love.load = load_module.load

--ref: https://gist.github.com/BlackBulletIV/4218802

local paused = nil --a time to finish, and resume program coroutine
local freezed = nil --a time to finish, and refresh canvas
local freezeTime = nil --time period to freeze

local co = nil

local function resume()
    if co then
        if paused and (paused < os.clock()) then
            paused = nil
        end

        if not paused then
            if coroutine.status(co) ~= "dead" then
                --love.graphics.push("all")
                assert(coroutine.resume(co))
                --love.graphics.pop()
            else
                co = nil
                canvas.reset()
            end
        end
    end
end

function love.load()
    canvas.buffer = love.graphics.newCanvas()
    canvas.lockbuffer = love.graphics.newCanvas()
    canvas.width = canvas.buffer:getWidth()
    canvas.height = canvas.buffer:getHeight()

    shader = love.graphics.newShader(glow_glsl)

    love.graphics.setCanvas(canvas.buffer)

    canvas.color(colors.White)
    canvas.backcolor(colors.Black)

    love.graphics.setLineWidth(1)
    --love.graphics.setLine(1, "smooth")
    love.graphics.setPointSize(1)
    love.graphics.setCanvas()

    if program then
        love.window.setTitle(program_file)
        co = coroutine.create(program)
    end
end

-------------------------------------------------------

function love.update(dt)
    if not stopped then --if stoped only we stop updating, but drawing keep it
        if canvas.update then
            canvas.update()
        end

        for k, o in pairs(canvas.objects) do
            if o.prepare and not o.prepared then
                o:prepare()
                o.prepared = true
            end
            if o.update then
                o.update(o)
            end
        end
    end
end

-------------------------------------------------------

function love.draw()
--	graphics.translate(offset_x, offset_y) --todo: canvas.offset(dx, dy)
    if canvas.shading then
        love.graphics.setShader(shader)

        shader:send("size", { 0.1, 0.1 })
        --shader:send("light_pos", {500, 200, 0})
    else
        love.graphics.setShader()
    end

    if program then
        love.graphics.setCanvas(canvas.buffer)
        resume()
        love.graphics.setCanvas()


        love.graphics.setColor(canvas.data.color)
        love.graphics.setBackgroundColor(canvas.data.backcolor)

        love.graphics.push("all")
        love.graphics.setBlendMode("alpha", "premultiplied")
        love.graphics.setColor({255, 255, 255})
        if not canvas.locked() then
            love.graphics.draw(canvas.buffer)
        else
            love.graphics.draw(canvas.lockbuffer)
        end
        love.graphics.pop()
    else
        love.graphics.print("NO FILE LOADED", 10, 10)
    end

    if canvas.draw then
        canvas.draw()
    end

    for k, o in pairs(canvas.objects) do
        if o.visible and o.draw then
            o:draw()
        end
    end
    if canvas.shading then
        love.graphics.setShader()
    end
end

local last_keypressed = nil

function love.keypressed(key, scancode, isrepeat)
    last_keypressed = key
    if last_keypressed == "p" then
        music.beep()
    elseif last_keypressed == "s" then
        music.stop()
    end
end

function love.keyreleased(key)
    last_keypressed = nil
end

function fillmode(b)
    if not b then
        b = canvas.fill
    end

    if b then
        return "fill"
    else
        return "line"
    end
end

--------------
-- Keyboard
--------------

keys = {}

keys.Space = "space"
keys.Escape = "escape"

function key(kill)
    result = last_keypressed
    if kill then
        last_keypressed = nil
    end
    return result
end

-----------------------------------------------------
--
-----------------------------------------------------

function canvas.reset()
    paused = nil
    freezed = nil
    freezeTime = nil
    canvas.lockCount = 0
end

function canvas.restart()
    canvas.objects = {}
    canvas.reset()
end

function canvas.refresh() --not tested yet
    if co and coroutine.running()  then
        coroutine.yield()
    end
end

local function present(ignore) --ignore freezing
    if co and coroutine.running()  then
        if freezed and (freezed > 0) and (freezed < os.clock()) then --not forever, and expired
            freezed = nil
        end

        if not freezed then
            coroutine.yield()
        end

        if not freezed and freezeTime then
            freezed = os.clock() + freezeTime
        end
    end
end

function canvas.lock()
    love.graphics.push("all")
    love.graphics.setCanvas(canvas.lockbuffer)
    love.graphics.setColor({255, 255, 255})
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.clear()
    love.graphics.draw(canvas.buffer)
    love.graphics.setCanvas()
    love.graphics.pop()

    canvas.lockCount = canvas.lockCount + 1
    present()
end

function canvas.unlock()
    canvas.lockCount = canvas.lockCount - 1
    --TODO: check if less than 0
    present()
end

function canvas.locked()
    return (canvas.lockCount > 0)
end

------------------------

function canvas.defreeze()
    freezed = nil
    freezeTime = nil
    present()
end

function canvas.freeze(seconds, once)
    present()
    if seconds then
        freezed = os.clock() + seconds
        if not once then
            freezeTime = seconds
        end
    else
        freezed = 0 --forever, until defreeze
    end
end

---------------------------

function canvas.backcolor(color, alpha)
    if alpha then
        color[4] = alpha
    elseif #color < 4 then
        color[4] = 255
    end
    love.graphics.setBackgroundColor(color)
    canvas.data.backcolor = color
    --present() it will set in love.draw()
end

function canvas.color(color, alpha)
    if alpha then
        color[4] = alpha
    elseif #color < 4 then
        color[4] = 255
    end
    love.graphics.setColor(color)
    canvas.data.color = color
    --present() --maybe no need to present()
end

function canvas.clear(color)
    love.graphics.clear(color) --<-- clear the background only
    --love.graphics.points(10, 10) --<-- it clear now
    present()
end

function canvas.save(filename)
    data = canvas.buffer:newImageData()
    data:encode("png", filename)
end

function canvas.circle(x, y, r)
    love.graphics.circle(fillmode(), x, y, r)
    present()
end

function canvas.rectangle(x, y, w, h)
    if not h  then
        h = w
    end
    love.graphics.rectangle(fillmode(), x, y, w, h)
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

function canvas.polygon(...)
    love.graphics.polygon(fillmode(), ... )
    present()
end

function canvas.square(x, y, size)  --x,y is center of rectangle
    love.graphics.rectangle(fillmode(), x - size / 2, y - size / 2, size, size)
    present()
end

function canvas.triangle(x, y, side)  --x,y is center of triangle
    --love.graphics.polygone(fillmode(), ) --todo
    present()
end

--not draw just set the start point to use it in line

function canvas.setpoint(x, y)
    canvas.last_x = x
    canvas.last_y = y
end

function canvas.text(s, x, y)
    love.graphics.print(s, x, y);
    present()
end

--------------------------
-- Utils
--------------------------

--not recomended to use sleep, use pause instead
function sleep(seconds)
    love.timer.sleep(seconds)
end

function delay(seconds) --TODO

end

--Do not call co.resume for a while
function pause(seconds)
    paused = os.clock() + seconds
    present()
end

function quit()
    love.event.quit()
    present()
end

--End the routine but dont exit

function stop()
    canvas.reset()
    freezed = nil
    stopped = true
    local old = co
    co = nil -- not sure, i want to kill coroutine

    if old and coroutine.running()  then
        coroutine.yield()
    end
end

function restart()
    canvas.restart()
    last_keypressed = nil -- move to console.reset()
    co = coroutine.create(program)
    coroutine.yield()
end