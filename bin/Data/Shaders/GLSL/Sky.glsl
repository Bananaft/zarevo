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

        vec4 diffuseInput = texture2D(sDiffMap, vScreenPos);


    vec4 projWorldPos = vec4(worldPos, 1.0);

    float depth2 = length(worldPos.xz);

    float fogFactor = clamp(depth2 / 1000, 0.0, 1.0);
    float diffFactor = clamp(depth2 / 5000, 0.0, 1.0);

    //float skydiff = 0.5 * (normal.y + 1.0);

    vec3 result = diffuseInput.rgb * (1-0.95*diffFactor) + cSkyColor * fogFactor;

    gl_FragColor = vec4(result, 0.0);

}
