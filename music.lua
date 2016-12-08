-------------------------------------------------------------------------------
--  This file is part of the "Lua LOVE Basic"
--
--   @license   The MIT License (MIT) Included in this distribution
--   @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------

music = {
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
--ref: http://www.qb64.net/wiki/index.php?title=SOUND
-------------------------------------------------------------------------------
--[[					The Seven Music Octaves

     Note     Frequency      Note     Frequency      Note      Frequency
   1* D#1 ...... 39           G3 ....... 196          A#5 ...... 932
      E1 ....... 41           G#3 ...... 208          B5 ....... 988
      F1 ....... 44           A3 ....... 220       6* C6 ....... 1047
      F#1 ...... 46           A#3 ...... 233          C#6 ...... 1109
      G1 ....... 49           B3 ....... 247          D6 ....... 1175
      G#1 ...... 51        4* C4 ....... 262          D#6 ...... 1245
      A1 ....... 55           C#4 ...... 277          E6 ....... 1318
      A#1 ...... 58           D4 ....... 294          F6 ....... 1397
      B1 ....... 62           D#4 ...... 311          F#6 ...... 1480
   2* C2 ....... 65           E4 ....... 330          G6 ....... 1568
      C#2 ...... 69           F4 ....... 349          G# ....... 1661
      D2 ....... 73           F#4 ...... 370          A6 ....... 1760
      D#2 ...... 78           G4 ....... 392          A#6 ...... 1865
      E2 ....... 82           G#4 ...... 415          B6 ....... 1976
      F2 ....... 87           A4 ....... 440       7* C7 ....... 2093
      F#2 ...... 92           A# ....... 466          C#7 ...... 2217
      G2 ....... 98           B4 ....... 494          D7 ....... 2349
      G#2 ...... 104       5* C5 ....... 523          D#7 ...... 2489
      A2 ....... 110          C#5 ...... 554          E7 ....... 2637
      A#2 ...... 117          D5 ....... 587          F7 ....... 2794
      B2 ....... 123          D#5 ...... 622          F#7 ...... 2960
   3* C3 ....... 131          E5 ....... 659          G7 ....... 3136
      C#3 ...... 139          F5 ....... 698          G#7 ...... 3322
      D3 ....... 147          F#5 ...... 740          A7 ....... 3520
      D#3 ...... 156          G5 ....... 784          A#7 ...... 3729
      E3 ....... 165          G#5 ...... 831          B7 ....... 3951
      F3 ....... 175          A5 ....... 880       8* C8 ....... 4186
      F#3 ...... 185
                             # denotes sharp
-----------------------------------------------------------------------------]]

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
    local scores = {
        c      = 0,
        ["c#"] = 1,
        d      = 2,
        ["d#"] = 3,
        e      = 4,
        f      = 5,
        ["f#"] = 6,
        g      = 7,
        ["g#"] = 8,
        a      = 9,
        ["a#"] = 10,
        ["b"]  = 11,
    }

    local baseNumber = 2 ^ (1/12)
    local baseOctave = 4
    local baseNoteC4 = 261.63
    local baseLength = 4

    local freq = 0
    local tempo = 120
    local octave = 4
    local length = 4 --note length
    local mode = 0
    local loop = 0
    --local offset = 1

    local function playnote(note, offset, len) --playnote("c", 1) --playnote(char, number[-1,0,+1]) --
        local index = (octave - baseOctave) * 12 + scores[note] + offset
        f = math.floor(baseNoteC4 * (baseNumber ^ index))
        l = math.floor(600 * baseLength / (tempo * len));
        print("freq", f)
        print("octave", f)
        print("length", l)
--    	note =
        --music.sound(l, f)
        --while music.source:isPlaying() do
            --oh no
        --end
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
        return (p <= #notes)
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

            if chr == "#" then
                note = note .. "#"
                next()
            end

            local offset = 0
            if chr == "+" then
                offset = 1
                next()
            elseif chr == "-" then
                offset = -1
                next()
            end

            local len = scan_number() or length
            playnote(note, offset, len)
        elseif chr == "n" then
            local number = scan_number()
            if number == nil then
                error("n command need Number")
            end
        elseif chr == "t" then
            next()
            tempo = scan_number()
        elseif chr == "l" then
            next()
            length = scan_number()
        elseif chr == "p" then
            next()
            pause = scan_number()
        elseif chr == "o" then
            next()
            octave = scan_number()
        elseif chr == "<" then
            octave = octave + 1
            next()
        elseif chr == ">" then
            octave = octave - 1
            next()
        elseif chr == "." then
            --idk what is this
            next()
        elseif chr == "m" then --backlegcy
            next() --ingore next char
            next()
        else
            error("[music.play] Can not recognize :" .. tostring(chr))
        end
    end
end

print "test parser"
--composer.parse("a#40b10c50d#e+f-g")
--composer.parse("cc#dd#efgab")
composer.parse("o3cc#dd#efgab")
--parse("mfl16t155o2mnb4p8msbbmnb4p8msbbb8g#8e8g#8b8g#8b8o3e8o2b8g#8e8g#8")
