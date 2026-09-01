Shader "Skybox/SelfSkybox_Ocean_Time"
{
    Properties
    {
        [Header(Add Mode)]
        _Test("test", Range(0, 1000)) = 0.15
        [MaterialToggle] _addSunandMoon("Add Sun And Moon", Float) = 0
        [MaterialToggle] _addGradient("Add Gradient", Float) = 0
        [Toggle(ADDCLOUD)] _addCloud("Add Cloud", Float) = 0
        [MaterialToggle] _addStar("Add Star", Float) = 0
        [MaterialToggle] _addHorizon("Add Horizon", Float) = 0
        [Toggle(MIRROR)] _MirrorMode("Mirror Mode", Float) = 0
        [MaterialToggle] _addAtmosphericScattering("Add Atmospheric Scattering", Float) = 0
        [MaterialToggle] _addMorningFog("Add Morning Fog", Float) = 1

        [Header(Sun)]
        _SunColor("Sun Color", Color) = (1,1,1,1)
        _SunRadius("Sun Radius", Range(0, 2)) = 0.1
        _SunBloomTex("Sun Bloom Texture", 2D) = "white" {}
        _SunBloomColor("Sun Bloom Color", Color) = (1, 0.8, 0.6, 1)
        _SunBloomIntensity("Sun Bloom Intensity", Range(0, 10)) = 2.0
        _SunBloomPower("Sun Bloom Power", Range(1, 10)) = 4.0
        _SunBloomSize("Sun Bloom Size", Range(0.1, 5)) = 1.0
        [Header(Sun Horizon Settings)]
        _SunHorizonHeight("Sun Horizon Height", Range(-1, 1)) = 0.0
        _SunHorizonSmooth("Sun Horizon Smoothness", Range(0.01, 0.5)) = 0.1

        [Header(Moon)]
        _MoonColor("Moon Color", Color) = (1,1,1,1)
        _MoonRadius("Moon Radius", Range(0, 2)) = 0.15
        _MoonOffset("Moon Crescent", Range(-1, 1)) = -0.1
        _MoonBloomColor("Moon Bloom Color", Color) = (0.8, 0.9, 1, 1)
        _MoonBloomIntensity("Moon Bloom Intensity", Range(0, 5)) = 1.0
        _MoonBloomPower("Moon Bloom Power", Range(1, 10)) = 3.0
        [Header(Moon Horizon Settings)]
        _MoonHorizonHeight("Moon Horizon Height", Range(-1, 1)) = 0.0
        _MoonHorizonSmooth("Moon Horizon Smoothness", Range(0.01, 0.5)) = 0.1

        [Header(Atmospheric Scattering)]
        _ScatteringIntensity("Scattering Intensity", Range(0, 5)) = 1.0
        _ScatteringPower("Scattering Power", Range(1, 10)) = 4.0
        _RayleighFactor("Rayleigh Factor (Blue)", Range(0, 2)) = 1.0
        _MieFactor("Mie Factor (Red)", Range(0, 2)) = 0.5
        _SunScatteringColor("Sun Scattering Color", Color) = (1.0, 0.6, 0.3, 1.0)
        _MoonScatteringColor("Moon Scattering Color", Color) = (0.5, 0.6, 1.0, 1.0)
        _SkyZenithColor("Sky Zenith Color", Color) = (0.1, 0.2, 0.5, 1.0)
        _SkyHorizonColor("Sky Horizon Color", Color) = (0.5, 0.6, 0.8, 1.0)
        _NightZenithColor("Night Zenith Color", Color) = (0.01, 0.02, 0.05, 1.0)
        _NightHorizonColor("Night Horizon Color", Color) = (0.05, 0.06, 0.1, 1.0)
        _AtmosphereHeight("Atmosphere Height", Range(0, 2)) = 1.0
        _GroundColor("Ground Color", Color) = (0.2, 0.2, 0.2, 1.0)

        [Header(Morning Fog)]
        _FogColor("Fog Color", Color) = (0.95, 0.92, 0.85, 1.0)
        _FogIntensity("Fog Intensity", Range(0, 2)) = 1.2
        _FogHeightFalloff("Fog Height Falloff", Range(0, 5)) = 1.5
        _FogDensity("Fog Density", Range(0, 3)) = 1.5
        _FogNoiseTex("Fog Noise Texture", 2D) = "white" {}
        _FogNoiseScale("Fog Noise Scale", Range(0.1, 5)) = 1.0
        _FogNoiseTiling("Fog Noise Tiling", Range(0.1, 5)) = 1.0
        _FogNoiseSpeed("Fog Noise Speed", Range(0, 2)) = 0.3
        _FogNoiseContrast("Fog Noise Contrast", Range(0.1, 3)) = 1.2
        _FogMorningStart("Fog Morning Start", Range(0, 0.5)) = 0.4
        _FogMorningPeak("Fog Morning Peak", Range(0.4, 0.6)) = 0.45
        _FogMorningEnd("Fog Morning End", Range(0.45, 1)) = 0.6
        _FogSunInfluence("Sun Influence on Fog", Range(0, 3)) = 2.0

        [Header(Cloud)]
        _Cloud("Cloud Texture", 2D) = "black" {}
        _CloudCutoff("Cloud Cutoff", Range(0, 3)) = 0.08
        _CloudSpeed("Cloud Move Speed", Range(-10, 10)) = 0.3
        _CloudScale("Cloud Scale", Range(0, 10)) = 0.3
        _CloudNoise("Cloud Noise", 2D) = "black" {}
        _CloudNoiseScale("Cloud Noise Scale", Range(0, 1)) = 0.2
        _CloudNoiseSpeed("Cloud Noise Speed", Range(-1, 1)) = 0.1
        _DistortTex("Distort Tex", 2D) = "black" {}
        _DistortScale("Distort Noise Scale", Range(0, 1)) = 0.06
        _DistortionSpeed("Distortion Speed", Range(-1, 1)) = 0.1
        _Fuzziness("Cloud Fuzziness", Range(-5, 5)) = 0.04
        _FuzzinessSec("Cloud Fuzziness Sec", Range(-5, 5)) = 0.04
        _CloudColorDayMain("Cloud Day Color Main", Color) = (0.0,0.2,0.1,1)
        _CloudColorDaySec("Clouds Day Color Sec", Color) = (0.6,0.7,0.6,1)
        _CloudColorNightMain("Clouds Night Color Main", Color) = (1,1,1,1)
        _CloudColorNightSec("Cloud Night Color Sec", Color) = (0.0,0.2,0.1,1)
        _CloudBrightnessDay("Cloud Brightness Day", Range(0, 2)) = 1
        _CloudBrightnessNight("Cloud Brightness Night", Range(0, 2)) = 1
        
        [Header(Star)]
        _Stars("Stars Texture", 2D) = "black" {}
        _StarsCutoff("Stars Cutoff", Range(0, 1)) = 0.08
        _StarsSpeed("Stars Move Speed", Range(-10, 10)) = 0.3
        _StarScale("Star Scale", Range(-10, 10)) = 0.3
        _StarsSkyColor("Stars Sky Color", Color) = (0.0,0.2,0.1,1)
            
        [Header(Sky of Day)]
        _DayTopColor("Day Top Color", Color) = (0.4,1,1,1)
        _DayBottomColor("Day Bottom Color", Color) = (0,0.8,1,1)

        [Header(Sky of Night)]
        _NightTopColor("Night Top Color", Color) = (0.4,1,1,1)
        _NightBottomColor("Night Bottom Color", Color) = (0,0.8,1,1)

        [Header(Horizon)]
        _HorizonHeight("Horizon Height", Range(-10,10)) = 10
        _HorizonIntensity("Horizon Intensity", Range(0, 100)) = 3.3
        _MidLightIntensity("Mid Light Intensity", Range(0, 100)) = 3.3
        _HorizonColorDay("Day Horizon Color", Color) = (0,0.8,1,1)
        _HorizonColorNight("Night Horizon Color", Color) = (0,0.8,1,1)
        _HorizonLightDay("Day Horizon Light", Color) = (0,0.8,1,1)
        _HorizonLightNight("Night Horizon Light", Color) = (0,0.8,1,1)
        _HorizonBrightness("Horizon Brightness", Range(-10,10)) = 10
    }

    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque"
            "Queue" = "Background"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }
        Cull Off ZWrite Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature MIRROR
            #pragma shader_feature ADDCLOUD

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 worldNormal : TEXCOORD3;
            };

            TEXTURE2D(_SunBloomTex); SAMPLER(sampler_SunBloomTex);
            TEXTURE2D(_FogNoiseTex); SAMPLER(sampler_FogNoiseTex);
            TEXTURE2D(_Cloud); SAMPLER(sampler_Cloud);
            TEXTURE2D(_CloudNoise); SAMPLER(sampler_CloudNoise);
            TEXTURE2D(_DistortTex); SAMPLER(sampler_DistortTex);
            TEXTURE2D(_Stars); SAMPLER(sampler_Stars);

            CBUFFER_START(UnityPerMaterial)
                // Add Mode
                float _Test;
                float _addSunandMoon;
                float _addGradient;
                float _addCloud;
                float _addStar;
                float _addHorizon;
                float _MirrorMode;
                float _addAtmosphericScattering;
                float _addMorningFog;

                // Sun
                float4 _SunColor;
                float _SunRadius;
                float4 _SunBloomColor;
                float _SunBloomIntensity;
                float _SunBloomPower;
                float _SunBloomSize;
                float4 _SunBloomTex_ST;
                float _SunHorizonHeight;
                float _SunHorizonSmooth;

                // Moon
                float4 _MoonColor;
                float _MoonRadius;
                float _MoonOffset;
                float4 _MoonBloomColor;
                float _MoonBloomIntensity;
                float _MoonBloomPower;
                float _MoonHorizonHeight;
                float _MoonHorizonSmooth;

                // Atmospheric Scattering
                float _ScatteringIntensity;
                float _ScatteringPower;
                float _RayleighFactor;
                float _MieFactor;
                float4 _SunScatteringColor;
                float4 _MoonScatteringColor;
                float4 _SkyZenithColor;
                float4 _SkyHorizonColor;
                float4 _NightZenithColor;
                float4 _NightHorizonColor;
                float _AtmosphereHeight;
                float4 _GroundColor;

                // Morning Fog
                float4 _FogColor;
                float _FogIntensity;
                float _FogHeightFalloff;
                float _FogDensity;
                float4 _FogNoiseTex_ST;
                float _FogNoiseScale;
                float _FogNoiseTiling;
                float _FogNoiseSpeed;
                float _FogNoiseContrast;
                float _FogMorningStart;
                float _FogMorningPeak;
                float _FogMorningEnd;
                float _FogSunInfluence;

                // Cloud
                float4 _Cloud_ST;
                float _CloudCutoff;
                float _CloudSpeed;
                float _CloudScale;
                float4 _CloudNoise_ST;
                float _CloudNoiseScale;
                float _CloudNoiseSpeed;
                float4 _DistortTex_ST;
                float _DistortScale;
                float _DistortionSpeed;
                float _Fuzziness;
                float _FuzzinessSec;
                float4 _CloudColorDayMain;
                float4 _CloudColorDaySec;
                float4 _CloudColorNightMain;
                float4 _CloudColorNightSec;
                float _CloudBrightnessDay;
                float _CloudBrightnessNight;

                // Star
                float4 _Stars_ST;
                float _StarsCutoff;
                float _StarsSpeed;
                float _StarScale;
                float4 _StarsSkyColor;

                // Sky
                float4 _DayTopColor;
                float4 _DayBottomColor;
                float4 _NightTopColor;
                float4 _NightBottomColor;

                // Horizon
                float _HorizonHeight;
                float _HorizonIntensity;
                float _MidLightIntensity;
                float4 _HorizonColorDay;
                float4 _HorizonColorNight;
                float4 _HorizonLightDay;
                float4 _HorizonLightNight;
                float _HorizonBrightness;
            CBUFFER_END

            float smoothstepEdge(float value, float threshold, float smoothness)
            {
                return smoothstep(threshold - smoothness, threshold + smoothness, value);
            }

            float rayleighPhase(float cosTheta)
            {
                return (3.0 / (16.0 * PI)) * (1.0 + cosTheta * cosTheta);
            }

            float miePhase(float cosTheta, float g)
            {
                float g2 = g * g;
                return (1.0 - g2) / (4.0 * PI * pow(abs(1.0 + g2 - 2.0 * g * cosTheta), 1.5));
            }

            float random(float2 st)
            {
                return frac(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float noise(float2 st)
            {
                float2 i = floor(st);
                float2 f = frac(st);
                float a = random(i);
                float b = random(i + float2(1.0, 0.0));
                float c = random(i + float2(0.0, 1.0));
                float d = random(i + float2(1.0, 1.0));
                float2 u = f * f * (3.0 - 2.0 * f);
                return lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
            }

            float2 CalculateFogUV(float3 worldPos, float3 viewDir, float3 worldNormal)
            {
                float2 uv1 = worldPos.xz * 0.01 * _FogNoiseTiling;
                float2 uv2 = float2(
                    atan2(worldNormal.x, worldNormal.z) / (PI * 2.0) + 0.5,
                    asin(worldNormal.y) / PI + 0.5
                ) * _FogNoiseTiling;
                float2 uv3 = viewDir.xz * 2.0 * _FogNoiseTiling;
                float heightFactor = saturate(worldPos.y * 0.1);
                float2 finalUV = lerp(uv1, uv2, heightFactor);
                return lerp(finalUV, uv3, heightFactor * 0.5);
            }

            float3 AtmosphericScattering(float3 viewDir, float3 sunDir, float3 moonDir, float sunY, float moonY, float t)
            {
                float viewDotUp = dot(viewDir, float3(0, 1, 0));
                float viewDotSun = dot(viewDir, sunDir);
                float viewDotMoon = dot(viewDir, moonDir);
                
                float heightGradient = saturate(viewDotUp * 0.5 + 0.5);
                heightGradient = pow(abs(heightGradient), _AtmosphereHeight);
                
                float3 zenithColor = lerp(_NightZenithColor.rgb, _SkyZenithColor.rgb, t);
                float3 horizonColor = lerp(_NightHorizonColor.rgb, _SkyHorizonColor.rgb, t);
                float3 skyColor = lerp(horizonColor, zenithColor, heightGradient);
                
                float rayleigh = rayleighPhase(viewDotSun) * _RayleighFactor;
                float3 rayleighScattering = float3(0.5, 0.7, 1.0) * rayleigh * saturate(sunY);
                
                float mie = miePhase(viewDotSun, 0.76) * _MieFactor;
                float3 mieScattering = _SunScatteringColor.rgb * mie * saturate(sunY);
                
                float moonRayleigh = rayleighPhase(viewDotMoon) * _RayleighFactor * 0.3;
                float3 moonScattering = _MoonScatteringColor.rgb * moonRayleigh * saturate(moonY);
                
                float sunHeightFactor = saturate(sunY + 0.3);
                float scatteringIntensity = pow(abs(1.0 - saturate(viewDotSun)), _ScatteringPower) * sunHeightFactor;
                
                float3 scattering = (rayleighScattering + mieScattering + moonScattering) * scatteringIntensity * _ScatteringIntensity;
                float groundFactor = saturate(-viewDotUp);
                float3 groundColor = _GroundColor.rgb * groundFactor;
                
                return skyColor + scattering - groundColor * 0.5;
            }

            float3 calculateSunMoonGlow(float3 viewDir, float3 sunDir, float3 moonDir, float sunVisible, float moonVisible, float t)
            {
                float viewDotSun = dot(viewDir, sunDir);
                float viewDotMoon = dot(viewDir, moonDir);
                
                float sunGlow = pow(saturate(viewDotSun), 32.0) * 2.0;
                sunGlow += pow(saturate(viewDotSun), 128.0) * 5.0;
                float3 sunGlowColor = sunGlow * _SunScatteringColor.rgb * sunVisible * t;
                
                float moonGlow = pow(saturate(viewDotMoon), 16.0) * 0.5;
                float3 moonGlowColor = moonGlow * _MoonScatteringColor.rgb * moonVisible * (1.0 - t);
                
                return sunGlowColor + moonGlowColor;
            }

            float3 CalculateMorningFog(float3 viewDir, float3 worldPos, float3 worldNormal, float3 sunDir, float sunY, float sunVisible, float t)
            {
                if (_addMorningFog < 0.5) return 0;
                
                float sunHeightFactor = saturate(1.0 - abs(sunY) * 2.0);
                float fogTimeFactor = 0.0;
                
                if (sunY > -0.2 && sunY < 0.2)
                {
                    fogTimeFactor = 1.0 - abs(sunY) * 5.0;
                    fogTimeFactor = saturate(fogTimeFactor);
                    fogTimeFactor = pow(abs(fogTimeFactor), 0.7);
                }
                
                if (fogTimeFactor <= 0.001) return 0;
                
                float viewDotUp = dot(viewDir, float3(0, 1, 0));
                float heightFactor = saturate(viewDotUp * 0.5 + 0.5);
                float heightAttenuation = 1.0 - pow(abs(heightFactor), _FogHeightFalloff);
                
                float3 fogColor = _FogColor.rgb;
                if (sunVisible > 0.1)
                {
                    float sunAngleEffect = saturate(1.0 - sunY * 2.0);
                    sunAngleEffect = pow(abs(sunAngleEffect), 1.5);
                    float viewDotSun = dot(viewDir, sunDir);
                    float viewSunEffect = pow(saturate(viewDotSun + 0.3), 3.0) * sunVisible;
                    float3 sunFogColor = _SunScatteringColor.rgb * 1.2;
                    float sunColorBlend = saturate(sunAngleEffect * viewSunEffect * _FogSunInfluence);
                    fogColor = lerp(_FogColor.rgb, sunFogColor, sunColorBlend);
                    float sunHeightEffect = saturate(sunY + 0.2);
                    fogTimeFactor *= (1.0 - sunHeightEffect * 0.5);
                }
                
                float2 fogUV = CalculateFogUV(worldPos, viewDir, worldNormal);
                fogUV += _Time.y * _FogNoiseSpeed * 0.1;
                
                float fogNoise1 = SAMPLE_TEXTURE2D(_FogNoiseTex, sampler_FogNoiseTex, fogUV * _FogNoiseScale).r;
                float fogNoise2 = SAMPLE_TEXTURE2D(_FogNoiseTex, sampler_FogNoiseTex, fogUV * _FogNoiseScale * 1.7 + float2(0.3, 0.7)).g;
                float fogNoise3 = SAMPLE_TEXTURE2D(_FogNoiseTex, sampler_FogNoiseTex, fogUV * _FogNoiseScale * 0.5 - float2(0.2, 0.5)).b;
                
                float combinedNoise = (fogNoise1 * 0.5 + fogNoise2 * 0.3 + fogNoise3 * 0.2);
                combinedNoise = saturate(pow(abs(combinedNoise), _FogNoiseContrast));
                
                float proceduralNoise = noise(fogUV * 3.0 + _Time.y * 0.05) * 0.3 + 0.7;
                combinedNoise *= proceduralNoise;
                
                float baseFogDensity = _FogDensity * fogTimeFactor * heightAttenuation * _FogIntensity;
                float fogDensity = saturate(baseFogDensity * combinedNoise);
                float fogAlpha = pow(abs(fogDensity), 0.8);
                
                return fogColor * fogAlpha * 1.2;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                o.viewDir = normalize(TransformObjectToWorldDir(v.vertex.xyz));
                o.worldNormal = normalize(v.vertex.xyz);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                Light mainLight = GetMainLight();
                float3 sunDir = normalize(mainLight.direction);
                float sunY = sunDir.y;
                float3 moonDir = normalize(-sunDir);
                float moonY = moonDir.y;
                float t = saturate(sunY * 0.5 + 0.5);
                
                float sunVisible = smoothstepEdge(sunY, _SunHorizonHeight, _SunHorizonSmooth);
                float moonVisible = smoothstepEdge(moonY, _MoonHorizonHeight, _MoonHorizonSmooth);

                #if defined(MIRROR)
                    float ypos = saturate(abs(i.uv.y));
                #else
                    float ypos = saturate(i.uv.y);
                #endif
                float3 gradientDay = lerp(_DayBottomColor.rgb, _DayTopColor.rgb, ypos);
                float3 gradientNight = lerp(_NightBottomColor.rgb, _NightTopColor.rgb, ypos);

                float3 viewDir = normalize(i.uv.xyz);
                float sunDist = distance(i.uv.xyz, sunDir);
                float sunDisc = saturate((1 - sunDist / _SunRadius) * 50) * sunVisible;
                
                float3 tangent = normalize(cross(sunDir, float3(0, 1, 0)));
                float3 bitangent = cross(sunDir, tangent);
                float2 bloomUV = float2(
                    dot(viewDir, tangent) / _SunBloomSize + 0.5,
                    dot(viewDir, bitangent) / _SunBloomSize + 0.5
                );
                float4 sunBloomTex = SAMPLE_TEXTURE2D(_SunBloomTex, sampler_SunBloomTex, TRANSFORM_TEX(bloomUV, _SunBloomTex));
                float sunBloomMask = pow(saturate(dot(viewDir, sunDir)), _SunBloomPower) * sunVisible;
                float3 sunBloom = sunBloomTex.rgb * sunBloomTex.a * _SunBloomColor.rgb * _SunBloomIntensity * sunBloomMask;

                float moonDist = distance(i.uv.xyz, moonDir);
                float moonDisc = saturate((1 - moonDist / _MoonRadius) * 50) * moonVisible;
                float3 moonTangent = normalize(float3(-moonDir.y, 0, moonDir.x));
                float3 crescentOffset = moonTangent * _MoonOffset * _MoonRadius * 0.8;
                float crescentMoon = distance(i.uv.xyz + crescentOffset, moonDir);
                float crescentMoonDisc = saturate((1 - crescentMoon / _MoonRadius) * 50) * moonVisible;
                moonDisc = saturate(moonDisc - crescentMoonDisc);
                
                float moonBloomMask = pow(saturate(dot(viewDir, moonDir)), _MoonBloomPower) * moonVisible;
                float3 moonBloom = moonBloomMask * _MoonBloomColor.rgb * _MoonBloomIntensity;
                
                float3 SunAndMoon = (sunDisc * _SunColor.rgb + sunBloom) * t + (moonDisc * _MoonColor.rgb + moonBloom) * (1.0 - t);

                float3 atmosphericScattering = 0;
                float3 celestialGlow = 0;
                if (_addAtmosphericScattering > 0.5)
                {
                    atmosphericScattering = AtmosphericScattering(viewDir, sunDir, moonDir, sunY, moonY, t);
                    celestialGlow = calculateSunMoonGlow(viewDir, sunDir, moonDir, sunVisible, moonVisible, t);
                }

                float3 morningFog = CalculateMorningFog(viewDir, i.worldPos, i.worldNormal, sunDir, sunY, sunVisible, t);

                float2 skyuv = i.worldPos.xz / max(clamp(i.worldPos.y, 0.001, 10000), 0.001);
                float cloud = SAMPLE_TEXTURE2D(_Cloud, sampler_Cloud, (skyuv + _Time.x * _CloudSpeed) * _CloudScale).r;
                float distort = SAMPLE_TEXTURE2D(_DistortTex, sampler_DistortTex, (skyuv + _Time.x * _DistortionSpeed) * _DistortScale).r;
                float cloudNoise = SAMPLE_TEXTURE2D(_CloudNoise, sampler_CloudNoise, ((skyuv + distort) - _Time.x * _CloudSpeed) * _CloudNoiseScale).r;
                float finalNoise = saturate(cloudNoise) * 3 * saturate(i.worldPos.y);
                cloud = saturate(smoothstep(_CloudCutoff * cloud, _CloudCutoff * cloud + _Fuzziness, finalNoise));
                float cloudSec = saturate(smoothstep(_CloudCutoff * cloud, _CloudCutoff * cloud + _Fuzziness + _FuzzinessSec, finalNoise));
                
                float3 cloudColoredDay = cloud * _CloudColorDayMain.rgb * _CloudBrightnessDay + cloudSec * _CloudColorDaySec.rgb * _CloudBrightnessDay;
                float3 cloudColoredNight = cloud * _CloudColorNightMain.rgb * _CloudBrightnessNight + cloudSec * _CloudColorNightSec.rgb * _CloudBrightnessNight;
                float3 finalcloud = lerp(cloudColoredNight, cloudColoredDay, t);

                if (_addMorningFog > 0.5 && length(morningFog) > 0.01)
                {
                    float2 fogUV = CalculateFogUV(i.worldPos, viewDir, i.worldNormal);
                    float localFogNoise = SAMPLE_TEXTURE2D(_FogNoiseTex, sampler_FogNoiseTex, fogUV * _FogNoiseScale * 2.0).r;
                    finalcloud = lerp(finalcloud, morningFog * 0.8, length(morningFog) * 0.5 * localFogNoise);
                    finalcloud += morningFog * length(morningFog) * 0.4 * localFogNoise;
                }

                float3 stars = SAMPLE_TEXTURE2D(_Stars, sampler_Stars, (skyuv + float2(_StarsSpeed, _StarsSpeed) * _Time.x) * _StarScale).rgb;
                stars = step(_StarsCutoff, stars) * (1 - t);
                #if defined(ADDCLOUD)
                    stars *= (1 - cloud);
                #endif
                if (_addAtmosphericScattering > 0.5) stars *= (1.0 - saturate(length(atmosphericScattering) * 0.5));
                if (_addMorningFog > 0.5 && length(morningFog) > 0.01)
                {
                    float2 fogUV = CalculateFogUV(i.worldPos, viewDir, i.worldNormal);
                    float localFogNoise = SAMPLE_TEXTURE2D(_FogNoiseTex, sampler_FogNoiseTex, fogUV * _FogNoiseScale * 1.5).g;
                    stars *= (1.0 - length(morningFog) * 0.9 * localFogNoise);
                }

                float3 horizon = saturate(1 - abs(i.uv.y * _HorizonIntensity - _HorizonHeight)) * 
                                ((_HorizonColorDay.rgb + saturate(1 - abs(i.uv.y * _HorizonIntensity - _HorizonHeight) * _MidLightIntensity) * _HorizonLightDay.rgb) * t +
                                 (_HorizonColorNight.rgb + saturate(1 - abs(i.uv.y * _HorizonIntensity - _HorizonHeight) * _MidLightIntensity) * _HorizonLightNight.rgb) * (1 - t)) * _HorizonBrightness;
                if (_addAtmosphericScattering > 0.5) horizon += atmosphericScattering * saturate(1.0 - abs(i.uv.y) * 5.0) * 0.5;
                if (_addMorningFog > 0.5 && length(morningFog) > 0.01)
                {
                    float2 fogUV = CalculateFogUV(i.worldPos, viewDir, i.worldNormal);
                    float localFogNoise = SAMPLE_TEXTURE2D(_FogNoiseTex, sampler_FogNoiseTex, fogUV * _FogNoiseScale * 1.2).r;
                    horizon = lerp(horizon, morningFog * 1.2, length(morningFog) * saturate(1.0 - abs(i.uv.y) * 2.0) * 0.7 * localFogNoise);
                }

                float3 combined = horizon * _addHorizon 
                                + stars * _addStar * _StarsSkyColor.rgb 
                                + lerp(gradientNight, gradientDay, t) * _addGradient
                                + SunAndMoon * _addSunandMoon
                                + finalcloud * _addCloud
                                + celestialGlow * _addAtmosphericScattering;

                if (_addMorningFog > 0.5 && length(morningFog) > 0.01)
                {
                    float2 fogUV = CalculateFogUV(i.worldPos, viewDir, i.worldNormal);
                    float localFogNoise = SAMPLE_TEXTURE2D(_FogNoiseTex, sampler_FogNoiseTex, fogUV * _FogNoiseScale).r;
                    combined = lerp(combined, morningFog, length(morningFog) * 0.8 * localFogNoise);
                    combined += morningFog * length(morningFog) * 0.3 * localFogNoise;
                }
                
                return half4(combined.xyz, 1.0);
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/Skybox"
}