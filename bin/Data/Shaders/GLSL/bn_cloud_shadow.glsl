#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"

varying vec2 vTexCoord;

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    vec4 clipPos = GetClipPos(worldPos);
    gl_Position = vec4(clipPos.x + 0.032 * iTexCoord.x ,
                       clipPos.y + 0.032 * iTexCoord.y ,
                       clipPos.z,clipPos.w);
    vTexCoord = GetTexCoord(iTexCoord);
}

void PS()
{
    #ifdef ALPHAMASK
        float alpha = texture2D(sDiffMap, vTexCoord).a;
        if (alpha < 0.5)
            discard;
    #endif

    gl_FragColor = vec4(1.0);
}
