#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"


//varying vec2 vTexCoord;

void VS()
{
  mat4 modelMatrix = iModelMatrix;
  //modelMatrix[3].xyz = vec3(0.0);
  vec3 worldPos = (vec4(0.) * modelMatrix).xyz;
  vec4 clipPos = GetClipPos(worldPos);
  gl_Position = clipPos;

//  vTexCoord = vec2(0.5 * iTexCoord.xy + vec2(0.5,0.5));

}

void PS()
{

  vec3 ambient = vec3(64.0,64.0,64.0);

  #if defined(PREPASS)
      // Fill light pre-pass G-Buffer
      gl_FragData[0] = vec4(0.5, 0.9, 0.5, 1.0);
      //gl_FragData[1] = vec4(EncodeDepth(vWorldPos.w), 0.0);
  #elif defined(DEFERRED)
      gl_FragData[0] = vec4(ambient , 1.0);
      gl_FragData[1] = vec4(0.0, 0.0, 0.0, 0.0);
      gl_FragData[2] = vec4(0.5, 0.5, 0.5, 1.0);
      //gl_FragData[3] = vec4(EncodeDepth(vWorldPos.w), 0.0);
  #else
      gl_FragColor = vec4(diffColor.rgb, diffColor.a);
  #endif
}
