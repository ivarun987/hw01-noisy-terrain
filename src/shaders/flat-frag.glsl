#version 300 es
precision highp float;

// The fragment shader used to render the background of the scene
// Modify this to make your background more interesting

in vec3 fs_Pos;

out vec4 out_Col;

uniform sampler2D glow;
uniform sampler2D color;

float random1( vec2 p , vec2 seed) {
  return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453);
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
  }
  return total;
}

// taken from https://stackoverflow.com/questions/17596393/glsl-es-fragment-shader-produces-very-different-results-on-different-devices
highp float rando(vec2 co) {
  highp float a = 1e3;
  highp float b = 1e-3;
  highp float c = 1e5;
  return fract(sin((co.x + co.y * a) * b) * c);
}


void main() {
  vec3 V = normalize(fs_Pos);
  vec3 L = normalize(vec3(0.0, 40.0, 0.0));

  // Compute the proximity of this fragment to the sun.
  float vl = dot(V, L);

  // Look up the sky color and glow colors.
  // vec4 Kc = texture2D(color, vec2((L.y + 1.0) / 2.0, V.y));
  // vec4 Kg = texture2D(glow,  vec2((L.y + 1.0) / 2.0, vl));

  // out_Col = vec4(Kc.rgb + Kg.rgb * Kg.a / 2.0, Kc.a);
  // vec3 L = normalize()

  vec2 color_seed = vec2(410.0, 71.0);
  out_Col = vec4(
      fbm(fs_Pos.x, fs_Pos.y, color_seed),
      fbm(fs_Pos.y, fs_Pos.z, color_seed),
      fbm(fs_Pos.x, fs_Pos.z, color_seed),
      1.0
  );

  // generate procedurally generated stars!
  float color = 0.0;
  highp float starValue = rando(fs_Pos.xy);
  float prob = 0.5;
  float size = 15.0;
  if (starValue > prob) {
    vec2 center = size * fs_Pos.xy + vec2(size, size) * 0.5;
    float xy_dist = abs(fs_Pos.x - center.x) * abs(fs_Pos.y - center.y) / 5.0;
    color = 0.6 - distance(fs_Pos.xy, center.xy) / (0.5 * size) * xy_dist;
  }

  out_Col = mix(
    vec4(164.0 / 255.0, 233.0 / 255.0, 1.0, 1.0),
    out_Col, 0.5);


  if (starValue < prob) {
    out_Col = out_Col;
  } else {
    float starIntensity = fract(100.0 * starValue);
    out_Col = mix(
      out_Col, vec4(1.0, 1.0, 1.0, 0.85), 0.7);
  }
}
