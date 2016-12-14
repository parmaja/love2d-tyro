-------------------------------------------------------------------------------
--	Music and Audio lib
--  https://en.wikipedia.org/wiki/Music_Macro_Language
--  This file is part of the "Lua LOVE Basic"
--
--  @license   The MIT License (MIT) Included in this distribution
--  @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------
require("basic.melody")
-------------------------------------------------
-- source is an interface
-- source:play()
-- source:stop()
-- source:busy()
-------------------------------------------------
music = {
    loop = false,
    background, --TODO: play in background
    source = nil, --source can be a love sound source or melody or anything else
    volume = 50,
    waveform = 2 --default waveform, piano
}

function music.start()
    if music.source then
        music.source:play()
    end
end

function music.stop()
    if music.source then
        music.source:stop()
        music.source = nil
    end
end

function music.busy()
    if music.source then
        if music.source:busy() then
            return true
        else
            music.source = nil --bad
        end
    end
      return false
end

function music.beep()
    melody.playsound(440, 0.2)
end

function music.play(...)
    if music.busy() then
        error("Music is busy!")
    end
    music.source = {
    }

    if music.background then
        local args = {...}
        if #args == 0 then
            error("No notes?!")
        end

        local thread_body = [[require("basic.music")
            require("love.sound")
            require("love.audio")
            melody_events = love.thread.getChannel("melody")
            melody.play([[
        ]]


        for i, n in ipairs(args) do
            if i > 1 then
                thread_body = thread_body .. ", [["
            end
            thread_body = thread_body .. n .. "]]"
        end
        thread_body = thread_body .. ')'


        music.source = {
            thread = love.thread.newThread(thread_body),
            events = love.thread.getChannel("melody"),
        }

        function music.source:stop()
            music.source.events:push("stop")
            music.source.thread:wait()
        end

        function music.source:busy()
            if music.source.thread:isRunning() then
                return true
            end
            return false
        end

        music.source.thread:start()
    else
        melody.play(...)
    end
end

function melody.playsound(channel, pitch, length, rest, tie, wait)

--saved = 1

    local function generate_sample()
        local rate = 44100 --22050
        local amplitude = 1 --not sure, i added it by my hand :P
        local data = love.sound.newSoundData((length + rest) * rate, rate, 16, 1) --rest keep it empty
        local samples = length * rate
        local sample = 0
        local c = 2 * math.pi * pitch / rate

        if pitch > 0 then
            for index = 0, samples - 1 do
                if channel.waveform then
                    sample = channel.waveform(index, samples, pitch, rate, tie) * amplitude
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
        channel.source:rewind() --better than seek(0)
        channel.source:setVolume(channel.volume)
        channel.source:play()
    end

    if wait then
        while channel.source:isPlaying() do
            --oh we need to wait it
        end
    end
    --melody_events
    if melody_events and (melody_events:getCount() > 0) then
        --return false if thread terminated
        local cmd = string.lower(melody_events:pop())
        if cmd == "stop" then
            return false
        else
            return true
        end
    else
        return true
    end
end