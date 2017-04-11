-------------------------------------------------------------------------------
--	Music and Audio lib
--  https://en.wikipedia.org/wiki/Music_Macro_Language
--  This file is part of the "Tyro"
--
--  @license   The MIT License (MIT) Included in this distribution
--  @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------
require("tyro.melody")
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
    waveform = "piano" --default waveform
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
    melody.playsound({pitch = 440, length = 0.2})
end

function music.play(...)
    if music.busy() then
        error("Music is busy!")
    end

    local args

    if type(...) == "table" then
        args = ...
    else
        args = {...}
    end

    if music.background then

        music.source = {
        }

        local thread_body = [[require("tyro.music")
            require("love.sound")
            require("love.audio")]]..
            'music.waveform = "' .. music.waveform .. '"' ..
            [[melody_events = love.thread.getChannel("melody")
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
        melody.play(args)
    end
end

--save_file = true
--save_sample = 5 --count of samples to save to love dir

--ref: http://www.topherlee.com/software/pcm-tut-wavformat.html
-- melody.playsound{ channel, pitch, length, rest, connected, volume, wait }

function melody.playsound(sound)

    local function generate_sample()
        local rate =  sound.rate or 44100 --22050
        local amplitude = sound.amplitude or 1 --not sure, i added it by my hand :P
        local data = love.sound.newSoundData((sound.length + sound.rest) * rate, rate, 16, 1) --rest keep it empty
        local samples = sound.length * rate
        local sample = 0
        local c = 2 * math.pi * sound.pitch / rate

        if sound.pitch > 0 then
            for index = 0, samples - 1 do
                if sound.waveform then
                    sample = sound.waveform(index, samples, sound.pitch, rate, sound.connected) * amplitude
                else
                    --to keep it simple to understand: sample = math.sin((index * pitch) * ((2 * math.pi) / rate)) * amplitude
                    sample = math.sin(index * c) * amplitude
                end
                data:setSample(index, sample) --bug in miniedit, put cursor on data and ctrl+f it now show "data"
            end
        end

        if save_file then
            if not wave_file then
                wave_file = love.filesystem.newFile("song.wav")
                wave_file:open("a")
            end
            if sound.id == 1 then --only first channel
                s = data:getString()
                wave_file:write(s)
            end

            if save_sample and (save_sample >= 1) then
                save_index = 1 + (save_index or 0)
                s = data:getString()
                love.filesystem.write("test"..tostring(save_index)..".data", s)
                print("sample saved" ,  save_sample)
                save_sample = save_sample - 1
            end
        end
        return data
    end

    if sound.source and sound.source:isPlaying() then
        sound.source:stop()
    end

    if not (sound.source and sound.last and (sound.last.length == sound.length) and (sound.last.pitch == sound.pitch) and (sound.last.rest == sound.rest) and (sound.last.connected == sound.connected)) then
        local sample = generate_sample(sound.pitch, sound.length, sound.rest, sound.connected)
        sound.last = {}
        sound.last.pitch = sound.pitch
        sound.last.length = sound.length
        sound.last.rest = sound.rest
        sound.last.connected = sound.connected
        sound.source = love.audio.newSource(sample)
        sound.source:setLooping(false)
    else
        sound.source:rewind() --better than seek(0)
    end
    sound.source:setVolume(sound.volume / 100)
    if not sound.source:isPlaying() then
        sound.source:play()
    end

    if wait then
        while sound.source:isPlaying() do
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