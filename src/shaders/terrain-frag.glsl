#version 300 es
precision highp float;

uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane

in vec3 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;

in float elevation;
in float moisture;
in float ocean_floor;
in vec4 fs_LightVec;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

float random1( vec2 p , vec2 seed) {
  return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453);
}

float random1( vec3 p , vec3 seed) {
  return fract(sin(dot(p + seed, vec3(987.654, 123.456, 531.975))) * 85734.3545);
}

vec2 random2( vec2 p , vec2 seed) {
  return fract(sin(vec2(dot(p + seed, vec2(311.7, 127.1)), dot(p + seed, vec2(269.5, 183.3)))) * 85734.3545);
}

float interp_noise_2D(float x, float y, vec2 seed) {
//  vec2 seed = vec2(420.0, 69.0);
  vec2 seed1 = vec2(2.0 * seed.x, 2.0 * seed.y);
  vec2 seed2 = vec2(4.0 * seed.x, 2.0 * seed.y);

  float intX = floor(x);
  float fractX = fract(x);
  float intY = floor(y);
  float fractY = fract(y);

  float v1 = random1(vec2(intX, intY), seed);
  float v2 = random1(vec2(intX + 1.0, intY), seed);
  float v3 = random1(vec2(intX, intY + 1.0), seed);
  float v4 = random1(vec2(intX + 1.0, intY + 1.0), seed);

  float i1 = mix(v1, v2, fractX);
  float i2 = mix(v3, v4, fractX);
  return mix(i1, i2, fractY);
}

float fbm(float x, float y, vec2 seed) {
  float total = 0.0;
  float persistence = 0.60;
  float octaves = 15.0;

  float total_freq = 0.0;

  for(float i = 0.0; i < octaves; i = i + 1.0) {
    float freq = pow(2.0, i);
    float amp = pow(persistence, i);
    float mult = 1.0 / pow(1.5, i);

    total_freq = total_freq + (1.0/freq);
    total = total + mult * interp_noise_2D(x * freq, y * freq, seed) * amp;
//    total = total + (1.0 / freq) * interp_noise_2D(x * freq, y * freq, seed) * amp;
//    total = total + interp_noise_2D(x * freq, y * freq, seed) * amp;
  }
  return total;
}

vec3 normalize_rgb(float r, float g, float b) {
  return vec3(r / 255.0, g / 255.0, b / 255.0);
}

