#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"

varying vec2 vTexCoord;

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix) +  vec3(6*iTexCoord.x, 6*iTexCoord.y,0) * cCameraRot;
    vec4 clipPos = GetClipPos(worldPos);
    //clipPos.z += 0.5;
    gl_Position = clipPos;
    vTexCoord = 0.5 * iTexCoord + vec2(0.5,0.5);
}

void PS()
{
        float alpha = texture2D(sDiffMap, vTexCoord).a;
        if (alpha < 0.5)
            discard;

    gl_FragColor = vec4(1.0);
}
