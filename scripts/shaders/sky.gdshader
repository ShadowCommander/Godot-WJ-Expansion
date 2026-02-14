shader_type sky;

uniform vec3 deep_space : source_color = vec3(0.01, 0.01, 0.01);
uniform vec3 horizon_space : source_color = vec3(0.01, 0.01, 0.01);
uniform vec3 nebula_tint : source_color = vec3(0.01, 0.01, 0.01);
uniform float star_amount : hint_range(0.0, 1.0) = 0.4;
uniform float nebula_strength : hint_range(0.0, 1.0) = 0.3;

vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(hash(i + vec2(0.0, 0.0)).x, hash(i + vec2(1.0, 0.0)).x, f.x),
               mix(hash(i + vec2(0.0, 1.0)).x, hash(i + vec2(1.0, 1.0)).x, f.x), f.y);
}

float stars(vec2 uv) {
    vec2 grid = floor(uv * 200.0);
    vec2 rnd = hash(grid);
    
    if (rnd.x > star_amount) return 0.0;
    
    vec2 pos = fract(uv * 200.0);
    vec2 center = rnd;
    float dist = length(pos - center);
    
    return smoothstep(0.02, 0.0, dist) * (0.5 + rnd.y * 0.5);
}

void sky() {
    vec3 dir = normalize(EYEDIR);
    vec2 uv = vec2(atan(dir.x, dir.z), acos(dir.y));
    
    float horizon = smoothstep(-0.2, 0.8, dir.y);
    vec3 base = mix(deep_space, horizon_space, horizon);
    
    float nebula = noise(uv * 3.0) * noise(uv * 6.0) * 0.5;
    nebula = smoothstep(0.1, 0.7, nebula);
    
    vec3 final_color = mix(base, nebula_tint, nebula * nebula_strength);
    final_color += stars(uv) * vec3(1.0, 0.9, 0.8);
    
    COLOR = final_color;
}