// Generate biome color depending on elevation and moisture
vec3 biome(float e, float m, vec3 color, vec2 seed) {
  // Color Biomes to Use
  // vec3 DEEP_SEA = normalize_rgb(43.0, 56.0, 103.0);
  vec3 DEEP_SEA = mix(normalize_rgb(175.0, 199.0, 227.0), normalize_rgb(1.0,1.0,5.0), 0.3);
  // vec3 OCEAN = normalize_rgb(66.0, 68.0, 118.0);
  vec3 OCEAN = normalize_rgb(156.0, 186.0, 222.0);
  vec3 BEACH = normalize_rgb(158.0,145.0,122.0);
  vec3 SCORCHED = normalize_rgb(85.0,85.0,85.0);
  vec3 BARE = normalize_rgb(136.0,136.0,136.0);
  vec3 TUNDRA = normalize_rgb(188.0,188.0,173.0);
  vec3 SNOW = normalize_rgb(222.0, 222.0, 228.0);
  // vec3 DESERT = normalize_rgb(203.0, 209.0, 161.0);
  vec3 DESERT = normalize_rgb(216.0, 191.0, 216.0);
  // vec3 SHRUBLAND = normalize_rgb(139.0, 152.0, 122.0);
  vec3 SHRUBLAND = normalize_rgb(155.0, 0.0, 146.0);
  // vec3 TAIGA = normalize_rgb(156.0, 168.0, 124.0);
  vec3 TAIGA = normalize_rgb(123.0, 104.0, 238.0);
  // vec3 GRASSLAND = normalize_rgb(143.0, 169.0, 96.0);
  vec3 GRASSLAND = normalize_rgb(67.0, 34.0, 64.0);
  // vec3 DECIDUOUS_FOREST = normalize_rgb(113.0, 145.0, 95.0);
  vec3 DECIDUOUS_FOREST = normalize_rgb(114.0, 69.0, 106.0);
  // vec3 RAIN_FOREST = normalize_rgb(84.0, 134.0, 90.0);
  vec3 RAIN_FOREST = normalize_rgb(114.0, 69.0, 106.0);
  // vec3 SUBTROPICAL_DESERT = normalize_rgb(206.0, 185.0, 145.0);
  vec3 SUBTROPICAL_DESERT = normalize_rgb(255.0, 0.0, 255.0);
  // vec3 TROPICAL_FOREST = normalize_rgb(102.0, 150.0, 79.0);
  vec3 TROPICAL_FOREST = normalize_rgb(139.0, 0.0, 139.0);
  // vec3 TROPICAL_RAIN_FOREST = normalize_rgb(69.0, 117.0, 88.0);
  vec3 TROPICAL_RAIN_FOREST = normalize_rgb(75.0, 255.0, 130.0);

  float frac_rand = fract(fbm(m, e, seed) * m * pow(e, 0.5) * 43.45678 + smoothstep(0.4,0.6,e));

  // Color Biome Logic
  if (e <= ocean_floor * 0.70) return DEEP_SEA;
  if (e <= ocean_floor) return OCEAN;
  if (e <= ocean_floor * 1.2) return mix(BEACH, SUBTROPICAL_DESERT, frac_rand);

  if (e > ocean_floor * 2.5) {
    if (m < 0.50) return mix(SCORCHED, BARE, frac_rand);
    if (m < 1.00) return mix(
      mix(SCORCHED, BARE, frac_rand),
      mix(BARE, TUNDRA, frac_rand), frac_rand);
    if (m < 1.40) return mix(
      mix(BARE, TUNDRA, frac_rand),
      mix(TUNDRA, SNOW, frac_rand), frac_rand);
    return mix(TUNDRA, SNOW, frac_rand);
  }

  if (e > ocean_floor * 1.8) {
    if (m < 0.60) return mix(DESERT, SHRUBLAND, frac_rand);
    if (m < 1.50) return mix(
      mix(DESERT, SHRUBLAND, frac_rand),
      mix(SHRUBLAND, TAIGA, frac_rand), frac_rand);
    return mix(SHRUBLAND, TAIGA, frac_rand);
  }

  if (e > ocean_floor * 1.3) {
    if (m < 0.80) return mix(DESERT, GRASSLAND, frac_rand);
    if (m < 1.00) return mix(
      mix(DESERT, GRASSLAND, frac_rand),
      mix(GRASSLAND, DECIDUOUS_FOREST, frac_rand), frac_rand);
    if (m < 1.70) return mix(
      mix(GRASSLAND, DECIDUOUS_FOREST, frac_rand),
      mix(DECIDUOUS_FOREST, RAIN_FOREST, frac_rand), frac_rand);
    return mix(DECIDUOUS_FOREST, RAIN_FOREST, frac_rand);
  }

  if (m < 0.30) return mix(SUBTROPICAL_DESERT, GRASSLAND, frac_rand);
  if (m < 0.80) return mix(
    mix(SUBTROPICAL_DESERT, GRASSLAND, frac_rand),
    mix(GRASSLAND, TROPICAL_FOREST, frac_rand), frac_rand);
  if (m < 1.40) return mix(
    mix(GRASSLAND, TROPICAL_FOREST, frac_rand),
    mix(TROPICAL_FOREST, TROPICAL_RAIN_FOREST, frac_rand), frac_rand);
  return mix(TROPICAL_FOREST, TROPICAL_RAIN_FOREST, frac_rand);
}


void main() {
  vec2 color_seed = vec2(566.0, 420.69);
  float fog = clamp(smoothstep(40.0, 50.0, length(fs_Pos)), 0.0, 1.0); // Distance fog
  vec4 temp_Col = vec4(mix(
    vec3(0.5 * (elevation + 1.0)),
    vec3(164.0 / 255.0, 233.0 / 255.0, 1.0), fog), 0.5);
  //temp_Col = vec4(fs_Pos.xyz, 1.0);
  out_Col = vec4(mix(
    biome(elevation, moisture, temp_Col.xyz, color_seed),
    temp_Col.xyz,
    fog), 0.5);

  vec3 rand_col = vec3(
    fract(fbm(moisture, elevation, color_seed)),
    fract(fbm(pow(moisture,2.0), 1.0 - elevation, color_seed)),
    fract(fbm(1.0/moisture, pow(elevation, 0.5), color_seed)));
    // fract(fbm(435.67 * moisture, abs(elevation), color_seed)));

  float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
  float ambientTerm = 0.3;
  float lightIntensity = diffuseTerm + ambientTerm;

  out_Col = vec4(mix(
      rand_col,
      vec3(mix(
        out_Col.rgb * lightIntensity,
        vec3(164.0 / 255.0, 233.0 / 255.0, 1.0),
        fog)),
      0.8), out_Col.a);
//  out_Col = vec4(out_Col.rgb, out_Col.a);

}
