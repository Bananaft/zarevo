#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"


varying vec2 vTexCoord;
//varying vec4 vWorldPos;
varying vec3 vNormal;
varying vec3 vBinormal;
varying vec3 vTangent;
//varying vec3 vClipPos;


void VS()
{
  mat4 modelMatrix = iModelMatrix;
  vec3 worldPos = GetWorldPos(modelMatrix) +  vec3(6*iTexCoord.x, 6*iTexCoord.y, 0) * cCameraRot;
  vec4 clipPos = GetClipPos(worldPos);
  gl_Position = clipPos;
  //vClipPos = clipPos.xyz;

  //vWorldPos = vec4(worldPos, GetDepth(gl_Position));
  //vec4 worldnorm = GetNearRay(gl_Position);
  vec3 camUp = vec3(cCameraRot[0][1],cCameraRot[1][1],cCameraRot[2][1]);
  vec3 Dir = normalize(cCameraPos-worldPos);
  vec3 Right = normalize( cross( Dir , camUp));
  vec3 Up = normalize( cross( Right, Dir ) );
  vNormal = Dir;
  vBinormal = Up * -1;
  vTangent = Right;

  vTexCoord = vec2(0.5 * iTexCoord.xy + vec2(0.5,0.5));

}

void PS()
{
  vec4 nmMap = texture2D(sDiffMap, vTexCoord.xy);
  //float depth = ReconstructDepth(texture2D(sDepthBuffer, vClipPos.xy).r);
  if (nmMap.a < 0.5)
      discard;
  mat3 tbn = transpose(mat3(vTangent, vBinormal, vNormal));
  vec3 normal = DecodeNormal(nmMap) * tbn;

  vec3 diffColor = vec3(1.0,1.0,1.0);
  vec3 ambient = diffColor.rgb * cAmbientColor * ( 0.5 * (normal.y + 1.0));
  float scatter = (1-nmMap.a) * 2;


  #if defined(PREPASS)
      // Fill light pre-pass G-Buffer
      gl_FragData[0] = vec4(0.5, 0.9, 0.5, 1.0);
      //gl_FragData[1] = vec4(EncodeDepth(vWorldPos.w), 0.0);
  #elif defined(DEFERRED)
      gl_FragData[0] = vec4(ambient , 1.0);
      gl_FragData[1] = vec4(diffColor.rgb, scatter);
      gl_FragData[2] = vec4(normal * 0.5 + 0.5, 1.0);
      //gl_FragData[3] = vec4(EncodeDepth(vWorldPos.w), 0.0);
  #else
      gl_FragColor = vec4(diffColor.rgb, diffColor.a);
  #endif
}
