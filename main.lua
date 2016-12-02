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

graphics = love.graphics

program_file = arg[#arg]
program = assert(loadfile(program_file))

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

--ref: https://gist.github.com/BlackBulletIV/4218802

gl_glow = [[// adapted from http://www.youtube.com/watch?v=qNM0k522R7o

extern vec2 size;
extern int samples = 5; // pixels per axis; higher = bigger glow, worse performance
extern float quality = 2.5; // lower = smaller glow, better quality

vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
{
  vec4 source = Texel(tex, tc);
  vec4 sum = vec4(0);
  int diff = (samples - 1) / 2;
  vec2 sizeFactor = vec2(1) / size * quality;

  for (int x = -diff; x <= diff; x++)
  {
    for (int y = -diff; y <= diff; y++)
    {
      vec2 offset = vec2(x, y) * sizeFactor;
      sum += Texel(tex, tc + offset);
    }
  }

  return ((sum / (samples * samples)) + source) * colour;
}]]

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
                love.graphics.setCanvas(canvas.buffer)
                --love.graphics.setShader(effect)
                assert(coroutine.resume(co))
                --love.graphics.setShader()
                love.graphics.setCanvas()
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

    --glowShader = love.graphics.newShader(gl_glow)

    love.graphics.setCanvas(canvas.buffer)
        --love.graphics.setBlendMode("screen")
        love.graphics.setBackgroundColor(0, 0, 0)
        love.graphics.setLineWidth(1)
        --love.graphics.setLine(1, "smooth")
        love.graphics.setPointSize(1)
    love.graphics.setCanvas()

    if program then
        love.window.setTitle(program_file)
        co = coroutine.create(program)
        resume()
    end
end

-------------------------------------------------------

function love.update(dt)
    --glowShader:send("size", { x, y })
    for k, o in pairs(canvas.objects) do
        if o.update then
            o.update(o)
        end
    end
end

-------------------------------------------------------

function love.draw()
    if freezed and (freezed < os.clock()) then
        canvas.lockCount = canvas.lockCount - 1
        freezed = nil
    end

    love.graphics.push("all")
--	graphics.translate(dx, dy) --todo:
    love.graphics.setColor(colors.White)
    love.graphics.setBlendMode("alpha", "premultiplied")
    if canvas.locked() then --locked
        love.graphics.draw(canvas.lockbuffer)
    else
        love.graphics.draw(canvas.buffer)
    end
    love.graphics.pop()

    if freezeTime then
        canvas.lock()
        freezed = os.clock() + freezeTime
    end

    for k, o in pairs(canvas.objects) do
        if o.visible then
            o.draw()
        end
    end

    if canvas.draw then
        canvas.draw()
    end

       resume()
end

last_keypressed = nil

function love.keypressed(key, scancode, isrepeat)
    last_keypressed = key
end

function love.keyreleased(key)
    last_keypressed = nil
end

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

-----------------------------------------------------
-- Colors
-----------------------------------------------------

colors = {
    count = 0 --deprecated, on lua 5.2 we can use #colors, but LOVE still at 5.1
}

colors_mt = {
    items = {}
}

colors_mt.__index =
    function(self, key)
        if type(key) == "number" then
            return colors_mt.items[key]
        end
    end

colors_mt.__newindex =
    function(self, key, value)
        self.count = #colors_mt.items + 1
        colors_mt.items[self.count] = value
        rawset(self, key, value)
    end

colors_mt.__len =  --need >lua5.2
    function(self)
        return #colors_mt.items
    end

setmetatable(colors, colors_mt)

colors.Black  = {0, 0 , 0}
colors.Violet = {148, 0, 211}
colors.Indigo = {75, 0, 130}
colors.Blue   = {0, 0, 255}
colors.Green  = {0, 255, 0}
colors.Yellow = {255, 255, 0}
colors.Orange = {255, 127, 0}
colors.Red    = {255, 0, 0}
colors.White  = {255,255,255}

--------------
-- Keyboard
--------------

keys = {}

keys.Space = "space"
keys.Escape = "escape"

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
    paused = nil
    freezed = nil
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
        love.graphics.setColor(r)
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

--not draw just set the start point to use it in line

function canvas.setpoint(x, y)
    canvas.last_x = x
    canvas.last_y = y
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
        love.graphics.setColor(self.color)
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
        love.graphics.setColor(self.color)
        love.graphics.rectangle(fillmode(self.fillmode), self.x, self.y, self.width, self.height)
    end

    --self.x, self.y, self.r = new_x, new_y, new_r

    canvas.objects[#canvas.objects + 1] = self
    return self
end

--todo:

turtles = {
}


function key()
    return last_keypressed
end

--------------------------
--
--------------------------

--not recomended to use sleep, use pause instead

function sleep(seconds)
    love.timer.sleep(seconds)
    --present()
end

function pause(seconds)
    paused = os.clock() + seconds
    present()
end

function freeze(seconds, repeated)
    canvas.lock()
    freezed = os.clock() + seconds
    if repeated then
        freezeTime = seconds
    end
    present()
end

function quit()
    love.event.quit()
    present()
end

--End the routine but dont exit

function stop()
    canvas.lockCount = 0
    co = nil -- not sure, i want to kill coroutine
    coroutine.yield()
end

function restart()
    canvas.reset()
    last_keypressed = nil -- move to console.reset()
    co = coroutine.create(program)
    coroutine.yield()
end