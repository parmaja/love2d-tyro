function write(...)
    local args = {...}
    for i, v in ipairs(args) do
        io.write(v)
    end
end

function writeln(...)
    write(...)
    io.write("\n")
end

function input(s)
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

function int(x)
    return math.floor(x)
end

function extractFilename(filename)
    return string.match(filename, "(.-)([^\\]-([^\\%.]+))$")
end

function printtable(o)
    for k, v in pairs(o) do
        print (k, v)
    end
end

