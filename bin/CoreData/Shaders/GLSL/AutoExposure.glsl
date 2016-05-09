#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"
#include "PostProcess.glsl"

varying vec2 vTexCoord;
varying vec2 vScreenPos;

#ifdef COMPILEPS
uniform float cAutoExposureAdaptRate;
uniform vec2 cAutoExposureLumRange;
uniform float cAutoExposureMiddleGrey;
uniform vec2 cHDR128InvSize;
uniform vec2 cLum64InvSize;
uniform vec2 cLum16InvSize;
uniform vec2 cLum4InvSize;

float GatherAvgLum(sampler2D texSampler, vec2 texCoord, vec2 texelSize)
{
    float lumAvg = 0.0;
    lumAvg += texture2D(texSampler, texCoord + vec2(1.0, -1.0) * texelSize).r;
    lumAvg += texture2D(texSampler, texCoord + vec2(-1.0, 1.0) * texelSize).r;
    lumAvg += texture2D(texSampler, texCoord + vec2(1.0, 1.0) * texelSize).r;
    lumAvg += texture2D(texSampler, texCoord + vec2(1.0, -1.0) * texelSize).r;
    return lumAvg / 4.0;
}
#endif

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);
    vTexCoord = GetQuadTexCoord(gl_Position);
    vScreenPos = GetScreenPosPreDiv(gl_Position);
}

// this value determines ratio of dark and bright pixels in frame for the same value of average luminance
// increasing this value means increasing contribution of bright pixels
// decreasing - increasing contribution of dark pixels
#define EXPOSURE_INTEGRAL_OFFSET 1.00f
// some non-linear response of bright pixels
#define EXPOSURE_EXP_OFFSET 0.5f

void PS()
{
    #ifdef LUMINANCE64
    vec3 colors[4];
    colors[ 0 ] = texture2D(sDiffMap, vTexCoord + vec2(-1.0, -1.0) * cHDR128InvSize).rgb;
    colors[ 1 ] = texture2D(sDiffMap, vTexCoord + vec2(-1.0, 1.0) * cHDR128InvSize).rgb;
    colors[ 2 ] = texture2D(sDiffMap, vTexCoord + vec2(1.0, 1.0) * cHDR128InvSize).rgb;
    colors[ 3 ] = texture2D(sDiffMap, vTexCoord + vec2(1.0, -1.0) * cHDR128InvSize).rgb;

 // pack luminance to shift dark/bright pixels contribution on total average
 float packedLum = 0;
 for( int n = 0; n < 4; ++n )
  packedLum += 1.0f / ( dot( colors[ n ], LumWeights ) + EXPOSURE_INTEGRAL_OFFSET );

 packedLum /= 4;
 packedLum = pow( packedLum, EXPOSURE_EXP_OFFSET );

    gl_FragColor.r = packedLum;
    #endif

    #ifdef LUMINANCE16
    gl_FragColor.r = GatherAvgLum(sDiffMap, vTexCoord, cLum64InvSize);
    #endif

    #ifdef LUMINANCE4
    gl_FragColor.r = GatherAvgLum(sDiffMap, vTexCoord, cLum16InvSize);
    #endif

    #ifdef LUMINANCE1
    gl_FragColor.r = GatherAvgLum(sDiffMap, vTexCoord, cLum4InvSize);
    #endif

    #ifdef ADAPTLUMINANCE
    float adaptedLum = texture2D(sDiffMap, vTexCoord).r;
   float lum = texture2D(sNormalMap, vTexCoord).r;
   lum = ( 1.0f / pow( lum, 1.0f / EXPOSURE_EXP_OFFSET ) - EXPOSURE_INTEGRAL_OFFSET );
   lum = clamp(lum, cAutoExposureLumRange.x, cAutoExposureLumRange.y);
    gl_FragColor.r = adaptedLum + (lum - adaptedLum) * (1.0 - exp(-cDeltaTimePS * cAutoExposureAdaptRate));


// gl_FragColor.r = curLum;
    #endif

    #ifdef EXPOSE
    vec3 color = texture2D(sDiffMap, vScreenPos).rgb;
    float adaptedLum = texture2D(sNormalMap, vTexCoord).r;
    //gl_FragColor = vec4( pow( vec3(color * (cAutoExposureMiddleGrey / adaptedLum)),vec3( 1/2.2 ) ), 1.0 );


    ///// Numbers output by FabriceNeyret2 https://www.shadertoy.com/view/4lXSR4
    int x = 28-int(vScreenPos.x * 1000)/3, y = int(vScreenPos.y  * 1000)/3,
    c = int( adaptedLum / pow(10.,float(x/4-3)) );
    x-=x/4*4;
    c = ( x<1||y<1||y>5? 0: y>4? 972980223: y>3? 690407533: y>2? 704642687: y>1? 696556137: 972881535 )
        / int(exp2(float(x+26+c/10*30-3*c)));
    vec3 num = vec3( max(c-c/2*2 , 0) );
    gl_FragColor = vec4( vec3(color * (cAutoExposureMiddleGrey / adaptedLum) + num*0.2), 1.0);

    #endif
}
