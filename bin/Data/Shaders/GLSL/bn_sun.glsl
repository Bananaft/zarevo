#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"


//varying vec2 vTexCoord;
varying vec3 vRay;

void VS()
{
  mat4 modelMatrix = iModelMatrix;
  //modelMatrix[3].xyz = vec3(0.0);
  vec3 worldPos = GetWorldPos(modelMatrix);
  vec4 clipPos = GetClipPos(cCameraPos + worldPos);
  //clipPos.z = 1900.0;

  gl_Position = clipPos;
  gl_Position.z = gl_Position.w;
  vRay = normalize(GetFarRay(gl_Position));
//  vTexCoord = vec2(0.5 * iTexCoord.xy + vec2(0.5,0.5));

}

void PS()
{

  vec3 ambient = vec3(64.0,64.0,64.0);
  float alpha = clamp( vRay.y * 100. - 0.5 , 0., 1.);

  #if defined(PREPASS)
      // Fill light pre-pass G-Buffer
      gl_FragData[0] = vec4(0.5, 0.9, 0.5, 1.0);
      //gl_FragData[1] = vec4(EncodeDepth(vWorldPos.w), 0.0);
  #elif defined(DEFERRED)
      gl_FragData[0] = vec4(ambient , alpha);
      gl_FragData[1] = vec4(0.0, 0.0, 0.0, 0.0);
      gl_FragData[2] = vec4(0.5, 0.5, 0.5, 1.0);
      //gl_FragData[3] = vec4(EncodeDepth(vWorldPos.w), 0.0);
  #else
      gl_FragColor = vec4(ambient.rgb, alpha);
  #endif
}
