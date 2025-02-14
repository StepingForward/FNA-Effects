#define MAX_LIGHTS 16

struct PS_INPUT
{
    float4 Position : SV_Position;
    float2 TexCoord : TEXCOORD0;
};

sampler TextureSampler;
float4 LightPositions[MAX_LIGHTS];
float4 LightColors[MAX_LIGHTS];
float4 LightInfo[MAX_LIGHTS]; // intensity, radius, unused, unused
int NumLights;
float3 AmbientColor;

float4 ps_main(PS_INPUT input) : COLOR
{
    float4 texColor = tex2D(TextureSampler, input.TexCoord);
    float3 finalColor = AmbientColor * texColor.rgb;

    for (int i = 0; i < NumLights; i++) // Very simple light effect, if smt is further == less light
    {
        float2 lightPos = LightPositions[i].xy;
        float3 lightColor = LightColors[i].rgb;
        float intensity = LightInfo[i].x;
        float radius = LightInfo[i].y;

        float2 diff = input.Position.xy - lightPos;
        float distance = length(diff);

        if (distance < radius)
        {
            float attenuation = 1.0 - (distance / radius);
            finalColor += lightColor * texColor.rgb * intensity * attenuation;
        }
    }

    return float4(finalColor, texColor.a);
}

technique BasicLighting
{
    pass P0
    {
        PixelShader = compile ps_3_0 ps_main();
    }
}