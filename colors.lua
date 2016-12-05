-------------------------------------------------------------------------------
--  This file is part of the "Lua LOVE Basic"
--
--   @license   The MIT License (MIT) Included in this distribution
--   @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------

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
colors.Brown    = {165, 42, 42}
colors.Red    = {255, 0, 0}
colors.Orange = {255, 127, 0}
colors.Yellow = {255, 255, 0}
colors.Green  = {0, 255, 0}
colors.Blue   = {0, 0, 255}
colors.Indigo = {75, 0, 130}
colors.Violet = {148, 0, 211}
colors.White  = {255,255,255}

colors.Maroon =	{128, 0, 0}
colors.Pink   = {255,84,167}
colors.Lime   =	{50, 205, 50}

colors.Silver = {192,192,192}
colors.Gray   = {128,128,128}
colors.RoyalBlue = {00, 23, 66}
colors.Navy = {0, 0, 128}

--TODO more colors