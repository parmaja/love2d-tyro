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
    music.sound(440, 0.2)
end

function music.play(notes)
    source = melody
    melody.play(notes)
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

function generate_source(pitch, length)
    local rate = 44100 --22050
    local amplitude = 1 --not sure, i added it by my hand :P
    local data = love.sound.newSoundData(length * rate, rate, 16, 1)
    local samples = length * rate
    local sample = 0
    local c = 2 * math.pi * pitch / rate

    if pitch > 0 then
        for index = 0, samples - 1 do
            if melody.waveform then
                sample = melody.waveform(index, samples, pitch, rate) * amplitude
            else
                --to keep it simple to understand: sample = math.sin((index * pitch) * ((2 * math.pi) / rate)) * amplitude
                sample = math.sin(index * c) * amplitude
            end
            data:setSample(index, sample) --bug in miniedit, put cursor on data and ctrl+f it now show "data"
        end
    end
--[[    if saved < 5 then
        s = data:getString()
        love.filesystem.write("test"..tostring(saved)..".data", s)
    end
    saved = saved + 1]]
    return data
end

function melody.playsound(composer, pitch, length, rest)
    wait = wait or false
    if composer.source then
        composer.source:stop()
    end
    if not (composer.source and (composer.last.length == length) and (composer.last.pitch == pitch)) then
        composer.last.length = length
        composer.last.pitch = pitch
        local sample = generate_source(pitch, length)
        composer.source = love.audio.newSource(sample)
        composer.source:setVolume(music.volume)
        composer.source:setLooping(false)
    end
    composer.source:play()
    --delay(length) --just trying
    while composer.source:isPlaying() do
        --oh no
    end

    if rest > 0 then
        delay(rest)
    end
end