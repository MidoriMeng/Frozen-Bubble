#ifndef IRIDESCENCE_DEPENDENCE_INCLUDED
#define IRIDESCENCE_DEPENDENCE_INCLUDED

// Based on GPU Gems
// Optimised by Alan Zucconi
float3 bump3y (float3 x, float3 yoffset)
{
    float3 y = 1 - x * x;
    y = saturate(y-yoffset);
    return y;
}

half3 spectral_gems (float w)
{
    // w: [400, 700]
    // x: [0,   1]
    half x = saturate((w - 400.0)/300.0);
    
    return bump3y
    (    half3
        (
            4 * (x - 0.75),    // Red
            4 * (x - 0.5),    // Green
            4 * (x - 0.25)    // Blue
        ), 0
    );
}

float3 spectral_zucconi (float w)
{
    // w: [400, 700]
    // x: [0,   1]
    float x = saturate((w - 400.0)/ 300.0);
    const float3 cs = float3(3.54541723, 2.86670055, 2.29421995);
    const float3 xs = float3(0.69548916, 0.49416934, 0.28269708);
    const float3 ys = float3(0.02320775, 0.15936245, 0.53520021);
    return bump3y (    cs * (x - xs), ys);
}

float3 spectral_zucconi6(float w)
{
    float x = saturate((w - 400.0)/ 300.0);
    const float3 c1 = float3(3.54585104, 2.93225262, 2.41593945);
    const float3 x1 = float3(0.69549072, 0.49228336, 0.27699880);
    const float3 y1 = float3(0.02312639, 0.15225084, 0.52607955);
    const float3 c2 = float3(3.90307140, 3.21182957, 3.96587128);
    const float3 x2 = float3(0.11748627, 0.86755042, 0.66077860);
    const float3 y2 = float3(0.84897130, 0.88445281, 0.73949448);
    return
        bump3y(c1 * (x - x1), y1) +
        bump3y(c2 * (x - x2), y2) ;
}

void spectral_zucconi6_float (float w, out float3 output)
{
    // w: [400, 700]
    // x: [0,   1]
    float x = saturate((w - 400.0)/ 300.0);
    const float3 c1 = float3(3.54585104, 2.93225262, 2.41593945);
    const float3 x1 = float3(0.69549072, 0.49228336, 0.27699880);
    const float3 y1 = float3(0.02312639, 0.15225084, 0.52607955);
    const float3 c2 = float3(3.90307140, 3.21182957, 3.96587128);
    const float3 x2 = float3(0.11748627, 0.86755042, 0.66077860);
    const float3 y2 = float3(0.84897130, 0.88445281, 0.73949448);
    output =
        bump3y(c1 * (x - x1), y1) +
        bump3y(c2 * (x - x2), y2) ;
}

void iridescence_float(float cosThetaR, float thickness, float power, float phase_shift, out float3 color)
{
    color = 0;
    float value = 2.66 * cosThetaR * thickness; // 2.66 = 2 * 1.33 , ior of water
    for (int n = -4; n <= 4; n++)
    {
        float wavelength = value / (n + 0.5);
        wavelength = pow(wavelength, power);
        color.rgb += spectral_zucconi6(wavelength + phase_shift);
    }
    color = saturate(color);
}
#endif