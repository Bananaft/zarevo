#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"

varying vec4 vTexCoord;

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix) +  vec3(6*iTexCoord.x, 6*iTexCoord.y,0) * cCameraRot;
    vec4 clipPos = GetClipPos(worldPos);

    gl_Position = clipPos;
    vTexCoord.xy = 0.5 * iTexCoord + vec2(0.5,0.5);
    vTexCoord.zw = clipPos.xy * 1024;
}

void PS()
{
        float chkr = fract(vTexCoord.z + vTexCoord.w);
        float alpha = texture2D(sDiffMap, vTexCoord.xy).a;

        if (chkr < 0.5)
            discard;

    //gl_FragColor = vec4(1.0);
}
