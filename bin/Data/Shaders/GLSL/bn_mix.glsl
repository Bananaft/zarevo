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
	vec4 normalMap = texture2D(sNormalMap, vTexCoord.xy * 300);
	
	vec3 nm1;
    nm1.xy = normalMap.rg * 2.0 - 1.0;
    nm1.z = sqrt(max(1.0 - dot(nm1.xy, nm1.xy), 0.0));
	
	vec3 nm2;
    nm2.xy = normalMap.ba * 2.0 - 1.0;
    nm2.z = sqrt(max(1.0 - dot(nm2.xy, nm2.xy), 0.0));
	
	vec4 heightmap = texture2D(sDiffMap, vTexCoord.xy + normalize(nm1.xy * 2) * 0.0006);

	vec4 diffColor = heightmap;
	
	
	
	vec3 normal = mix(nm1, nm2, 1-heightmap.a);
	
	mat3 tbn = mat3(vTangent.xyz, vec3(vTexCoord.zw, vTangent.w), vNormal);
    normal = normalize(tbn * normal);
	
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
