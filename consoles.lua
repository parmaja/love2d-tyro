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
    "123456789.,!?-+/():;%&`'*#=[]\"")
    --self.font:setLineHeight(10)

    self.charWidth  = self.font:getWidth("_")
    self.charHeight = self.font:getHeight("|")
    self.lineHeight = self.charHeight + self.lineSpacing

    self.font:setLineHeight(self.lineHeight)
    print ("font height", self.lineHeight)
end

function console:add(new_text)
    local line = line:clone{ text = new_text}
    self.lines[#self.lines + 1] = line
    return line
end

function console:update(dt)
end

function console:draw()
    local x = self.window.top
    local y = self.window.left

    love.graphics.setFont(self.font)

    local h = self.font:getLineHeight()

    for i = 1, #self.lines do
    --for line in self.lines do
        line = self.lines[i]
        love.graphics.print(line.text, x, y)
        y = y + h
    end
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


-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

classes.line = line
classes.console = console