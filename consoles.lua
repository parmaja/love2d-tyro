-------------------------------------------------------------------------------
--  This file is part of the "Lua LOVE Basic"
--
--  @license   The MIT License (MIT) Included in this distribution
--  @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------

local console = visual:inherite{
    window = {
        top = 0,
        left = 0,
        width = 500,
        height = 500,
    },
    client = {},
    margin = 10,
    lines = {},
    col = 1,
    row = 1,
    line = nil, --current line text should be just pointer to lines[index].line
    cursor = {
        visible = true,
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

function console:load()
    --self.font = love.graphics.newFont(14)
    --self.font = love.graphics.newFont("VeraMono.ttf", 14)
    --self.font = love.graphics.newFont("clacon.ttf", 18)
    self.font = love.graphics.newImageFont("love_font.png",  " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\"", 1)
    --self.font:setLineHeight(10)
    self.charWidth  = self.font:getWidth("H")
    self.charHeight = self.font:getHeight("W")
    self.lineHeight = self.charHeight + self.lineSpacing

    self.cursor.width = self.charWidth
    self.cursor.height = self.charHeight

    self.font:setLineHeight(self.lineHeight)
    table.insert(canvas.hooks.keys, self)
end

function console:add(new_text)
    local line = line:clone{ text = new_text}
    self.lines[#self.lines + 1] = line
    return line
end

function console:update(dt)
    self.cursor.console = self
    self.cursor:update(dt)
end

function console:keypress(chr)
	self:add_char(chr)
end

function console:keydown(key, scancode, isrepeat)
	if key == "left" then
    	self.cursor.col = self.cursor.col - 1
    elseif key == "right" then
    	self.cursor.col = self.cursor.col + 1
	elseif key == "up" then
    	self.cursor.row = self.cursor.row - 1
    elseif key == "down" then
    	self.cursor.row = self.cursor.row + 1
	elseif key == "backspace" then
    	if self.cursor.col > 1 then
			local line = self.lines[self.cursor.row]
		    line.text = line.text:sub(1, self.cursor.col - 2) .. line.text:sub(self.cursor.col)
		    self.cursor.col = self.cursor.col - 1
        end
    elseif key == "delete" then
		local line = self.lines[self.cursor.row]
		line.text = line.text:sub(1, self.cursor.col - 1) .. line.text:sub(self.cursor.col + 1)
    end
end

function console:add_char(chr)
	local line = self.lines[self.cursor.row]
    line.text = line.text:sub(1, self.cursor.col - 1) .. chr .. line.text:sub(self.cursor.col)
    self.cursor.col = self.cursor.col + 1
end

function console:draw()
    love.graphics.push("all")
    love.graphics.setColor(colors.Black)
    love.graphics.rectangle("line", self.window.top, self.window.left, self.window.width, self.window.height)

    self.client.top = self.window.top + self.margin --we need inflat rect
    self.client.left = self.window.left + self.margin
    self.client.width = self.window.width + self.margin * 2
    self.client.height = self.window.height + self.margin * 2

    love.graphics.setScissor(unpack(self.client))
--    love.graphics.setBackgroundColor(colors.CamouflageGreen)
--    love.graphics.clear()

    local x = self.client.top
    local y = self.client.left

    love.graphics.setFont(self.font)
    love.graphics.setColor(colors.White)

    local h = self.lineHeight
    local max_h = self.client.top + self.client.height

    for i = 1, #self.lines do
    --for line in self.lines do
        local line = self.lines[i]
        love.graphics.print(line.text, x, y)
        y = y + h
        if y > max_h then
            break
        end
    end
    self.cursor.top = self.client.top
    self.cursor.left = self.client.left

    self.cursor:draw()
    love.graphics.setScissor()
    love.graphics.pop()
end

function objects.console()
    local self = console:clone()
    self:load()
    self.margin = self.charHeight
    self:add('Hello World')
    self:add('Every where')
    self.cursor.row = 2
    self.cursor.col = 5
    return self
end

-------------------------------------------------------------------------------
-- Cursor
-------------------------------------------------------------------------------

function console.cursor:position()
    self.top = self.console.client.top + (self.row - 1) * self.console.charHeight
    self.left = self.console.client.left + (self.col - 1) * self.console.charWidth
    return self.left, self.top, self.console.charWidth, self.console.charHeight
end

function console.cursor:update(dt)
    if self.visible then
        self._timed = self._timed + dt
        local blinktime = 1
        local b = self._timed % blinktime
        if self._timed > blinktime then
            self._timed = b
        end
        if b > blinktime / 2 then
            b = b - blinktime / 2
        else
            b = blinktime / 2 - b
        end
        self.show = math.floor((b / (blinktime / 2)) * 255)
    end
end

function console.cursor:draw()
    if self.visible then
        if self.show > 0 then
            local x, y, w, h = self:position()
            local c = { love.graphics.getColor() }
            love.graphics.setLineWidth(1)
            love.graphics.setColor(change_alpha(colors.White, self.show))
            love.graphics.rectangle("fill", x, y + h  * 3/4, w , h / 4)
            love.graphics.setColor(c)
        end
    end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

classes.line = line
classes.console = console