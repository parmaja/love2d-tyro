-------------------------------------------------------------------------------
--	Music and Audio lib
--  https://en.wikipedia.org/wiki/Music_Macro_Language
--  This file is part of the "Lua LOVE Basic"
--
--  @license   The MIT License (MIT) Included in this distribution
--  @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------
require("basic.melody")

music = {
    loop = false,
    background, --TODO: play in background
    source = nil, --source can be a love sound source  or melody
    volume = 50,
}

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
    melody.playsound(440, 0.2)
end

function music.play(...)
    source = melody
    melody.play(...)
end

local function delay(seconds)
    local n = os.clock() + seconds
    while os.clock() <= n do
    end
end

---------------------------------------------
-- Example: composer:generate(440, 0.1)    --
---------------------------------------------
--generate((freq, seconds)
--generate sample waveform

saved = 1

function generate_sample(pitch, length, rest, tie)
    local rate = 44100 --22050
    local amplitude = 1 --not sure, i added it by my hand :P
    local data = love.sound.newSoundData((length + rest) * rate, rate, 16, 1) --rest keep it empty
    local samples = length * rate
    local sample = 0
    local c = 2 * math.pi * pitch / rate

    if pitch > 0 then
        for index = 0, samples - 1 do
            if melody.waveform then
                sample = melody.waveform(index, samples, pitch, rate, tie) * amplitude
            else
                --to keep it simple to understand: sample = math.sin((index * pitch) * ((2 * math.pi) / rate)) * amplitude
                sample = math.sin(index * c) * amplitude
            end
            data:setSample(index, sample) --bug in miniedit, put cursor on data and ctrl+f it now show "data"
        end
    end
    if saved < 5 then
        s = data:getString()
        love.filesystem.write("test"..tostring(saved)..".data", s)
    end
    saved = saved + 1
    return data
end

function melody.playsound(composer, pitch, length, rest, tie, wait)

    if composer.source then
--        if composer.source:isPlaying() then
--            error("it is playing, please wait")
--        end
        composer.source:stop()
    end
    if not (composer.source and composer.last and (composer.last.length == length) and (composer.last.pitch == pitch) and (composer.last.rest == rest) and (composer.last.tie == tie)) then
        local sample = generate_sample(pitch, length, rest, tie)
        composer.source = love.audio.newSource(sample)
        composer.source:setVolume(music.volume)
        composer.source:setLooping(false)
        composer.last = {}
        composer.last.pitch = pitch
        composer.last.length = length
        composer.last.rest = rest
        composer.last.tie = tie
        composer.source:play()
    else
        composer.source:rewind()
        composer.source:play()
    end

    if wait then
        while composer.source:isPlaying() do
            --oh we need to wait it
        end
    end
end