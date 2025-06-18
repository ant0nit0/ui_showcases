#include <flutter/runtime_effect.glsl>

uniform float progress;
uniform vec2 size;
uniform float waveSpeed;
uniform float waveIntensity;
uniform float waveFrequency;
uniform sampler2D image;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / size;
    
    // Calculate wave distortion using uniform parameters
    float wave = sin(uv.x * waveFrequency + progress * waveSpeed *6.28);
    vec2 distortedUV = uv + vec2(0.0, wave * waveIntensity);
    
    // Sample texture with proper coordinates
    vec4 color = texture(image, distortedUV);
    
    // Add lighting effect
    color.rgb *= 1.0 - 0.3 * abs(wave);
    
    fragColor = color;
}