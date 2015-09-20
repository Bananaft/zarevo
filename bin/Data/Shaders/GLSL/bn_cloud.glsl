#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"


varying vec4 vTexCoord;
varying vec3 vNormal;

void VS()
{
  mat4 modelMatrix = iModelMatrix;
  vec3 worldPos = GetWorldPos(modelMatrix);
  gl_Position = GetClipPos(worldPos);
  vWorldPos = vec4(worldPos, GetDepth(gl_Position));

  //vNormal = GetWorldNormal(modelMatrix);

  //vec3 tangent = GetWorldTangent(modelMatrix);
  //vec3 bitangent = cross(tangent, vNormal) * iTangent.w;
  vTexCoord = vec4(GetTexCoord(iTexCoord),0,0);

}

void PS()
{
  vec3 normal = vec3(0,1,0);
  vec3 ambient = vec3(0.2,0.2,0.5);
  vec3 diffColor = vec3(1,0.7,0.7);
  #if defined(PREPASS)
      // Fill light pre-pass G-Buffer
      gl_FragData[0] = vec4(0.5, 0.5, 0.5, 1.0);
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
