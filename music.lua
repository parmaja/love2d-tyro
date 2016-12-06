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

local function makeSample(length, pitch)
  length = length or 0.1
  pitch = pitch or 440
  local overtime = 1.5
  local tick = love.sound.newSoundData(overtime * length * 44100, 44100, 16, 1)
  for i = 0, length * 44100 * overtime - 1 do
      local sample = math.sin((i * pitch * math.pi * 2) / 44100) * length
      tick:setSample(i, sample)
  end
  return tick
end

function music.sound(length, pitch)
    local sample = makeSample(length, pitch)
    music.source = love.audio.newSource(sample)
    music.source:setVolume(music.volume)
    music.source:setLooping(true)
    music.source:play()
end

local function parse(notes)
    result = {
    }
    local freq = 0
    local tempo = 0
    local octave = 0
    local length = 0

    local i = 1

    local c = ""
    local p = 0

    local function check(c, t)
        for k, v in pairs(t) do
            if c == v then
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
            c = notes:sub(p, p)
            return true
        end
    end

    local function scan_number()
        local r = ""
        while next() do
            if c >= "1" and c <= "9" then
                r = r .. c
            else
                break
            end
        end
        print(r)
        return tonumber(r)
    end

    local function scan(t)
        local r = ""
        while next() do
            if check(c, t) then
                r = r .. c
            else
                break
            end
        end
        return r
    end

    next()
    while p <= #notes do
        if check(c, {" ", "\n", "\t"}) then
            next()
        elseif c=="!" then
            reset()
            next()
        elseif c >= "a" and c <="g" then
            local s = c .. scan{"#", "+", "-"}
            print("note:", s)
            freq = scan_number()
            print("freq", freq)
        elseif c == "t" then
            tempo = scan_number()
            print("tempo:", tempo)
        elseif c == "p" then
            pause = scan_number()
            print("pause:", pause)
        elseif c == "o" then
            octave = scan_number()
            print("octave:", octave)
        elseif c == "<" then
            octave = octave + 1
            next()
        elseif c == ">" then
            result.octave = result.octave - 1
            next()
        else
            next()
        end
    end
end

function music.play(notes)
end

function music.stop(all)
    if music.source then
        music.source:stop()
        music.source = nil
    end
end

print "test parser"
parse("a#4b10c50d#e+f-g")
print ""
--parse("mfl16t155o2mnb4p8msbbmnb4p8msbbb8g#8e8g#8b8g#8b8o3e8o2b8g#8e8g#8")
