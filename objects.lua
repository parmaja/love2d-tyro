-------------------------------------------------------------------------------
--  This file is part of the "Lua LOVE Basic"
--
--   @license   The MIT License (MIT) Included in this distribution
--   @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------
--  Base object for other objects, inherite and clone are here, kinda of oop
-------------------------------------------------------------------------------

classes = {
}

objects = {
}

object = {
    class = "object", --class name
    ascent = nil, --parent object/class
}

function object:copyfrom(o)
    if o then
        for k, v in pairs(o) do
            self[k] = v
        end
    end
end

function object:inherite(values)
    local o = setmetatable({}, getmetatable(self))

    for k, v in pairs(self) do
        o[k] = v
    end

    if values then
        for k, v in pairs(values) do
            o[k] = v
        end
    end

    o.ascent = self --last line we not copied

    return o
end

function object:clone(...)
    o = self:inherite(...)
    if o.init then
        o:init()
    end
    return o
end

visual = object:clone{
    visible = true,
    rotate = 0,
    x = 0,
    y = 0,
    strides = 0,
    stride = 0  --current stride, perhaps not number, used for animation
}

function visual:init()
    canvas.add(self)
end

function visual:_changed()
    if self.changed then
        self:changed()
    end
end

function visual:put(new_x, new_y)
    self.x, self.y = new_x, new_y
    self:_changed()
end

function visual:turn(phy)
    self.rotate = self.rotate + phy
    self:_changed()
end

function visual:show()
    self.visible = true
    self:_changed()
end

function visual:hide()
    self.visible = false
    self:_changed()
end

function visual.finish() --TODO finish it and remove it from objects list
end