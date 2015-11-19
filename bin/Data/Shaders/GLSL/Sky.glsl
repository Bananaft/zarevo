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
varying float CamHeight;

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    vScreenPos = GetScreenPosPreDiv(gl_Position);
    vFarRay = GetFarRay(gl_Position);
    CamHeight = cCameraPos.y;
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
    //vec4 albedoInput = texture2D(sAlbedoBuffer, vScreenPos);
    vec4 normalInput = texture2D(sNormalBuffer, vScreenPos);


    vec4 projWorldPos = vec4(worldPos, 1.0);

    float depth2 = 1-clamp(length(worldPos)/cFogDist, 0.0, 1.0);
    float height = (worldPos.y + CamHeight)*0.01;

    float fogFactor =  clamp(exp(-height*depth2+0.7) * (1-exp(depth2*2-2)),0,1);
    float diffFactor = 1-fogFactor;
    vec3 DirRay = normalize(vFarRay);

    float layer = clamp(exp(((1-DirRay.y)-1) * (0.5 + CamHeight*0.001)),0,1);
    float sunDot = max(dot(DirRay ,-1 * cSunDir ),0);
    float sunAmount = pow (exp((sunDot-1)*5), 1 + (1-layer) * 60);


    vec3 fogcolor = 1.0 * cSkyColor * layer + cSunColor *  sunAmount;

    vec3 skyLight = cSkyColor * 0.02;

    vec3 result = (diffuseInput.rgb)*diffFactor + fogcolor*fogFactor;

    gl_FragColor = vec4(result, 0.0);

}
