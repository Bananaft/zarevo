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
//varying float CamPos;

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    vScreenPos = GetScreenPosPreDiv(gl_Position);
    vFarRay = GetFarRay(gl_Position);
    //CamPos = cCameraPos;
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
    vec4 albedoInput = texture2D(sEmissiveMap, vScreenPos);
    vec4 normalInput = texture2D(sNormalBuffer, vScreenPos);



    vec4 projWorldPos = vec4(worldPos, 1.0);

    float depth2 = 1-clamp(length(worldPos)/cFogDist, 0.0, 1.0);
    vec3 globalPos = worldPos + cCameraPosPS;
    float height = globalPos.y*0.01;

    vec2 uv = 0.5 + globalPos.xz / (3072 * 5);
    uv.y *= -1;
    vec4 groundAlbedo = textureLod(sSpecMap, uv, 0.0);


    float fogFactor =  clamp(exp(-height*depth2+0.7) * (1-exp(depth2*2-2)),0,1);
    float diffFactor = 1-fogFactor;
    vec3 DirRay = normalize(vFarRay);

    float layer = clamp(exp(((1-DirRay.y)-1) * (0.5 + cCameraPosPS.y*0.001)),0,1);
    float sunDot = max(dot(DirRay ,-1 * cSunDir ),0);
    float sunAmount = pow (exp((sunDot-1)*5), 1 + (1-layer) * 60);


    vec3 fogcolor = 1.0 * cSkyColor * layer + cSunColor *  sunAmount;

    float groundDiff = max(dot(vec3(0,-1,0), cSunDir), 0.0);

    vec3 zenithFactor = cSkyColor * pow(normalInput.y,4.2); //cSkyColor
    vec3 horizonFactor = cSkyColor * (1- 4 * pow(abs(0.5 - normalInput.y),2.2));
    vec3 groundFactor = (cSkyColor + (cSunColor * groundDiff)) * 0.5 * groundAlbedo.rgb * pow(1-normalInput.y,4.2); //


    vec3 skyLight =  0.9 * (zenithFactor + horizonFactor + groundFactor);

    //vec3 skyLight = vec3(0.5) * normalInput.y + vec3(0.5) * (1-normalInput.y);

    vec3 result = (diffuseInput.rgb + skyLight * albedoInput.rgb)*diffFactor + fogcolor*fogFactor;

    gl_FragColor = vec4(result, 0.0);

}
