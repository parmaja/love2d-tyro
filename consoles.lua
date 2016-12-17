-------------------------------------------------------------------------------
--  This file is part of the "Lua LOVE Basic"
--
--   @license   The MIT License (MIT) Included in this distribution
--   @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------

local console = visual:inherite{
    window = {
        top = 10,
        left = 10,
        width = 500,
        hight = 500,
    },

    lines = {},
    col = 1,
    row = 1,
    line = nil, --current line text should be just pointer to lines[index].line
    cursor = {
        col = 0,
        row = 0,
        _timed = 0,
        width = 10, -- in pixels
        height = 10,
        show = 0,
    },
    charWidth  = 8,
    charHeight = 8,
    lineHeight = 8,
    lineSpacing = 0,

}

-------------------------------------------------------------------------------
-- Line
-------------------------------------------------------------------------------

local line = object:inherite{
    state = 0,
    att = nil, --attribute
    text = '',
}

function line:scan() --TODO
end

-------------------------------------------------------------------------------
-- Console
-------------------------------------------------------------------------------

function console:loadfont(fontname)
    self.font = love.graphics.newImageFont("love_font.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"", 1)
    --self.font:setLineHeight(10)

    self.charWidth  = self.font:getWidth("H")
    print(self.charWidth)
    self.charHeight = self.font:getHeight("W")
    self.lineHeight = self.charHeight + self.lineSpacing

    self.cursor.width = self.charWidth
    self.cursor.height = self.charHeight

    self.font:setLineHeight(self.lineHeight)


    print ("font height", self.lineHeight)
end

function console:add(new_text)
    local line = line:clone{ text = new_text}
    self.lines[#self.lines + 1] = line
    return line
end

function console:update(dt)
    self.cursor:update(dt)
end

function console:draw()
    local x = self.window.top
    local y = self.window.left

    love.graphics.setFont(self.font)
    love.graphics.setColor(change_alpha(colors.Red, 255))

    local h = self.lineHeight

    for i = 1, #self.lines do
    --for line in self.lines do
        local line = self.lines[i]
        love.graphics.print(line.text, x, y)
        y = y + h
    end
    self.cursor:draw()
end

function objects.console()
    local self = console:clone()
    --self.font = love.graphics.newFont("love_font.png", 16)

    self:loadfont("love_font.png")


    self:add('Hello World')
    self:add('Every where')
    self.cursor.col = 5
    self.cursor.row = 2
    return self
end

-------------------------------------------------------------------------------
-- Cursor
-------------------------------------------------------------------------------

function console.cursor:getPosition()
    return 10, 10, self.width, self.height
end

function console.cursor:update(dt)
    self._timed = self._timed + dt
    local blinktime = 1
    local b = self._timed % blinktime
    if self._timed > blinktime then
        self._timed = b
    end
    self.show = math.floor(b / blinktime * 255)
end

function console.cursor:draw()
    if self.show > 0 then
        x, y, w, h = self:getPosition()
        local c = { love.graphics.getColor() }
        love.graphics.setColor(change_alpha(colors.White, self.show))
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(c)
    end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

classes.line = line
classes.console = console