-------------------------------------------------------------------------------
--  This file is part of the "Lua LOVE Basic"
--
--   @license   The MIT License (MIT) Included in this distribution
--   @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------

music = {
    mode,
    tempo, --number
    octave = 4;
    loop,
    background, --play in back ground
    volume = 2,

    source = nil --current source
}

--ref: 	https://github.com/miko/Love2d-samples/blob/master/MikoIntroScreen/Intro.lua#L38
--		http://www.headchant.com/2011/11/01/sound-synthesis-with-love-part-ii-sine-waves/
--qbasic todo style http://www.schoolfreeware.com/QBasic_Tutorial_25_-_Sound_And_Music_-_QB64.html
--http://www.qb64.net/wiki/index.php/PLAY
--ref: http://www.delphipraxis.net/970179-post1.html
--ref: http://www.phy.mtu.edu/~suits/notefreqs.html

-----------------
--
-- Example: makeSample(0.1, 440) --
-----------------
local function makeSample(length, pitch) --(seconds, freq)
    local rate = 8000 --44100
    local length = length or 0.1
    local pitch = pitch or 440
    local tick = love.sound.newSoundData(length * rate, rate, 16, 1)
    for i = 0, length * rate - 1 do
      local sample = math.sin((i * pitch * math.pi * 2) / rate) * length
      tick:setSample(i, sample)
    end
    return tick
end

function music.sound(length, pitch)
    local sample = makeSample(length, pitch)
      music.stop()
    music.source = love.audio.newSource(sample)
    music.source:setVolume(music.volume)
    music.source:setLooping(false)
    music.start()
end

function music.start()
    if music.source then
        music.source:play()
    end
end

function music.stop(all)
    if music.source then
        music.source:stop()
        music.source = nil
    end
end

function music.beep()
    music.sound(0.2, 800)
end

function music.play(notes)
end

local composer = {}

function composer.parse(notes)
    --notes:lower()
    local normal = {}
    normal["a"] = 9/12
    normal["b"]  = 10/12
    normal["c"]  = 0/12
    normal["d"]  = 2/12
    normal["e"]  = 4/12
    normal["f"]  = 5/12
    normal["g"]  = 7/12
    normal["h"]  = 11/12

    local freq = 0
    local tempo = 120
    local octave = 4
    local length = 4
    local mode = 0
    local length = 0.2
    local loop = 0
    local offset = 0

    local function playnote(note, step, length) --playnote("c", 1) --playnote(char, number[-1,0,+1]) --
        freq = 32.703125 * math.pow(2, octave + normal[note] + offset);
        print(freq)
        print(math.floor(freq))
--    	note =
        music.sound(length, freq)
    end

    local i = 1

    local chr = ""
    local p = 0

    local function check(chr, t)
        for k, v in pairs(t) do
            if chr == v then
                return true
            end
        end
        return false
    end

    local function reset()
    end

    local function step()
        p = p + 1
        return p <= #notes
    end

    local function next()
        if not step() then
            return nil
        else
            chr = notes:sub(p, p)
            return true
        end
    end

    local function scan_number()
        local r = ""
        while p <= #notes do
            if chr >= "0" and chr <= "9" then
                r = r .. chr
            else
                break
            end
            next()
        end
        return tonumber(r)
    end

    local function scan(t)
        local r = ""
        while p <= #notes do
            if check(chr, t) then
                r = r .. chr
            else
                break
            end
            next()
        end
        return r
    end

    next()
    while p <= #notes do
        if check(chr, {" ", "\n", "\t"}) then
            next()
        elseif chr=="!" then
            reset()
            next()
        elseif chr >= "a" and chr <="g" then
            local note = chr
            next()
            local step = scan{"#", "+", "-"}
            local length = scan_number()

            if step =="#" or step =="+"  then
                step = 1
            elseif step =="-" then
                step = -1
            else
                step = 0
            end
            playnote(note, step, length)
        elseif chr == "n" then
            local number = scan_number()
            if number == nil then
                error("n command need Number")
            end
        elseif chr == "t" then
            next()
            tempo = scan_number()
        elseif chr == "p" then
            pause = scan_number()
        elseif chr == "o" then
            octave = scan_number()
        elseif chr == "<" then
            octave = octave + 1
            next()
        elseif chr == ">" then
            result.octave = result.octave - 1
            next()
        elseif chr == "." then
            --idk what is this
            next()
        elseif chr == "m" then
            next() --ingore next char
            next()
        else
            error("[music.play] Can not recognize :" .. tostring(chr))
        end
    end
end

print "test parser"
--composer.parse("a#40b10c50d#e+f-g")
composer.parse("abcd")
--parse("mfl16t155o2mnb4p8msbbmnb4p8msbbb8g#8e8g#8b8g#8b8o3e8o2b8g#8e8g#8")

