-------------------------------------------------------------------------------
--  This file is part of the "Tyro"
--
--  @license   The MIT License (MIT) Included in this distribution
--  @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------

-----------------------------------------------------
-- Colors
-----------------------------------------------------

--ref: http://colors.findthedata.com/compare/306-384/Navy-Blue-vs-Royal-Blue

colors = {
    count = 0 --deprecated, on lua 5.2 we can use #colors, but LOVE still at 5.1
}

local colors_mt = {
    items = {}
}

local color_mt = {
    __add = function (lhs, rhs)
        local result = {}
        result[1] = (lhs[1] + rhs[1]) / 2
        result[2] = (lhs[2] + rhs[2]) / 2
        result[3] = (lhs[3] + rhs[3]) / 2
        if lhs[4] and rhs[4] then
            result[4] = (lhs[4] + rhs[4]) / 2
        end
        return result
      end,

    __sub = function (lhs, rhs)
        local result = {}
        result[1] = (lhs[1] - rhs[1]) / 2
        result[2] = (lhs[2] - rhs[2]) / 2
        result[3] = (lhs[3] - rhs[3]) / 2
        if lhs[4] and rhs[4] then
            result[4] = (lhs[4] + rhs[4]) / 2
        end
        return result
      end,

    --number (0, 100)
    __mul = function (lhs, number)
        local result = {}

        number = math.floor((255 * 2 * number) / 100 - 255)

        if type(number) ~="number" then
            error("Color only multiply with number")
        end

        local function check(c)
            if c > 255 then
                c = 255
            elseif c < 0 then
                c = 0
            end
            return c
        end
        result[1] = check(lhs[1] + number)
        result[2] = check(lhs[2] + number)
        result[3] = check(lhs[3] + number)
        if lhs[4] then
            result[4] = lhs[4]
        end
        return result
      end,
}

colors_mt.__index =
    function(self, key)
        if type(key) == "number" then
            return colors_mt.items[key]
        end
    end

colors_mt.__newindex =
    function(self, key, value)
        if type(value) == "table" then --considered a color
            self.count = #colors_mt.items + 1
            colors_mt.items[self.count] = value
            setmetatable(value, color_mt)
            rawset(self, key, value)
        end
    end

colors_mt.__len =  --need >lua5.2
    function(self)
        return #colors_mt.items
    end

setmetatable(colors, colors_mt)
--Rainbow colors
colors.Black  = {0, 0 , 0}
colors.Brown  = {165, 42, 42}
colors.Red    = {255, 0, 0}
colors.Orange = {255, 127, 0}
colors.Yellow = {255, 255, 0}
colors.Green  = {0, 255, 0}
colors.Blue   = {0, 0, 255}
colors.Indigo = {75, 0, 130}
colors.Violet = {148, 0, 211}
colors.White  = {255,255,255}
---------------------
colors.Maroon = {128, 0, 0}
colors.Pink   = {255,84,167}
colors.Lime   = {50, 205, 50}

colors.Silver = {192,192,192}
colors.Gray   = {128,128,128}
colors.RoyalBlue = {00, 23, 66}
colors.OceanBlue = {0, 119, 190}
colors.Navy = {0, 0, 128}
colors.WildBlueYonder = {162, 173, 208}
colors.LaurelGreen = {169, 186, 157}
colors.CamouflageGreen = {120, 134, 107}

--TODO more colors

function change_alpha(color, alpha)
    local c = {color[1], color[2], color[3], alpha}
    return c
end