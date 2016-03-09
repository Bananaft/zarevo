#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"
#include "Lighting.glsl"

uniform float cExposure;

varying vec2 vScreenPos;


void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    vScreenPos = GetScreenPosPreDiv(gl_Position);
}


void PS()
{

    vec4 diffuseInput = texture2D(sDiffMap, vScreenPos);

    gl_FragColor = vec4(diffuseInput * cExposure);

}
