-----------------------------------------------------
-- Colors
-----------------------------------------------------

colors = {
    count = 0 --deprecated, on lua 5.2 we can use #colors, but LOVE still at 5.1
}

colors_mt = {
    items = {}
}

colors_mt.__index =
    function(self, key)
        if type(key) == "number" then
            return colors_mt.items[key]
        end
    end

colors_mt.__newindex =
    function(self, key, value)
        self.count = #colors_mt.items + 1
        colors_mt.items[self.count] = value
        rawset(self, key, value)
    end

colors_mt.__len =  --need >lua5.2
    function(self)
        return #colors_mt.items
    end

setmetatable(colors, colors_mt)

colors.Black  = {0, 0 , 0}
colors.Violet = {148, 0, 211}
colors.Indigo = {75, 0, 130}
colors.Blue   = {0, 0, 255}
colors.Green  = {0, 255, 0}
colors.Yellow = {255, 255, 0}
colors.Orange = {255, 127, 0}
colors.Red    = {255, 0, 0}
colors.White  = {255,255,255}

colors.Pink   = {255,84,167}

-------------------------------------
-- Shaders
-------------------------------------

glow_glsl = [[// adapted from http://www.youtube.com/watch?v=qNM0k522R7o
extern vec2 size = vec2(0.1, 0.1);
extern int samples = 4; // pixels per axis; higher = bigger glow, worse performance
extern float quality = 0.1; // lower = smaller glow, better quality

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 window_coords)
{
  vec4 source = Texel(texture, texture_coords);
  vec4 sum = vec4(0) ;
  int diff = (samples - 1) / 2 + 1;
  vec2 sizeFactor = vec2(1) / size * quality;

  for (int x = -diff; x <= diff; x++)
  {
    for (int y = -diff; y <= diff; y++)
    {
      vec2 offset = vec2(x, y) * sizeFactor;
      sum += Texel(texture, texture_coords + offset);
    }
  }

  return ((sum / (samples * samples)) + source) * color;
}]]


--ref: https://github.com/AnisB/OpenGLShaders/blob/master/shaders/backlightshader.glsl

spotlight_glsl=[[
extern vec3 light_pos;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {

   // Récupération de la Diffuse
   vec4 diffuse  = Texel(texture, texture_coords);


   //Définition de la direction de la lumière
   vec3 light_direction = light_pos - vec3(pixel_coords, 0);

   // Récupération de la distance par rapport à l'objet (Norme du vecteur)
   float light_distance = length(light_direction);

   // Formule pour l'atténuation
   float attenuation = 70/sqrt(pow(light_distance, 2));

   // Norme du vecteur d'attenuation
   light_direction = normalize(light_direction);

   //Caulcul de la valeur de l'illumination pour un point donné
   float light = clamp(attenuation , 0.0, 1.0);

   // Ombrage
   float cel_light =smoothstep(0.30, 0.52, light) * 0.6 + 0.4;

   return vec4(cel_light* diffuse.rgb, diffuse.a);
}
]]

glsl_dt = [[
    extern number time;
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
    {
        return vec4((1.0+sin(time))/2.0, abs(cos(time)), abs(sin(time)), 1.0);
    }
]]