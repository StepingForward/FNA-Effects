float fract(float x)
{
    return x - floor(x);
}

float2 fract(float2 x)
{
    return x - floor(x);
}

float rand(float2 coords)
{
    return fract(sin(dot(coords, float2(56.3456f, 78.3456f)) * 5.0f) * 10000.0f);
}

float3 mix(float3 a, float3 b, float t)
{
    return a * (1.0 - t) + b * t;
}

float4 mix(float4 a, float4 b, float t)
{
    return a * (1.0 - t) + b * t;
}

float2 mix(float2 a, float2 b, float t)
{
    return a * (1.0 - t) + b * t;
}

float mix(float a, float b, float t)
{
    return a * (1.0 - t) + b * t;
}

float noise(float2 coords, float off)
{
    float2 i = floor(coords);
    float2 f = fract(coords);

    float a = rand(i + off);
    float b = rand(i + float2(1.0f, 0.0f) + off);
    float c = rand(i + float2(0.0f, 1.0f) + off);
    float d = rand(i + float2(1.0f, 1.0f) + off);

    float2 cubic = f * f * (3.0f - 2.0f * f);

    return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0f - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(float2 coords, float off)
{
    float value = 0.0f;
    float scale = 0.5f;

    for (int i = 0; i < 5; i++)
    {
        value += noise(coords, off) * scale;
        coords *= 4.0f;
        scale *= 0.5f;
    }

    return value;
}