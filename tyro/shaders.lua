-------------------------------------------------------------------------------
--  This file is part of the "Tyro"
--
--   @license   The MIT License (MIT) Included in this distribution
--   @author    Zaher Dirkey <zaherdirkey at yahoo dot com>
-------------------------------------------------------------------------------

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


--[[
    love.graphics.setBackgroundColor( 55, 55, 55 )

    lg = {			-- looking_glass params
        x		= 0.5,
        y		= 0.5,
        size	= 0.15,
        mag		= 2.0,
        fog		= 0.1,
        }

    for i,j in pairs(lg) do
        shader:send(i,j)
    end

]]

glass_glsl = [[
        extern float x;
        extern float y;
        extern float size;
        extern float mag;
        extern float fog;
        vec4 effect(vec4 global_color, Image texture, vec2 tc, vec2 pc )
        {
            vec4 pixel;
            float root = sqrt((x-tc.x) * (x-tc.x) + (y-tc.y) * (y-tc.y));
            if (root <= size) {
                pixel = Texel(texture, vec2( x-(x-tc.x)/mag, y-(y-tc.y)/mag) );
            }
            else {
                pixel = Texel(texture, vec2( tc.x, tc.y ) );pixel.a = fog;
            }
            return pixel;
        }
    ]]