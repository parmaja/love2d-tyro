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

