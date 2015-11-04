uniform vec2 kernel[9] = vec2[]
(
   vec2(0.95581, -0.18159), vec2(0.50147, -0.35807), vec2(0.69607, 0.35559),
   vec2(-0.0036825, -0.59150),	vec2(0.15930, 0.089750), vec2(-0.65031, 0.058189),
   vec2(0.11915, 0.78449),	vec2(-0.34296, 0.51575), vec2(-0.60380, -0.41527)
);

#ifdef COMPILEVS
vec3 GetAmbient(float zonePos)
{
    return cAmbientStartColor + zonePos * cAmbientEndColor;
}

#ifdef NUMVERTEXLIGHTS
float GetVertexLight(int index, vec3 worldPos, vec3 normal)
{
    vec3 lightDir = cVertexLights[index * 3 + 1].xyz;
    vec3 lightPos = cVertexLights[index * 3 + 2].xyz;
    float invRange = cVertexLights[index * 3].w;
    float cutoff = cVertexLights[index * 3 + 1].w;
    float invCutoff = cVertexLights[index * 3 + 2].w;

    // Directional light
    if (invRange == 0.0)
    {
        float NdotL = max(dot(normal, lightDir), 0.0);
        return NdotL;
    }
    // Point/spot light
    else
    {
        vec3 lightVec = (lightPos - worldPos) * invRange;
        float lightDist = length(lightVec);
        vec3 localDir = lightVec / lightDist;
        float NdotL = max(dot(normal, localDir), 0.0);
        float atten = clamp(1.0 - lightDist * lightDist, 0.0, 1.0);
        float spotEffect = dot(localDir, lightDir);
        float spotAtten = clamp((spotEffect - cutoff) * invCutoff, 0.0, 1.0);
        return NdotL * atten * spotAtten;
    }
}

float GetVertexLightVolumetric(int index, vec3 worldPos)
{
    vec3 lightDir = cVertexLights[index * 3 + 1].xyz;
    vec3 lightPos = cVertexLights[index * 3 + 2].xyz;
    float invRange = cVertexLights[index * 3].w;
    float cutoff = cVertexLights[index * 3 + 1].w;
    float invCutoff = cVertexLights[index * 3 + 2].w;

    // Directional light
    if (invRange == 0.0)
        return 1.0;
    // Point/spot light
    else
    {
        vec3 lightVec = (lightPos - worldPos) * invRange;
        float lightDist = length(lightVec);
        vec3 localDir = lightVec / lightDist;
        float atten = clamp(1.0 - lightDist * lightDist, 0.0, 1.0);
        float spotEffect = dot(localDir, lightDir);
        float spotAtten = clamp((spotEffect - cutoff) * invCutoff, 0.0, 1.0);
        return atten * spotAtten;
    }
}
#endif

#ifdef SHADOW

#if defined(DIRLIGHT) && (!defined(GL_ES) || defined(WEBGL))
    #define NUMCASCADES 4
#else
    #define NUMCASCADES 1
#endif

vec4 GetShadowPos(int index, vec4 projWorldPos)
{
    #if defined(DIRLIGHT)
        return projWorldPos * cLightMatrices[index];
    #elif defined(SPOTLIGHT)
        return projWorldPos * cLightMatrices[1];
    #else
        return vec4(projWorldPos.xyz - cLightPos.xyz, 1.0);
    #endif
}

#endif
#endif

#ifdef COMPILEPS
float GetDiffuse(vec3 normal, vec3 worldPos, out vec3 lightDir, float translucency)
{
    #ifdef DIRLIGHT
        lightDir = cLightDirPS;
        float NdotL = dot(normal, lightDir);
        float Diffuse = NdotL * (1 - translucency);
        float Scatter = (NdotL * 0.5 + 0.8 * translucency) * translucency;
        return max(Diffuse + Scatter, 0.0);
    #else
        vec3 lightVec = (cLightPosPS.xyz - worldPos) * cLightPosPS.w;
        float lightDist = length(lightVec);
        lightDir = lightVec / lightDist;
        float NdotL = dot(normal, lightDir);
        float Diffuse = NdotL * (1 - translucency);
        float Scatter = (NdotL * 0.5 + 0.8 * translucency) * translucency;
        return max((Diffuse + Scatter) * pow(max(1-lightDist,0),2.6), 0.0);
    #endif
}

