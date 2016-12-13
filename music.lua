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
    if music.background then
        local args = {...}
        if #args == 0 then
            error("No notes?!")
        end

        local thread_body = [[require("basic.music")
            require("love.sound")
            require("love.audio")
            melody.play([[
        ]]


        for i, n in ipairs(args) do
            if i > 1 then
                thread_body = thread_body .. ", [["
            end
            thread_body = thread_body .. n .. "]]"
        end
        thread_body = thread_body .. ')'

        print(thread_body)

        music.thread = love.thread.newThread(thread_body)
        music.thread:start()
    else
        melody.play(...)
    end
    source = melody --temporary, i will make object for it
end

---------------------------------------------
-- Example: channel:generate(440, 0.1)    --
---------------------------------------------
--generate((freq, seconds)
--generate sample waveform

--saved = 1

function generate_sample(pitch, length, rest, tie)
    local rate = 22050 --44100 --22050
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
--    if saved < 5 then
--        s = data:getString()
--        love.filesystem.write("test"..tostring(saved)..".data", s)
--    end
--    saved = saved + 1
    return data
end

function melody.playsound(channel, pitch, length, rest, tie, wait)

    if channel.source then
--        if channel.source:isPlaying() then
--            error("it is playing, please wait")
--        end
        channel.source:stop()
    end

    if not (channel.source and channel.last and (channel.last.length == length) and (channel.last.pitch == pitch) and (channel.last.rest == rest) and (channel.last.tie == tie)) then
        local sample = generate_sample(pitch, length, rest, tie)
        channel.last = {}
        channel.last.pitch = pitch
        channel.last.length = length
        channel.last.rest = rest
        channel.last.tie = tie
        channel.source = love.audio.newSource(sample)
        channel.source:setLooping(false)
        channel.source:setVolume(channel.volume)
        channel.source:play()
    else
        channel.source:seek(0)
        channel.source:setVolume(channel.volume)
        channel.source:play()
    end

    if wait then
        while channel.source:isPlaying() do
            --oh we need to wait it
        end
    end
end