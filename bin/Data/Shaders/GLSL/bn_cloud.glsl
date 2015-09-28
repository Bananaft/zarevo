#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"


varying vec4 vTexCoord;
varying vec4 vWorldPos;
varying vec3 vNormal;
varying vec3 vBinormal;
varying vec3 vTangent;


void VS()
{
  mat4 modelMatrix = iModelMatrix;
  vec3 worldPos = GetWorldPos(modelMatrix) +  vec3(6*iTexCoord.x, 6*iTexCoord.y,0) * cCameraRot;
  gl_Position = GetClipPos(worldPos);
  vWorldPos = vec4(worldPos, GetDepth(gl_Position));
  //vec4 worldnorm = GetNearRay(gl_Position);
  vec3 camDir = normalize(cCameraPos-worldPos);
  vec3 camRight = normalize( cross( camDir, cCameraRot[ 1 ].xyz ) );
  vec3 camUp = normalize( cross( camRight, camDir ) );
  vNormal = camUp;//vec3(0,0,-1) * cCameraRot;

  vTexCoord = vec4(0.5 * iTexCoord + vec2(0.5,0.5),0,0);

}

void PS()
{
  vec4 blob_nm = texture2D(sDiffMap, vTexCoord.xy);
  mat3 tbn = mat3(vTangent, vBinormal, vNormal);
  vec3 normal =  normalize(blob_nm.xyz * tbn);// + blob_nm.rgb;//vec3(0.5 + 0.5 * vTexCoord.x,0.5 + 0.5 * vTexCoord.x,1-(0.5 * (vTexCoord.x+vTexCoord.y)));
  vec3 ambient = vec3(0.0,0.0,0.0);
  vec3 diffColor = vec3(1.0,1.0,1.0);
  #if defined(PREPASS)
      // Fill light pre-pass G-Buffer
      gl_FragData[0] = vec4(0.5, 0.9, 0.5, 1.0);
      gl_FragData[1] = vec4(EncodeDepth(vWorldPos.w), 0.0);
  #elif defined(DEFERRED)
      gl_FragData[0] = vec4(ambient , 1.0);
      gl_FragData[1] = vec4(diffColor.rgb, 0.0);
      gl_FragData[2] = vec4(normal * 0.5 + 0.5, 1.0);
      gl_FragData[3] = vec4(EncodeDepth(vWorldPos.w), 0.0);
  #else
      gl_FragColor = vec4(diffColor.rgb, diffColor.a);
  #endif
}
