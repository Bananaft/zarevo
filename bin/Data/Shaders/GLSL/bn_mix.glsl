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
	
    // Get material diffuse albedo
    #ifdef DIFFMAP
        vec4 diffColor = cMatDiffColor * texture2D(sDiffMap, vTexCoord * 0.2);
        #ifdef ALPHAMASK
            if (diffColor.a < 0.5)
                discard;
        #endif
    #else
        vec4 diffColor = cMatDiffColor;
    #endif
	
	//vec2 distCoord = vTexCoord + (1 - diffColor.r * 2);
	vec4 normalMap = texture2D(sNormalMap, vTexCoord*1 +  .02 * (1 - diffColor.b * 2));

    #ifdef VERTEXCOLOR
        diffColor *= vColor;
    #endif
	
	//diffColor = vec4(1.0,0.5,0.0,1.0);

    #if defined(PREPASS)
        // Fill light pre-pass G-Buffer
        gl_FragData[0] = vec4(0.5, 0.5, 0.5, 1.0);
        gl_FragData[1] = vec4(EncodeDepth(vWorldPos.w), 0.0);
    #elif defined(DEFERRED)
        gl_FragData[0] = vec4(0,0,0, diffColor.a);
        gl_FragData[1] = vec4(1,1,1, 0.0);
        gl_FragData[2] = vec4(normalMap.rgb * 0.5 + 0.5, 1.0);
        gl_FragData[3] = vec4(EncodeDepth(vWorldPos.w), 0.0);
    #else
        gl_FragColor = vec4(diffColor.rgb, diffColor.a);
    #endif
}
