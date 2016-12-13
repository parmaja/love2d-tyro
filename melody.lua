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
-------------------------------------------------------------------------------
melody = {
}

function melody.play(...)

    local args = {...}
    if #args == 0 then
        error("No notes?!")
    end
    local channels = {}
    for i, n in ipairs(args) do
        if not n or #n == 0 then
            error("No notes?!")
        end
        local ch = {
            source = nil,
            finished = false,
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
            if ch.source and ch.source:isPlaying() then
                busy = true
            elseif ch:next() then
                print(ch.name, "freq Hz, len ms, rest ms", ch.sound.pitch, math.floor(ch.sound.length * 100), math.floor(ch.sound.rest * 100))
                melody.playsound(ch, ch.sound.pitch, ch.sound.length, ch.sound.rest, false)
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

--ref:  http://www.qb64.net/wiki/index.php/PLAY
--		https://github.com/miko/Love2d-samples/blob/master/MikoIntroScreen/Intro.lua#L38
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
local baseLength = 4
local baseTempo  = 60

saved = 1

function mml_prepare(self, notes)
    self.notes = notes:lower()

    --Current values by default
    self.freq = 0

    self.tempo = 120
    self.octave = 4
    self.shift_octave = 0
    self.length = 4 --note length
    self.subsequent = 0 -- 0 = legato 1 = normal 2 = staccato

    self.line = 1 --line for error messages
    if self.notes:sub(1, 4) == "mml@" then
        self.pos = 5
    else
        self.pos = 1
    end

    if (self.pos <= #self.notes) then
        self.chr = self.notes:sub(self.pos, self.pos)
    end
end

function mml_next(self)

    --playnote(char, number[-1,0,+1], number[1..16], number[1..2])
    --playnote("c#", 1, 0, 0)
    --playnote("r", 1)
    --playnote(440, 1) --by number
    local function playnote(note, duration, offset, increase)
        increase = increase or 0
        offset = offset or 0
        local f = 0
        if note == "r" or note == "p" then
            f = 0
        elseif type(note) =="number" then
            f = note
        else
            local index = scores[note]
            if not index then
                error("We dont have it in music:" .. note .. " at "  .. tostring(line) .. ":" .. tostring(self.pos))
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

        if self.subsequent == 1 then --normal
            r = l / 8
            l = l - r
        elseif self.subsequent == 2 then --staccato
            r = l / 4
            l = l - r
        end
        self.sound = {pitch = f, length = l, rest = r}
        --now use it to play
        return true
    end

    local function reset()
        self.tempo = 120
        self.octave = 4
        self.length = 4 --note length
        self.subsequent = 0
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

    local function scan_eol()
        while self.pos <= #notes do
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
                error("Length should be less or equal 96: your length is: " .. tostring(duration)  .. " at " .. tostring(self.line) .. ":" .. tostring(self.pos))
            end

            local increase = 0
            local by = 0.5
            if self.chr == "." then
                repeat
                    increase = increase + by --not sure about next dot
                    by = by / 2
                until not step() or self.chr ~= "."
            end

            return playnote(note, duration, offset, increase)

        elseif self.chr == "n" then  --TODO: note index
            step()
            local number = scan_number(2)
            if number == nil then
                error("[music.play] F command need a umber at :"  .. " at " .. tostring(self.line) .. ":" .. tostring(self.pos))
            end
            --local index = calcIndex(number)
            --return playnote(index, duration)
        elseif self.chr == "q" then --by frequency
            step()
            local number = scan_number()
            if number == nil then
                error("[music.play] F command need a number at :"  .. " at " .. tostring(self.line) .. ":" .. tostring(self.pos))
            end
            return playnote(number, self.length)
        elseif self.chr == "t" then
            step()
            self.tempo = scan_number()
        elseif self.chr == "l" then
            step()
            local l = scan_number()
            if l > 96 then
                error("Length should be less or equal 96: your length is:" .. tostring(l) .. " at " .. tostring(self.line) .. ":" .. tostring(self.pos))
            end
            self.length = l
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
            return playnote("r", duration, 0, increase)
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
        elseif self.chr == "&" then --ignore it, can not support it
            step()
            --return playnote("r", 1, 0, 1)
        elseif self.chr == "," then --ignore it, can not support it
            step()
            --return playnote("r", 1, 0, 1)
        elseif self.chr == ";" then --ignore it, can not support it
            step()
            --return playnote("r", 1, 0, 1)
        elseif self.chr == "v" then --ignoring it
            step()
            self.volume = scan_number()
        elseif self.chr == "m" then
            step()
            if self.chr == "l" then --legato
                self.subsequent = 0
            elseif self.chr == "n" then --normal
                self.subsequent = 1
            elseif self.chr == "s" then --staccato
                self.subsequent = 2
            elseif self.chr == "f" then --just for compatibility
            elseif self.chr == "b" then
            else
                error("[music.play] Illegal subcommand for M" .. self.chr .. " at:" .. tostring(self.pos))
            end
            step()
        else
            error("[music.play] Can not recognize: " .. self.chr .. " at:" .. tostring(self.line) .. ":" .. tostring(self.pos))
        end
    end
end