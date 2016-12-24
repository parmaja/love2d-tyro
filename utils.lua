-------------------------------------------------------------------------------
--  This file is part of the "Lua LOVE Basic"
--
--   @license   The MIT License (MIT) Included in this distribution
--   @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------

math.randomseed(os.time())

function io.writeln(...)
    write(...)
    io.write("\n")
end

function io.input(s)
    if s then
        write(s)
    end
    io.flush();
    s = io.read()
    x = tonumber(s)
    if x == nil then
        return s
    else
        return x
    end
end

function ExtractFileName(filename)
    return string.match(filename, "(.-)([^\\]-([^\\%.]+))$")
end

function table.print(o)
    for k, v in pairs(o) do
        print (k, v)
    end
end

local function delay(seconds)
    local n = os.clock() + seconds
    while os.clock() <= n do
    end
end