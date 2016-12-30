-------------------------------------------------------------------------------
--	Music Macro Language
--  https://en.wikipedia.org/wiki/Music_Macro_Language
--
--  This file is used part of the "Lua LOVE Basic"
--  @license   The MIT License (MIT) Included in this distribution
--  @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------
--  Look at this site, it have many of songs
--	https://archeagemmllibrary.com/
--	usefull refereces
--
--  http://web.mit.edu/18.06/www/Essays/linear-algebra-and-music.pdf
-------------------------------------------------------------------------------

melody = {
    waveforms = {}
}

waveforms_mt = {
    items = {}
}

waveforms_mt.__index =
    function(self, key)
        if type(key) == "number" then
            return waveforms_mt.items[key]
        end
    end

waveforms_mt.__newindex =
    function(self, key, value)
        local count = #waveforms_mt.items + 1
        waveforms_mt.items[count] = value
        rawset(self, key, value)
    end

setmetatable(melody.waveforms, waveforms_mt)

function melody.error(ch, msg, line, column)
    msg = "[melody] " .. msg .." at: "

    if ch and ch.name then
        msg = msg .. ch.name .. ", "
    end

    if line then
        msg = msg .. tostring(line) .. ":" .. tostring(column)
    end
    error(msg)
end

function melody.addWaveform(name, waveform)
    if type(waveform) ~= "function" then
        melody.error(nil, "waveform should fucntion")
    end
    --melody.waveforms[#melody.waveforms + 1] = { name = name, waveform = waveform }
    melody.waveforms[name] = waveform
end

function melody.play(...)

    local args = {...}
    if #args == 0 then
        melody.error(nil, "No notes?!")
    end

    local channels = {
    }

    for i, n in ipairs(args) do
        if not n or #n == 0 then
            melody.error(nil, "No notes?!")
        end
        local ch = {
            volume = 100,
            source = nil,
            finished = false,
            name = "notdefined",
        }
        index = #channels + 1
        channels[index] = ch

        ch.name = "channel"..tostring(index)
        ch.prepare = mml_prepare
        ch.next = mml_next
        ch:prepare(n)
    end

    local index = 1
    local count = #channels
    local busy = false
    while true do
        ch = channels[index]
        if not ch.finished then
            --if ch.source and ch.source:isPlaying() then
            if ch.expired and (ch.expired > os.clock()) then
                busy = true
            elseif ch:next() then
                print(ch.name, "n, freq Hz, len ms, rest ms", ch.pos, ch.sound.pitch, math.floor(ch.sound.length * 100), math.floor(ch.sound.rest * 100))
                if ch.sound.tie then
                    ch.expired = os.clock() + ch.sound.length
                else
                    ch.expired = os.clock() + ch.sound.length + ch.sound.rest
                end
                if not melody.playsound(ch, ch.sound.pitch, ch.sound.length, ch.sound.rest, ch.sound.tie, false) then
                    break
                end
                busy = true
            else
                ch.finished = true
                ch.source = nil
            end
        end
        index = index + 1
        if index > count then
            index = 1
            if not busy then
                break
            else
                busy = false
            end
        end
    end
end

local function check(c, t)
    for k, v in pairs(t) do
        if c == v then
            return true
        end
    end
    return false
end

--		http://www.headchant.com/2011/11/01/sound-synthesis-with-love-part-ii-sine-waves/
--      https://stackoverflow.com/questions/11355353/how-can-i-convert-qbasic-play-commands-to-something-more-contemporary
--ref:  http://www.phy.mtu.edu/~suits/notefreqs.html
-- 		http://wiki.mabinogiworld.com/view/User:LexisMikaya/MML_101_Guide
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

--Constants values

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

local baseNumber = 2 ^ (1/12)
local baseOctave = 4
local baseNoteC4 = 261.63
local baseNote = 39
local baseLength = 4
local baseTempo  = 60

function mml_prepare(self, notes)
    self.notes = notes:lower()

    --Current values by default
    self.tempo = 120
    self.octave = 4
    self.shift_octave = 0
    self.waveform = melody.waveforms[music.waveform] --first and default waveform
    self.length = 4 --note length
    self.subsequent = 0 -- 0 = legato 1 = normal 2 = staccato

    self.line = 1 --line for error messages
    self.pos = 1

    if (self.pos <= #self.notes) then
        self.chr = self.notes:sub(self.pos, self.pos)
    end
end

function mml_next(self)
    --playnote(char, number[-1,0,+1], number[1..16], number[1..2])
    --playnote("c#", 1, 0, 0)
    --playnote("r", 1)
    --playnote(20, 1) --by number
    local function playnote(note, duration, offset, increase, tie)
        increase = increase or 0
        offset = offset or 0
        local f = 0
        if note == "r" or note == "p" then
            f = 0
        elseif type(note) =="number" then
            index = note
            f = math.floor((baseNote + self.shift_octave) * (baseNumber ^ index))
        else
            local index = scores[note]
            if not index then
                melody:error("We dont have it in music:" .. note ,line, self.pos)
            end
            --calc index using current octave
            index = ((self.octave + self.shift_octave)- baseOctave) * 12 + index + offset
            f = math.floor(baseNoteC4 * (baseNumber ^ index))
        end
        --ref: https://music.stackexchange.com/questions/24140/how-can-i-find-the-length-in-seconds-of-a-quarter-note-crotchet-if-i-have-a-te
        --     http://www.sengpielaudio.com/calculator-bpmtempotime.htm
        --4 seconds for tempo = 60 beat per second, so what if tempo 120 and 2 for duration
        local l = (baseLength / duration) * (baseTempo / self.tempo) * (1 + increase);

        local r = 0   --legato
        if not tie then
            if self.subsequent == 1 then --normal
                r = l / 8
                l = l - r
            elseif self.subsequent == 2 then --staccato
                r = l / 4
                l = l - r
            end
        end
        self.sound = {pitch = f, length = l, rest = r, ["tie"] = tie}
        --now use it to play
        return true
    end


    local function reset()
        self.tempo = 120
        self.octave = 4
        self.shift_octave = 0
        self.waveform = melody.waveforms[music.waveform] --first and default waveform
        self.length = 4 --note length
        self.subsequent = 0 -- 0 = legato 1 = normal 2 = staccato
    end

    local function step()
        self.pos = self.pos + 1
        if (self.pos > #self.notes) then
            self.chr = nil
            return false
        else
            self.chr = self.notes:sub(self.pos, self.pos)
            return true
        end
    end

    local function restart()
        reset()
        self.line = 1 --line for error messages
        self.pos = 0 --zero because we do step()
        step()
    end

    local function scan_number(max)
        local r = ""
        while self.pos <= #self.notes do
            if (self.chr >= "0" and self.chr <= "9") or self.chr == "-" or self.chr=="+" then
                r = r .. self.chr
            else
                break
            end

            step()

            if max and #r >= max then
                break
            end
        end

        if #r > 0 then
            return tonumber(r)
        else
            return nil
        end
    end

    local function scan(t)
        local r = ""
        while self.pos <= #notes do
            if check(self.chr, t) then
                r = r .. self.chr
            else
                break
            end
            step()
        end
        return r
    end

    local function scan_to(chr)
        local r = ""
        while self.pos <= #self.notes do
            if self.chr == chr then
                step()
                break
            end
            r = r .. self.chr
            step()
        end
        return r
    end

    local function scan_eol()
        while self.pos <= #self.notes do
            if self.chr == "\n" then
                break
            end
            step()
        end
    end

    while self.pos <= #self.notes do
        if self.chr == "#" then
            step()
            scan_eol()
        elseif check(self.chr, {" ", "\t", "\r"}) then
            step()
        elseif self.chr == "\n" then
            self.line = self.line + 1 --line only for error messages
            step()
        elseif self.chr=="!" then
            reset()
            step()
        elseif self.chr >= "a" and self.chr <="g" then
            local note = self.chr
            step()

            if self.chr == "#" then
                note = note .. "#"
                step()
            end

            local offset = 0
            if self.chr == "+" then
                offset = 1
                step()
            elseif self.chr == "-" then
                offset = -1
                step()
            end

            local duration = scan_number() or self.length
            if duration > 96 then
                melody:error("Length should be less or equal 96: your length is: " .. tostring(duration), self.line, self.pos)
            end

            local increase = 0
            local by = 0.5
            if self.chr == "." then
                repeat
                    increase = increase + by --not sure about next dot
                    by = by / 2
                until not step() or self.chr ~= "."
            end

            local tie = false
            if self.chr == "&" then  --trying to use it, but i think i cant
                step()
                tie = true
            end

            return playnote(note, duration, offset, increase, tie)

        elseif self.chr == "n" then
            step()
            local number = scan_number(2)
            if number == nil then
                melody:error("'n' command need a number", self.line, self.pos)
            end
            return playnote(number, self.length)
        elseif self.chr == "q" then --by frequency
            step()
            local number = scan_number()
            if number == nil then
                melody:error("'q' command need a number", self.line, self.pos)
            end
            return playnote(number, self.length)
        elseif self.chr == "t" then
            step()
            self.tempo = scan_number()
        elseif self.chr == "l" then
            step()
            local l = scan_number()
            if l > 96 then
                melody:error("Length should be less or equal 96: your length is:" .. tostring(l), self.line, self.pos)
            end
            local increase = 0
            local by = 0.5
            if self.chr == "." then
                repeat
                    increase = increase + by --not sure about next dot
                    by = by / 2
                until not step() or self.chr ~= "."
            end

            self.length = l + increase

        elseif self.chr == "p" or self.chr == "r" then
            step()
            local duration = scan_number() or self.length
            local increase = 0
            local by = 0.5
            if self.chr == "." then
                repeat
                    increase = increase + by --not sure about next dot
                    by = by / 2
                until not step() or self.chr ~= "."
            end
            local tie = false
            if self.chr == "&" then  --trying to use it, but i think i cant
                step()
                tie = true
            end
            return playnote("r", duration, 0, increase, tie)
        elseif self.chr == "o" then
            step()
            self.octave = scan_number()
        elseif self.chr == ">" then
            step()
            local by = scan_number(1) or 1
            self.octave = self.octave + by
        elseif self.chr == "<" then
            step()
            local by = scan_number(1) or 1
            self.octave = self.octave - by
        elseif self.chr == "s" then --shift octave, special for compatibility with some devices
            step()
            local by = scan_number()
            if by then
                self.shift_octave = self.shift_octave + by
            else
                self.shift_octave = 0
            end
        elseif self.chr == "," then
            step()
            melody:error("command ',' not supported, it used to split song to multiple channels, use play(note1, note2)", self.line, self.pos)
        elseif self.chr == ";" then --stop
            step()
            return false --finish it
        elseif self.chr == "v" then --ignoring it
            step()
            self.volume = scan_number()
        elseif self.chr == "w" then --set a waveform
            step()
            if self.chr == "[" then
                step()
                local wf = scan_to("]") --by name
                self.waveform = melody.waveforms[wf]
                if not self.waveform then
                    melody:error("No waveform: " .. wf)
                end
            else
                local wf = scan_number()
                local f = melody.waveforms[wf]
                if not f then
                    melody:error("No waveform indexed for :"..tostring(wf), self.line, self.pos)
                end
                self.waveform = f
            end
        elseif self.chr == "m" then
            step()
            if self.chr == "l" then --legato
                step()
                self.subsequent = 0
            elseif self.chr == "n" then --normal
                step()
                self.subsequent = 1
            elseif self.chr == "s" then --staccato
                step()
                self.subsequent = 2
            elseif self.chr=="r" then --repeat it
                step()
                local number = scan_number() --todo
                restart(number)
            elseif self.chr=="x" then --exit
                step()
                return false
            elseif self.chr == "f" then --just for compatibility
                step()
            elseif self.chr == "b" then
                step()
            else
                step()
                melody:error("Illegal subcommand for M" .. self.chr, self.line, self.pos)
            end
        else
            melody:error("Can not recognize: " .. self.chr, self.line, self.pos)
        end
    end
end

function waveform_normal(index, samples, pitch, rate, tie)
    return math.sin((index * pitch) * ((2 * math.pi) / rate))
end

function waveform_piano(index, samples, pitch, rate, tie)
    --https://stackoverflow.com/questions/20037947/fade-out-function-of-audio-between-samplerate-changes
    local fade = 1
    if not tie then
        fade = math.exp(-math.log(50) * index / samples / 3) --fadeout
    end
    local sample  = math.sin(index * (2 * math.pi) * pitch / rate)
    local a = math.sin(index * (2 * math.pi) * pitch * 2 / rate) / 2
    local b = math.sin(index * (2 * math.pi) * pitch / 2 / rate) / 2
    local sample = (sample - a - b) / 2 --2 not 3 cuz we divided a and b with 2
    return sample * fade
end

function waveform_ramp(index, samples, pitch, rate, tie)
    wl = rate / pitch
    sample = (index % wl) / wl
    return sample
end

function waveform_triangle(index, samples, pitch, rate, tie)
    wl = rate / pitch
    i = math.floor(index % wl)
    if i < (wl) then
        sample = (i * 2) / wl
    else
        sample = ((wl - i) * 2) / wl
    end
    return sample
end

function waveform_square(index, samples, pitch, rate, tie)
    wl = rate / pitch
    i = math.floor(index % wl)
    if i < (wl / 2) then
        sample = 1
    else
        sample = -1
    end
    return sample
end

function waveform_random(index, samples, pitch, rate, tie)
    wl = rate / pitch
       sample = (math.random(wl * 2) - wl) / wl
    return sample
end

function waveform_organ(index, samples, pitch, rate, tie)
    local sample  = math.sin(index * (2 * math.pi) * pitch / rate)
    if math.abs(sample) > 0.5 then
        a = math.sin(index * (2 * math.pi) * pitch / 3 / rate) / 2
        sample = (sample + a) / 2
    end
    return sample
end

function waveform_ss(index, samples, pitch, rate, tie)
    wl = rate / pitch * 2 --not sure the size
    i = math.floor(index % wl)
    if i <= (wl / 2) then
        a = 1
    else
        a = -1
    end

    local sample  = math.sin(index * (2 * math.pi) * pitch / rate ) / 10
    sample = (sample - a) / 2 --<-- 2 is wrong
    return sample
end

melody.addWaveform("normal", waveform_normal)
melody.addWaveform("piano", waveform_piano)
melody.addWaveform("organ", waveform_organ)
melody.addWaveform("ss", waveform_ss) --sin square
melody.addWaveform("ramp", waveform_ramp)
melody.addWaveform("triangle", waveform_triangle)
melody.addWaveform("square", waveform_square)
melody.addWaveform("random", waveform_random)