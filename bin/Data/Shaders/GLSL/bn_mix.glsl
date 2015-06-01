#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"


varying vec2 vTexCoord;
varying vec4 vWorldPos;
varying vec3 vNormal;
#ifdef VERTEXCOLOR
    varying vec4 vColor;
#endif

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);
    vTexCoord = GetTexCoord(iTexCoord); // iTexCoord;//
    vWorldPos = vec4(worldPos, GetDepth(gl_Position));
	
	vNormal = GetWorldNormal(modelMatrix);

    #ifdef VERTEXCOLOR
        vColor = iColor;
    #endif
}

void PS()
{
	vec3 normal = normalize(vNormal);

    vec4 heightmap = texture2D(sDiffMap, vTexCoord);
	vec3 pattern  = texture2D(sNormalMap, vTexCoord * 1024).rgb;
	vec2 coords = vec2(heightmap.r + pattern.r * 0.02, heightmap.b + pattern.g  * 0.02);
	vec3 color = texture2D(sSpecMap,coords).rgb;
	
	vec4 diffColor = vec4(color,0);
	
	
	//vec2 distCoord = vTexCoord + (1 - diffColor.r * 2);
	//vec4 normalMap = texture2D(sNormalMap, vTexCoord*1 +  .02 * (1 - diffColor.b * 2));

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
