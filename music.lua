-------------------------------------------------------------------------------
--  This file is part of the "Lua LOVE Basic"
--
--   @license   The MIT License (MIT) Included in this distribution
--   @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------

music = {
    loop = false,
    background, --TODO: play in background
    volume = 50,
}

local composer = {
    source = nil, --current source playing/cached
    last = {
        pitch = nil,
        length = nil,
    }
}

--ref:  http://www.qb64.net/wiki/index.php/PLAY
--		https://github.com/miko/Love2d-samples/blob/master/MikoIntroScreen/Intro.lua#L38
--		http://www.headchant.com/2011/11/01/sound-synthesis-with-love-part-ii-sine-waves/
--      https://stackoverflow.com/questions/11355353/how-can-i-convert-qbasic-play-commands-to-something-more-contemporary
--ref: http://www.phy.mtu.edu/~suits/notefreqs.html

-------------------------------------------------------------------------------
--ref: http://www.qb64.net/wiki/index.php?title=SOUND
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

-----------------------------------
-- Example: makeSample(0.1, 440) --
-----------------------------------

local function makeSample(pitch, length) --(seconds, freq)
    local rate = 22050 -- or 44100
    local amplitude = 1.5 --not sure, i added it by my hand :P
    local tick = love.sound.newSoundData(length * rate, rate, 16, 1)
    for i = 0, length * rate - 1 do
           local sample = math.sin((i * pitch) * ((2 * math.pi) / rate)) * amplitude
          tick:setSample(i, sample)
    end
    return tick
end

local function delay(seconds)
    local n = os.clock() + seconds
    while os.clock() <= n do
    end
end

function music.sound(length, pitch, wait)
    wait = wait or false
    if composer.source then
        composer.source:stop()
    end
    if not (composer.source and (composer.last.length == length) and (composer.last.pitch == pitch)) then
        composer.last.length = length
        composer.last.pitch = pitch
        local sample = makeSample(pitch, length)
        composer.source = love.audio.newSource(sample)
        composer.source:setVolume(music.volume)
        composer.source:setLooping(false)
    end
    composer.source:play()
    if wait then
        --delay(length) --just trying
        while composer.source:isPlaying() do
            --oh no
        end
    end
end

function music.start()
    if composer.source then
        composer.source:play()
    end
end

function music.stop(all)
    if composer.source then
        composer.source:stop()
        composer.source = nil
    end
end

function music.beep()
    music.sound(0.2, 800)
end

function music.play(notes)
    composer.parse(notes)
end

function composer.parse(notes)
    --Constants values
    local baseNumber = 2 ^ (1/12)
    local baseOctave = 4
    local baseNoteC4 = 261.63
    local baseLength = 4
    local baseTempo = 60

    --Current values by default
    local freq = 0

    local tempo = 120
    local octave = 4
    local length = 4 --note length
    local subsequent = 0 -- 0 = legato 1 = normal 2 = staccato

    local pos = 0

    local scores = {
        ["c"]   = 0,
        ["c#"]  = 1,
        ["d"]   = 2,
        ["d#"]  = 3,
        ["e"]   = 4,
        ["f"]   = 5,
        ["f#"]  = 6,
        ["g"]   = 7,
        ["g#"]  = 8,
        ["a"]   = 9,
        ["a#"]  = 10,
        ["b"]   = 11,
    }

    --playnote(char, number[-1,0,+1], number[1..16], number[1..2])
    --playnote("c#", 1, 0, 0)
    --playnote("r", 1)
    local function playnote(note, duration, offset, increase)
        increase = increase or 1
        offset = offset or 0
        if note == "r" then
            f = 0
        else
            local index = scores[note]
            if not index then
                error("We dont have it in music:" .. note)
            end
            --calc index using current octave
            index = (octave - baseOctave) * 12 + index + offset
            f = math.floor(baseNoteC4 * (baseNumber ^ index))
        end
        --ref: https://music.stackexchange.com/questions/24140/how-can-i-find-the-length-in-seconds-of-a-quarter-note-crotchet-if-i-have-a-te
        --     http://www.sengpielaudio.com/calculator-bpmtempotime.htm
        --4 seconds for tempo = 60 beat per second, so what if tempo 120 and 2 for duration
        l = (baseLength / duration) * (baseTempo / tempo) * (1 + increase);
        print("freq", f)
        if debugging then
            --print("length", l)
        end

        local rest = 0   --legato
        if subsequent == 1 then --normal
            rest = l * 1 / 8
            l = l - rest
        elseif subsequent == 2 then --staccato
            rest = l * 1 / 4
            l = l - rest
        end
        music.sound(l, f, true)
        if rest > 0 then
            delay(rest)
        end
    end

    local i = 1

    local chr = ""
    local function check(chr, t)
        for k, v in pairs(t) do
            if chr == v then
                return true
            end
        end
        return false
    end

    local function reset()
        tempo = 120
        octave = 4
        length = 4 --note length
        subsequent = 0
    end

    local function step()
        pos = pos + 1
        return (pos <= #notes)
    end

    local function next()
        if not step() then
            return nil
        else
            chr = notes:sub(pos, pos)
            return true
        end
    end

    local function scan_number(max)
        local r = ""
        while pos <= #notes do
            if chr >= "0" and chr <= "9" then
                r = r .. chr
            else
                break
            end

            next()

            if max and #r >= max then
                break
            end
        end
        return tonumber(r)
    end

    local function scan(t)
        local r = ""
        while pos <= #notes do
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
    while pos <= #notes do
        if check(chr, {" ", "\n", "\r", "\t"}) then
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

            local increase = 0
            local by = 0.5
            if chr == "." then
                repeat
                    increase = increase + by --not sure about next dot
                    by = by / 2
                    next()
                until chr ~= "."
            end

            local duration = scan_number() or length

            playnote(note, duration, offset, increase)

        elseif chr == "n" then
            local number = scan_number(2) --TODO
            if number == nil then
                error("[music.play] n command need Number at :" .. tostring(pos))
            end
        elseif chr == "t" then
            next()
            tempo = scan_number()
        elseif chr == "l" then
            next()
            length = scan_number()
        elseif chr == "p" or chr == "r" then
            next()
            local duration = scan_number()
            playnote("r", duration, 0, 1)
        elseif chr == "o" then
            next()
            octave = scan_number()
        elseif chr == "<" then
            octave = octave + 1
            next()
        elseif chr == ">" then
            octave = octave - 1
            next()
        elseif chr == "," then
            playnote("r", 1, 0, 1)
            next()
        elseif chr == "m" then
            next()
            if chr == "n" then
                subsequent = 1
            elseif chr == "l" then
                subsequent = 0
            elseif chr == "s" then
                subsequent = 2
            elseif chr == "f" then --just for compatibility
            elseif chr == "b" then
            else
                error("[music.play] Illegal subcommand for M" .. chr .. " at :" .. tostring(pos))
            end
            next()
        else
            error("[music.play] Can not recognize: " .. chr .. " at :" .. tostring(pos))
        end
    end
    composer.source = nil
    composer.last.length = nil
    composer.last.pitch = nil
end