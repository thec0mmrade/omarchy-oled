// OLED glow + faint scanlines
// Subtle cyan-tinted bloom around bright text on dark background
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 texel = 1.0 / iResolution.xy;

    // Sample the current pixel
    vec4 current = texture(iChannel0, uv);
    float cur_lum = dot(current.rgb, vec3(0.299, 0.587, 0.114));

    // --- Cyan bloom (bright text bleeds outward on dark background) ---
    float bloom = 0.0;
    const float BLOOM_RADIUS = 3.0;
    for (float dx = -BLOOM_RADIUS; dx <= BLOOM_RADIUS; dx += 1.0) {
        for (float dy = -BLOOM_RADIUS; dy <= BLOOM_RADIUS; dy += 1.0) {
            if (dx == 0.0 && dy == 0.0) continue;

            vec4 neighbor = texture(iChannel0, uv + texel * vec2(dx, dy));
            float n_lum = dot(neighbor.rgb, vec3(0.299, 0.587, 0.114));

            // Bloom where neighbor is bright (text) and current is dark (background)
            float mask = smoothstep(0.3, 0.6, n_lum) * smoothstep(0.3, 0.1, cur_lum);

            // Fade with distance
            float dist = length(vec2(dx, dy)) / BLOOM_RADIUS;
            float falloff = 1.0 - dist;
            bloom = max(bloom, mask * falloff);
        }
    }

    // Cyan-tinted glow color
    vec3 glow_color = vec3(0.0, 0.83, 1.0); // #00D4FF
    vec3 result = current.rgb;
    result = mix(result, glow_color, bloom * 0.15); // subtle bloom

    // --- Faint scanlines ---
    float scanline = sin(fragCoord.y * 3.14159) * 0.5 + 0.5;
    result *= mix(1.0, 0.97, scanline); // very faint darkening on odd lines

    fragColor = vec4(result, current.a);
}
