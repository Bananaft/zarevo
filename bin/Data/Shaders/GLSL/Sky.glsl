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

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    vScreenPos = GetScreenPosPreDiv(gl_Position);
    vFarRay = GetFarRay(gl_Position);
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

        vec4 albedoInput = texture2D(sAlbedoBuffer, vScreenPos);
        vec4 normalInput = texture2D(sNormalBuffer, vScreenPos);


    vec3 normal = normalize(normalInput.rgb * 2.0 - 1.0);
    vec4 projWorldPos = vec4(worldPos, 1.0);
    vec3 sunColor = cSunColor.rgb;
    vec3 sunDir = cSunDir;

    //float diff = max(dot(normal, sunDir), 0.0); //GetDiffuse(normal, worldPos, sunDir);

    //#ifdef SHADOW
    //    diff *= GetDirShadowDeferred(projWorldPos, depth);
    //#endif
    float fogFactor = clamp(15 * depth, 0.0, 1.0);

    float skydiff = 0.5 * (normal.y + 1.0);

    vec3 result = mix(albedoInput.rgb * (skydiff * cSkyColor),cSkyColor * 2,fogFactor);

    gl_FragColor = vec4(result, 0.0);

}
