#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"


varying vec4 vTexCoord;
varying vec4 vWorldPos;
varying vec3 vNormal;
varying vec4 vTangent;
#ifdef VERTEXCOLOR
    varying vec4 vColor;
#endif

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    vWorldPos = vec4(worldPos, GetDepth(gl_Position));

	vNormal = GetWorldNormal(modelMatrix);

	vec3 tangent = GetWorldTangent(modelMatrix);
    vec3 bitangent = cross(tangent, vNormal) * iTangent.w;
    vTexCoord = vec4(GetTexCoord(iTexCoord) * (1.0 + (1.0/3072.0)), bitangent.xy);
    vTangent = vec4(tangent, bitangent.z);

    #ifdef VERTEXCOLOR
        vColor = iColor;
    #endif
}

void PS()
{
  vec4 tilemap = texture2D(sDiffMap, vWorldPos.xz / 3072 / 5);
  vec4 pmap = texture2D(sNormalMap, (fract(vWorldPos.xz/5)+vec2(tilemap.r*255,0))/8);

	vec4 diffColor = pmap;

	vec3 normal = vNormal;

	//mat3 tbn = mat3(vTangent.xyz, vec3(vTexCoord.zw, vTangent.w), vNormal);
    //normal = normalize(tbn * normal);


    #if defined(PREPASS)
        // Fill light pre-pass G-Buffer
        gl_FragData[0] = vec4(0.5, 0.5, 0.5, 1.0);
        gl_FragData[1] = vec4(EncodeDepth(vWorldPos.w), 0.0);
    #elif defined(DEFERRED)
        gl_FragData[0] = vec4(0.0);
        gl_FragData[1] = vec4(diffColor.rgb * 0.55, 0.0); //diffColor.rgb
        gl_FragData[2] = vec4(normal * 0.5 + 0.5, 0.0);
        gl_FragData[3] = vec4(EncodeDepth(vWorldPos.w), 0.0);
    #else
        gl_FragColor = vec4(diffColor.rgb, diffColor.a);
    #endif
}