float GetDiffuseVolumetric(vec3 worldPos)
{
    #ifdef DIRLIGHT
        return 1.0;
    #else
        vec3 lightVec = (cLightPosPS.xyz - worldPos) * cLightPosPS.w;
        float lightDist = length(lightVec);
        return texture2D(sLightRampMap, vec2(lightDist, 0.0)).r;
    #endif
}

float GetSpecular(vec3 normal, vec3 eyeVec, vec3 lightDir, float specularPower)
{
    vec3 halfVec = normalize(normalize(eyeVec) + lightDir);
    return pow(max(dot(normal, halfVec), 0.0), specularPower);
}

float GetIntensity(vec3 color)
{
    return dot(color, vec3(0.299, 0.587, 0.114));
}

#ifdef SHADOW

#if defined(DIRLIGHT) && (!defined(GL_ES) || defined(WEBGL))
    #define NUMCASCADES 4
#else
    #define NUMCASCADES 1
#endif

float GetShadow(vec4 shadowPos)
{
    #ifndef GL_ES
        #ifndef LQSHADOW
            // Take four samples and average them
            // Note: in case of sampling a point light cube shadow, we optimize out the w divide as it has already been performed
            #ifndef POINTLIGHT
                vec2 offsets = cShadowMapInvSize * shadowPos.w;
            #else
                vec2 offsets = cShadowMapInvSize;
            #endif
            #ifndef GL3
                return cShadowIntensity.y + cShadowIntensity.x * (shadow2DProj(sShadowMap, shadowPos).r +
                    shadow2DProj(sShadowMap, vec4(shadowPos.x + offsets.x, shadowPos.yzw)).r +
                    shadow2DProj(sShadowMap, vec4(shadowPos.x, shadowPos.y + offsets.y, shadowPos.zw)).r +
                    shadow2DProj(sShadowMap, vec4(shadowPos.xy + offsets.xy, shadowPos.zw)).r);
            #else
                // float inLight =0;
                // for(int i=0; i<9; i++)
                // {
                //   inLight += textureProj(sShadowMap, vec4(shadowPos.xy + kernel[i] * 0.0008, shadowPos.zw));
                // }
                //
                // return inLight/9;
                return 1-clamp( -1000 * (texture(sShadowMap,shadowPos.xy).r - shadowPos.z),0.0,1.0);//texture(sShadowMap,vec3(shadowPos.xy, 1.0));//cShadowIntensity.y + cShadowIntensity.x * (texture(sShadowMap, shadowPos.xyz));// +
                    //textureProj(sShadowMap, vec4(shadowPos.x + offsets.x , shadowPos.yzw)) +
                    //textureProj(sShadowMap, vec4(shadowPos.x, shadowPos.y + offsets.y, shadowPos.zw)) +
                    //textureProj(sShadowMap, vec4(shadowPos.xy + offsets.xy, shadowPos.zw)));
            #endif
        #else
            // Take one sample
            #ifndef GL3
                float inLight = shadow2DProj(sShadowMap, shadowPos).r;
            #else
                float inLight = textureProj(sShadowMap, shadowPos);
            #endif
            return cShadowIntensity.y + cShadowIntensity.x * inLight;
        #endif
    #else
        #ifndef LQSHADOW
            // Take four samples and average them
            vec2 offsets = cShadowMapInvSize * shadowPos.w;
            vec4 inLight = vec4(
                texture2DProj(sShadowMap, shadowPos).r * shadowPos.w > shadowPos.z,
                texture2DProj(sShadowMap, vec4(shadowPos.x + offsets.x, shadowPos.yzw)).r * shadowPos.w > shadowPos.z,
                texture2DProj(sShadowMap, vec4(shadowPos.x, shadowPos.y + offsets.y, shadowPos.zw)).r * shadowPos.w > shadowPos.z,
                texture2DProj(sShadowMap, vec4(shadowPos.xy + offsets.xy, shadowPos.zw)).r * shadowPos.w > shadowPos.z
            );
            return cShadowIntensity.y + dot(inLight, vec4(cShadowIntensity.x));
        #else
            // Take one sample
            return cShadowIntensity.y + (texture2DProj(sShadowMap, shadowPos).r * shadowPos.w > shadowPos.z ? cShadowIntensity.x : 0.0);
        #endif
    #endif
}

