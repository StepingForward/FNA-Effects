#include"common.fxh"

sampler s0;

float2 resolution; // Render resolution
float time; // Some time variable(frame in my case) that simulates time
float scale = 1.0f; 

float3 lerp_colors[3]; // Used for the first effect as the colors to change between

float seed = 3452.1234234; // Random seed for the first effect

bool type[4] = { false, false, false, true }; // Types

float4 mainImage(float4 fragCoord : SV_Position, float2 uv : TEXCOORD0) : COLOR0
{
    if (type[0]) // Clouds
    {
        float4 fragColor;
    
        float2 uv = fragCoord.xy / resolution.y * scale;
    
        float Pixels = 1024.0;
        float dx = 10.0 * (1.0 / Pixels);
        float dy = 10.0 * (1.0 / Pixels);
  
        float2 Coord = float2(dx * floor(uv.x / dx),
                          dy * floor(uv.y / dy));
        float2 motion = float2(fbm(Coord + time * 0.05f, seed), fbm(Coord + time * 0.05f, seed));

        float final = fbm(Coord + motion, 0);
    
        //fragColor = float4(mix(lerp_colors[0] * 0.5f, lerp_colors[1] * 0.5f + lerp_colors[2] * 0.5f, final), 1);
        fragColor = float4(mix(float3(-0.5f, -0.5f, -0.5f), float3(0.5, 0.5f, 0.5f) + float3(0.9f, 0.9f, 0.9f), final), 1);
    
        return fragColor;
    }
    else if (type[1]) // Square pattern
    {
        float scale = 20.0;
    
        float2 offset = float2(sin(time * 0.5), cos(time * 0.5)) * 0.2;
    
        float2 gridUV = frac((uv + offset) * scale);
    
        float lineWidth = 0.1;
        float square = step(lineWidth, gridUV.x) * step(lineWidth, gridUV.y);

        square *= step(gridUV.x, 1.0 - lineWidth) * step(gridUV.y, 1.0 - lineWidth);
    
        return float4(square, square, square, 1.0);
    }
    else // Other squares
    {
        float scale = 50.0;
    
        float angle = time * 0.1;
        float2x2 rotationMatrix = float2x2(
            cos(angle), -sin(angle),
            sin(angle), cos(angle)
        );
    
        float2 offset = float2(sin(time * 0.5), cos(time * 0.5)) * 0.1;
    
        float2 rotatedUV = mul(rotationMatrix, (uv - 0.5)) + 0.5;
    
        float2 gridUV = floor((rotatedUV + offset) * scale);
        float checker = 0.0f;
        if (type[2]) // Checkerboard squares
        {
            checker = fbm(gridUV.x + gridUV.y, 2.0);
        }
        else // Wavy squares
        {
            checker = fmod(gridUV.x + gridUV.y, 2.0);
        }
        float4 color1 = float4(mix(float3(0.2, 0.1, 0.3), float3(0.4, 0.2, 0.5) + float3(0.5, 0.4, 0.7), checker), 1.0);
        float4 color2 = float4(mix(float3(0.3, 0.0, 0.0), float3(0.5, 0.2, 0.4) + float3(0.7, 0.4, 0.4), checker), 1.0);
    
        return lerp(color1, color2, checker);
    }
}

technique Background
{
    pass Pass1
    {
        PixelShader = compile ps_3_0 mainImage();
    }
}