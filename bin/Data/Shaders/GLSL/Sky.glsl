#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"
#include "Lighting.glsl"

uniform vec3 cSkyColor;
uniform vec3 cSunColor;
uniform vec3 cSunDir;
uniform float cFogDist;

varying vec2 vScreenPos;
varying vec3 vFarRay;
varying vec3 vDirRay;

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    vScreenPos = GetScreenPosPreDiv(gl_Position);
    vFarRay = GetFarRay(gl_Position);
    vDirRay = normalize(vFarRay);
}


void PS()
{
    // If rendering a directional light quad, optimize out the w divide

        #ifdef HWDEPTH
            float depth = ReconstructDepth(texture2D(sDepthBuffer, vScreenPos).r);
        #else
            float depth = DecodeDepth(texture2D(sDepthBuffer, vScreenPos).rgb);
        #endif

        vec3 worldPos = vFarRay * depth;

        vec4 diffuseInput = texture2D(sDiffMap, vScreenPos);


    vec4 projWorldPos = vec4(worldPos, 1.0);

    float depth2 = 1-clamp(length(worldPos)/7000, 0.0, 1.0);

   float fogFactor = (1-exp(depth2*4-4));
    float diffFactor = (exp(depth2*3-3));
    //float skyfactor = (exp((1-depth2)*10-10));

    //float skydiff = 0.5 * (normal.y + 1.0);
    vec3 DirRay = normalize(vFarRay);
    float layer = min(exp((1-abs(DirRay.y))*10*(1-diffFactor)-10*(1-diffFactor)),1);

    float sunAmount = max(dot(DirRay ,-1 * cSunDir ),0);// * (1-diffFactor);//max (dot(DirRay ,-1 * cSunDir ),0);
    //sunAmount *= 1+layer*2;
    //

    vec3 fogcolor = cSkyColor + cSunColor *  pow(sunAmount,(1-layer)*8.0);//mix( cSkyColor,cSunColor, sunAmount );// pow(sunAmount,8.0)

    vec3 result = diffuseInput.rgb*diffFactor + fogcolor*fogFactor; //diffuseInput.rgb * (1-0.95*diffFactor) + fogcolor * fogFactor;

    gl_FragColor = vec4(result, 0.0);

}