#ifdef POINTLIGHT
float GetPointShadow(vec3 lightVec)
{
    vec3 axis = textureCube(sFaceSelectCubeMap, lightVec).rgb;
    float depth = abs(dot(lightVec, axis));

    // Expand the maximum component of the light vector to get full 0.0 - 1.0 UV range from the cube map,
    // and to avoid sampling across faces. Some GPU's filter across faces, while others do not, and in this
    // case filtering across faces is wrong
    const vec3 factor = vec3(1.0 / 256.0);
    lightVec += factor * axis * lightVec;

    // Read the 2D UV coordinates, adjust according to shadow map size and add face offset
    vec4 indirectPos = textureCube(sIndirectionCubeMap, lightVec);
    indirectPos.xy *= cShadowCubeAdjust.xy;
    indirectPos.xy += vec2(cShadowCubeAdjust.z + indirectPos.z * 0.5, cShadowCubeAdjust.w + indirectPos.w);

    vec4 shadowPos = vec4(indirectPos.xy, cShadowDepthFade.x + cShadowDepthFade.y / depth, 1.0);
    return GetShadow(shadowPos);
}
#endif

#ifdef DIRLIGHT
float GetDirShadowFade(float inLight, float depth)
{
    return min(inLight + max((depth - cShadowDepthFade.z) * cShadowDepthFade.w, 0.0), 1.0);
}

#if !defined(GL_ES) || defined(WEBGL)
float GetDirShadow(const vec4 iShadowPos[NUMCASCADES], float depth)
{
    vec4 shadowPos;

    if (depth < cShadowSplits.x)
        shadowPos = iShadowPos[0];
    else if (depth < cShadowSplits.y)
        shadowPos = iShadowPos[1];
    else if (depth < cShadowSplits.z)
        shadowPos = iShadowPos[2];
    else
        shadowPos = iShadowPos[3];

    return GetDirShadowFade(GetShadow(shadowPos), depth);
}
#else
float GetDirShadow(const vec4 iShadowPos[NUMCASCADES], float depth)
{
    return GetDirShadowFade(GetShadow(iShadowPos[0]), depth);
}
#endif

#ifndef GL_ES
float GetDirShadowDeferred(vec4 projWorldPos, float depth)
{
    vec4 shadowPos;

    if (depth < cShadowSplits.x)
        shadowPos = projWorldPos * cLightMatricesPS[0];
    else if (depth < cShadowSplits.y)
        shadowPos = projWorldPos * cLightMatricesPS[1];
    else if (depth < cShadowSplits.z)
        shadowPos = projWorldPos * cLightMatricesPS[2];
    else
        shadowPos = projWorldPos * cLightMatricesPS[3];

    return GetDirShadowFade(GetShadow(shadowPos), depth);
}
#endif
#endif

float GetShadow(vec4 iShadowPos[NUMCASCADES], float depth)
{
    #if defined(DIRLIGHT)
        return GetDirShadow(iShadowPos, depth);
    #elif defined(SPOTLIGHT)
        return GetShadow(iShadowPos[0]);
    #else
        return GetPointShadow(iShadowPos[0].xyz);
    #endif
}

#ifndef GL_ES
float GetShadowDeferred(vec4 projWorldPos, float depth)
{
    #if defined(DIRLIGHT)
        return GetDirShadowDeferred(projWorldPos, depth);
    #elif defined(SPOTLIGHT)
        vec4 shadowPos = projWorldPos * cLightMatricesPS[1];
        return GetShadow(shadowPos);
    #else
        vec3 shadowPos = projWorldPos.xyz - cLightPosPS.xyz;
        return GetPointShadow(shadowPos);
    #endif
}
#endif
#endif
#endif
