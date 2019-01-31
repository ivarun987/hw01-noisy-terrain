#version 300 es


uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;

out vec3 fs_Pos;
out vec4 fs_Nor;
out vec4 fs_Col;

out vec4 fs_LightVec;
out float elevation;
out float moisture;
out float ocean_floor;

const vec4 lightPos = vec4(1.0, 2.0, 1.0, 1.0);

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


void main()
{
  ocean_floor = .5;
  vec2 seed_elevation = vec2(1420.0, 659.0);
  vec2 seed_moisture = vec2(6626.0, 442.0);
  vec2 elevation_input = vec2(vs_Pos.x + u_PlanePos.x, vs_Pos.z + u_PlanePos.y)/11.0;
  elevation = fbm(elevation_input.x, elevation_input.y, seed_elevation);
//  float offset = 1.3;
//  elevation = offset - abs(elevation);
//  elevation = elevation * elevation;

  moisture = fbm(vs_Pos.x + u_PlanePos.x, vs_Pos.z + u_PlanePos.y, seed_moisture);
  fs_Pos = vec3(vs_Pos.x, elevation, vs_Pos.z);
  //float fs_Sine = (cos((vs_Pos.x + u_PlanePos.x) * 3.14159 * 0.1) + cos((vs_Pos.z + u_PlanePos.y) * 3.14159 * 0.1));
  //elevation = float(round(elevation * 12.5)) / 12.5;

  float exp = 5.0;
  elevation = pow(elevation, exp);
  // elevation = smoothstep(0.4,0.6,elevation);

//  if (elevation < ocean_floor) {
//    elevation = ocean_floor;
//ww  }

  vec4 modelposition = vec4(vs_Pos.x, elevation * 2.0, vs_Pos.z, 1.0);
  modelposition = u_Model * modelposition;
  mat3 invTranspose = mat3(u_ModelInvTr);
  fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0.0);
  fs_LightVec = lightPos - modelposition;
  gl_Position = u_ViewProj * modelposition;
}
