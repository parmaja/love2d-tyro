-------------------------------------------------------------------------------
--  This file is part of the "Lua LOVE Basic"
--
--  @license   The MIT License (MIT) Included in this distribution
--  @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
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

local debugging = false

graphics = love.graphics

if not program_file then
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
    else
        program_file = "intro.lua"
    end
end

program = assert(loadfile(program_file))

if debugging then
    require("mobdebug").start()
end

canvas = object:clone{
    shading = false,
    buffer = nil,
    lockbuffer = nil,
    lockCount = 0,
    hooks = {    --object that hooks to draw, keyboards
        draws = {}, --update and draw
        keys = {}, --key
    },
    data = {
        color = nil,
        backcolor = nil
    },
    mode = 0, -- 0 = normal top left, 1 = bottom left, 2 = center bottom left
    fill = false,
    last_x = 0,
    last_y = 0,
    width = 0,
    height = 0,
}

function canvas.add(o)
    canvas.hooks.draws[#canvas.hooks.draws + 1] = o
end

function canvas.remove(o)
    for i = 1, #canvas.hooks.draws do
        if canvas.hooks.draws[i] == o then
            table.remove(canvas.hooks.draws, i)
            break
        end
    end
end

--todo
console = {
}

--load_module = require "main_load"
--love.load = load_module.load

--ref: https://gist.github.com/BlackBulletIV/4218802

local delay_end = nil --a time to finish, and resume program coroutine
local paused = false --stop updating objects

local freezed = nil --a time to finish, and refresh canvas
local freezeTime = nil --time period to freeze

local co = nil

local function resume()
    if co then
        if delay_end and (delay_end < os.clock()) then
            delay_end = nil
            paused = false
        end

        if not delay_end then
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

function love.threaderror(thread, errorstr)
  print("Thread Error: ".. errorstr)
  --thread:getError() will return the same error string now.
end

function love.load()
    canvas.buffer = love.graphics.newCanvas()
    canvas.lockbuffer = love.graphics.newCanvas()
    canvas.width = canvas.buffer:getWidth()
    canvas.height = canvas.buffer:getHeight()

    shader = love.graphics.newShader(glow_glsl)

    love.graphics.setCanvas(canvas.buffer)

    canvas.color(colors.Black)
    canvas.backcolor(colors.LaurelGreen) -- WildBlueYonder   CamouflageGreen

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
            canvas.update(dt)
        end

        for k, o in pairs(canvas.hooks.draws) do
            if o.prepare and not o.prepared then
                o:prepare()
                o.prepared = true
            end
            if o.update then
                o:update(dt)
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
        if canvas.mode == 1 then
            love.graphics.translate(0, love.graphics.getHeight())
            love.graphics.scale(1, -1) --bug in love2D or i dont know how to slove it
        elseif canvas.mode == 2 then
            love.graphics.translate(math.floor(love.graphics.getWidth() / 2), math.floor(love.graphics.getHeight() / 2))
            love.graphics.scale(1, -1)
        end
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

    for k, o in pairs(canvas.hooks.draws) do
        if o.visible and o.draw then
            o:draw()
        end
    end
    if canvas.shading then
        love.graphics.setShader()
    end
end

local last_keypressed = nil

function love.textinput(chr)
    for k, o in pairs(canvas.hooks.keys) do
        if o.keypress then
            o:keypress(chr)
        end
    end
end

function love.keypressed(key, scancode, isrepeat)
    for k, o in pairs(canvas.hooks.keys) do
        if o.keydown then
            o:keydown(key, scancode, isrepeat)
        end
    end
    last_keypressed = key
end

function love.keyreleased(key)
    for k, o in pairs(canvas.hooks.keys) do
        if o.keyup then
            o:keyup(key, scancode, isrepeat)
        end
    end
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
    delay_end = nil
    freezed = nil
    freezeTime = nil
    canvas.lockCount = 0
end

function canvas.restart()
    canvas.hooks.draws = {}
    canvas.hooks.keys = {} --not sure
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
    canvas.data.backcolor = change_alpha(color, alpha)
    love.graphics.setBackgroundColor(canvas.data.backcolor)
    --present() no need, it will set in love.draw()
end

function canvas.color(color, alpha)
    canvas.data.color = change_alpha(color, alpha)
    love.graphics.setColor(canvas.data.color)
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
    delay_end = os.clock() + seconds
    present()
end

function pause(seconds)
    delay_end = os.clock() + seconds
    paused = true
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