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
    vTexCoord = vec4(GetTexCoord(iTexCoord), bitangent.xy);
    vTangent = vec4(tangent, bitangent.z);

    #ifdef VERTEXCOLOR
        vColor = iColor;
    #endif
}

void PS()
{
	vec4 heightmap = texture2D(sDiffMap, vTexCoord.xy);

	vec4 diffColor = heightmap;
	
	vec4 normalMap = texture2D(sNormalMap, vTexCoord.xy * 200);
	mat3 tbn = mat3(vTangent.xyz, vec3(vTexCoord.zw, vTangent.w), vNormal);
    vec3 normal = normalize(tbn * DecodeNormal(normalMap));
	
	vec3 ambient = diffColor.rgb * cAmbientColor;

    #if defined(PREPASS)
        // Fill light pre-pass G-Buffer
        gl_FragData[0] = vec4(0.5, 0.5, 0.5, 1.0);
        gl_FragData[1] = vec4(EncodeDepth(vWorldPos.w), 0.0);
    #elif defined(DEFERRED)
        gl_FragData[0] = vec4(ambient , diffColor.a);
        gl_FragData[1] = vec4(diffColor.rgb, 0.0);
        gl_FragData[2] = vec4(normal * 0.5 + 0.5, 1.0);
        gl_FragData[3] = vec4(EncodeDepth(vWorldPos.w), 0.0);
    #else
        gl_FragColor = vec4(diffColor.rgb, diffColor.a);
    #endif
}
