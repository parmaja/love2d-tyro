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

function music.play(notes)
end

function music.stop(all)
    if music.source then
        music.source:stop()
        music.source = nil
    end
end