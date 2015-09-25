#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"


varying vec4 vTexCoord;
varying vec4 vWorldPos;

void VS()
{
  mat4 modelMatrix = iModelMatrix;
  vec3 worldPos = GetWorldPos(modelMatrix) +  vec3(6*iTexCoord.x, 6*iTexCoord.y,0) * cCameraRot;
  gl_Position = GetClipPos(worldPos);
  vWorldPos = vec4(worldPos, GetDepth(gl_Position));

  //vNormal = GetWorldNormal(modelMatrix);

  //vec3 tangent = GetWorldTangent(modelMatrix);
  //vec3 bitangent = cross(tangent, vNormal) * iTangent.w;
  vTexCoord = vec4(0.5 * iTexCoord + vec2(0.5,0.5),0,0);

}

void PS()
{
  vec3 normal = vec3(0.5 + 0.5 * vTexCoord.x,0.5 + 0.5 * vTexCoord.x,1-(0.5 * (vTexCoord.x+vTexCoord.y)));
  vec3 ambient = vec3(0.0,0.0,0.0);
  vec4 blob_nm = texture2D(sDiffMap, vTexCoord.xy); //
  vec3 diffColor = blob_nm.rgb;
  #if defined(PREPASS)
      // Fill light pre-pass G-Buffer
      gl_FragData[0] = vec4(0.5, 0.5, 0.5, 1.0);
      gl_FragData[1] = vec4(EncodeDepth(vWorldPos.w), 0.0);
  #elif defined(DEFERRED)
      gl_FragData[0] = vec4(diffColor , 1.0);
      gl_FragData[1] = vec4(diffColor.rgb, 0.0);
      gl_FragData[2] = vec4(normal * 0.5 + 0.5, 1.0);
      gl_FragData[3] = vec4(EncodeDepth(vWorldPos.w), 0.0);
  #else
      gl_FragColor = vec4(diffColor.rgb, diffColor.a);
  #endif
}
