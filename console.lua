-------------------------------------------------------------------------------
--  This file is part of the "Lua LOVE Basic"
--
--   @license   The MIT License (MIT) Included in this distribution
--   @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------

require "basic.utils"
require "basic.colors"
require "basic.objects"
require "basic.shaders"


console = visual:clone{
    window = {
        top = 10,
        left = 10,
        width = 500,
        hight = 500,
    },

    lines = {}
}

line = object:clone{
    text = ''
}