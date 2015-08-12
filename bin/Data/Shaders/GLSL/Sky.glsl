#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"
#include "Lighting.glsl"

uniform vec3 cSkyColor;
uniform vec3 cSunColor;
uniform vec3 cSunDir;
uniform float cFogDist;
uniform float cCamHeight;

varying vec2 vScreenPos;
varying vec3 vFarRay;

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    vScreenPos = GetScreenPosPreDiv(gl_Position);
    vFarRay = GetFarRay(gl_Position);
}


void PS()
{
    // If rendering a directional light quad, optimize out the w divide

        #ifdef HWDEPTH
            float depth = ReconstructDepth(texture2D(sDepthBuffer, vScreenPos).r);
        #else
            float depth = DecodeDepth(texture2D(sDepthBuffer, vScreenPos).rgb);
        #endif

        vec3 worldPos = vFarRay * depth;

        vec4 diffuseInput = texture2D(sDiffMap, vScreenPos);


    vec4 projWorldPos = vec4(worldPos, 1.0);

    float depth2 = 1-clamp(length(worldPos)/cFogDist, 0.0, 1.0);
    float height = (worldPos.y + cCamHeight)*0.01;

    float fogFactor =  clamp(exp(-height*depth2+0.7) * (1-exp(depth2*2-2)),0,1);
    float diffFactor = 1-fogFactor;//(1-exp(-height*depth2)) * (exp(depth2*3-3));
    //float skyfactor = (exp((1-depth2)*10-10));

    //float skydiff = 0.5 * (normal.y + 1.0);
    vec3 DirRay = normalize(vFarRay);
  //  float layer = min(pow((1-abs(DirRay.y)),3.5),1);//*2*(1-diffFactor)-2*(1-diffFactor)
    //float layer = pow(1-DirRay.y, 1-cCamHeight);
    float layer = clamp(exp(((1-DirRay.y)-1) * (0.5 + cCamHeight*0.001)),0,1);
    float sunDot = max(dot(DirRay ,-1 * cSunDir ),0);
    float sunAmount = pow (exp((sunDot-1)*5), 1 + (1-layer) * 60); //exp(sunDot*20*(1-layer)-20*(1-layer)); //pow (sunDot, 1 + (1-layer) * 6);// * (1-diffFactor);//max (dot(DirRay ,-1 * cSunDir ),0);

    //sunAmount *= 1+layer*2;
    //

    vec3 fogcolor = 1.0 * cSkyColor * layer + cSunColor *  sunAmount;//             //mix( cSkyColor,cSunColor, sunAmount );// pow(sunAmount,8.0)

    vec3 result = diffuseInput.rgb*diffFactor + fogcolor*fogFactor; //diffuseInput.rgb * (1-0.95*diffFactor) + fogcolor * fogFactor;

    //result = pow( result ,vec3( 1/2.2 ) );

    gl_FragColor = vec4(result, 0.0);

}
