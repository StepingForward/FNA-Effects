sampler s0;
float timer;

float4 BevelPixelShaderFunction(float2 coords: TEXCOORD0) : COLOR0
{
    float4 color = tex2D(s0, coords);
	color -= tex2D(s0, coords - 0.002 * sin(timer/10)) * 2.5f;
	color += tex2D(s0, coords + 0.002 * cos(timer/10)) * 2.5f;

    return color;
}

float _bloomThreshold;

float4 SinInvertePixelFunction( float2 coords:TEXCOORD0, in float2 screenPos:VPOS ) : COLOR0
{
    float4 norm_color = tex2D(s0, coords);
    float4 color = float4(0, 0, 0, 0);
    
    if (coords.x > 1 * abs(sin(timer / 100))) {
        color = float4(1-norm_color.r, 1-norm_color.g, 1-norm_color.b, 1);
    }
    else {
        color = norm_color;
    }

    return color;
}

texture distortionTexture;
sampler2D distortionTextureSampler = sampler_state
{
    Texture = <distortionTexture>;
    AddressU = Wrap;
    AddressV = Wrap;
};

float distortionFactor;
float riseFactor;

float4 HeatDistortionPS(float2 coords : TEXCOORD0) : COLOR0
{
    float2 distortionUV = coords;
    distortionUV.y -= sin(timer) * -riseFactor;
    
    float2 distortionMapValue = tex2D( distortionTextureSampler, distortionUV ).xy;
    
    float2 distortionPositionOffset = distortionMapValue;
    distortionMapValue = ( ( distortionMapValue * 2.0 ) - 1.0 );
    
    distortionMapValue *= distortionFactor;
    
    distortionMapValue *= ( coords.y );
    
    float4 color = tex2D(s0, distortionMapValue + coords);
    
    return float4(max(color.r, color.r + 0.1), min(color.g, color.g - 0.1), min(color.b, color.b - 0.1), color.a);
}

float4 WaterDistortionPS(float2 coords : TEXCOORD0) : COLOR0
{
    float2 distortionUV = coords;
    distortionUV.x -= sin(timer) * -riseFactor;
    
    float2 distortionMapValue = tex2D(distortionTextureSampler, distortionUV).xy;
    
    float2 distortionPositionOffset = distortionMapValue;
    distortionMapValue = ((distortionMapValue * 2.0) - 1.0);
    
    distortionMapValue *= distortionFactor;
    
    distortionMapValue *= (coords.x);
    
    float4 color = tex2D(s0, distortionMapValue + coords);
    
    return float4(min(color.r, color.r - 0.05), min(color.g, color.g - 0.05), max(color.b, max(color.b + 0.1, color.b + 0.2)), color.a);
}

float power;
float radius;


float4 VignettePS(float2 texCoord : TEXCOORD0) : COLOR0
{
    float4 color = tex2D(s0, texCoord);
    float2 dist = (texCoord - 0.5f) * radius;
    dist.x = 1 - dot(dist, dist) * power;
    color.rgb *= dist.x;
    
    return color;
}

technique Vignette
{
    pass Pass1
    {
        PixelShader = compile ps_2_0 VignettePS();
    }
}

technique Distortion
{
    pass Water
    {
        PixelShader = compile ps_2_0 WaterDistortionPS();
    }

    pass Heat
    {
        PixelShader = compile ps_2_0 HeatDistortionPS();
    }
}

technique SinInvert
{
    pass Pass1
    {
        PixelShader = compile ps_3_0 SinInvertePixelFunction();
    }
}

technique Bevel
{
    pass Pass1
    {
        PixelShader = compile ps_2_0 BevelPixelShaderFunction();
    }
}