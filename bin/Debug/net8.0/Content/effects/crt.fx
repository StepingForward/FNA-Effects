float time;

float distortion = 0.01; // Strength of barrel distortion
float scanlineIntensity = 0.1; // Darkness of scanlines
float aberrationAmount = 0.0; // Chromatic aberration shift
float scanlineFrequency = 100.0; // Scanline frequency

float distortionFactor = 0.009f; // Distortion "power"
float riseFactor = 15; // Distortion movement

bool waterDistortion = false;
bool heatDistortion = false;

sampler2D ScreenTexture : register(s0);

texture distortionTexture; // In this case I use water.png
sampler2D distortionTextureSampler = sampler_state
{
    Texture = <distortionTexture>;
    AddressU = Wrap;
    AddressV = Wrap;
};

float2 BarrelDistortion(float2 uv, float distortion)
{
    uv = uv * 2.0 - 1.0;
    float r2 = dot(uv, uv);
    uv *= 1.0 + distortion * r2;
    uv = (uv + 1.0) * 0.5;
    return uv;
}

float4 CRT_Shader(float2 uv : TEXCOORD0) : COLOR0
{
    float3 color = float3(1, 1, 1);
    
    if (waterDistortion)
    {
        float2 distortionUV = uv;
        distortionUV.x -= sin(time) * riseFactor;
    
        float2 distortionMapValue = tex2D(distortionTextureSampler, distortionUV).xy;
    
        float2 distortionPositionOffset = distortionMapValue;
        distortionMapValue = ((distortionMapValue * 2.0) - 1.0);
    
        distortionMapValue *= distortionFactor;
    
        distortionMapValue *= (uv.x);
    
        uv = BarrelDistortion(uv, distortion);
    
        if (uv.x < 0 || uv.x > 1 || uv.y < 0 || uv.y > 1)
            return float4(0, 0, 0, 1);
    
        float r = tex2D(ScreenTexture, uv + float2(aberrationAmount, 0) + distortionMapValue).r;
        float g = tex2D(ScreenTexture, uv + distortionMapValue).g;
        float b = tex2D(ScreenTexture, uv - float2(aberrationAmount, 0) + distortionMapValue).b;

        color = float3(min(r, r - 0.01), min(g, g - 0.01), max(b, b + 0.1));
    } //Draw with water distortion
    else if (heatDistortion)
    {
        float2 distortionUV = uv;
        distortionUV.y -= sin(time) * -riseFactor;
    
        float2 distortionMapValue = tex2D(distortionTextureSampler, distortionUV).xy;
    
        float2 distortionPositionOffset = distortionMapValue;
        distortionMapValue = ((distortionMapValue * 2.0) - 1.0);
    
        distortionMapValue *= distortionFactor;
    
        distortionMapValue *= (uv.y);
    
        uv = BarrelDistortion(uv, distortion);
    
        if (uv.x < 0 || uv.x > 1 || uv.y < 0 || uv.y > 1)
            return float4(0, 0, 0, 1);
    
        float r = tex2D(ScreenTexture, uv + float2(aberrationAmount, 0) + distortionMapValue).r;
        float g = tex2D(ScreenTexture, uv + distortionMapValue).g;
        float b = tex2D(ScreenTexture, uv - float2(aberrationAmount, 0) + distortionMapValue).b;

        color = float3(max(r, r + 0.05), min(g, g - 0.01), min(b, b - 0.01));
    } // Draw with heat distortion
    else // Just normal crt effect
    {
        uv = BarrelDistortion(uv, distortion);
    
        if (uv.x < 0 || uv.x > 1 || uv.y < 0 || uv.y > 1)
            return float4(0, 0, 0, 1);
    
        float r = tex2D(ScreenTexture, uv + float2(aberrationAmount, 0)).r;
        float g = tex2D(ScreenTexture, uv).g;
        float b = tex2D(ScreenTexture, uv - float2(aberrationAmount, 0)).b;

        color = float3(r, g, b);
    }
    
    float scanline = 0.5 + 0.5 * sin((uv.y + time) * scanlineFrequency);
    
    color *= (1.0 - scanlineIntensity) + scanline * scanlineIntensity;
    
    return float4(color, 1.0);
}

technique CRT_Effect
{
    pass CRT
    {
        PixelShader = compile ps_3_0 CRT_Shader();
    }
}