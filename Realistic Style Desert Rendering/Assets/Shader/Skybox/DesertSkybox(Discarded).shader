Shader "Custom/DesertSkybox"
{
    Properties
    {
        _Exposure ("Overall Exposure", Range(0.1, 2.0)) = 0.6
        _HighlightsExposure ("Highlights Exposure", Range(0.1, 1.0)) = 0.4

        _SunRadius ("Sun Radius", Range(0.001, 0.1)) = 0.02
        _MoonRadius ("Moon Radius", Range(0.001, 0.1)) = 0.015
        _SunColor ("Sun Color", Color) = (0.9,0.75,0.5,1)
        _MoonColor ("Moon Color", Color) = (0.6,0.65,0.8,1)

        _DayBottomColor ("Day Bottom", Color) = (0.35,0.45,0.7,1)
        _DayMidColor    ("Day Mid",    Color) = (0.15,0.3,0.6,1)
        _DayTopColor    ("Day Top",    Color) = (0.02,0.1,0.4,1)
        _NightBottomColor ("Night Bottom", Color) = (0.02,0.03,0.06,1)
        _NightMidColor    ("Night Mid",    Color) = (0.01,0.015,0.04,1)
        _NightTopColor    ("Night Top",    Color) = (0.002,0.005,0.015,1)

        _HorizonHeight ("Horizon Height", Range(-0.2,0.2)) = 0.0
        _HorizonIntensity ("Horizon Intensity", Range(1,20)) = 8
        _MidLightIntensity ("Mid Light Intensity", Range(0,5)) = 2
        _HorizonBrightness ("Horizon Brightness", Range(0,2)) = 0.6
        _HorizonColorDay ("Horizon Day", Color) = (0.7,0.6,0.4,1)
        _HorizonColorNight ("Horizon Night", Color) = (0.15,0.18,0.3,1)
        _HorizonLightDay ("Horizon Glow Day", Color) = (0.6,0.3,0.15,1)
        _HorizonLightNight ("Horizon Glow Night", Color) = (0.2,0.25,0.5,1)

        _SunBloom ("Sun Bloom Color", Color) = (0.6,0.4,0.2,1)
        _BloomPower ("Bloom Power", Range(1,32)) = 12

        _CloudShapeTex ("Cloud Shape", 2D) = "white" {}
        _DistorTex ("Cloud Distort", 2D) = "white" {}
        _CloudNoise ("Cloud Detail Noise", 2D) = "white" {}
        _CloudSpeed ("Cloud Flow Speed", Range(0,0.2)) = 0.02
        _DistorTexSpeed ("Distort Speed", Range(0,0.2)) = 0.01
        _DistorTexScale ("Distort Scale", Range(0.1,5)) = 1
        _CloudNoiseScale ("Detail Scale", Range(0.1,5)) = 1
        _CloudCutoff ("Cloud Cutoff", Range(0,1)) = 0.55
        _CloudCutoffTwo ("Cloud Cutoff 2", Range(0,1)) = 0.4
        _CloudSmooth ("Cloud Smooth", Range(0,0.5)) = 0.1
        _CloudLevel ("Cloud Level Bias", Range(0,1)) = 0.15
        _FirstCloudColor ("Cloud1 Day", Color) = (0.75,0.75,0.8,1)
        _SecondCloudColor ("Cloud2 Day", Color) = (0.6,0.65,0.8,1)
        _FirstCloudColorN ("Cloud1 Night", Color) = (0.2,0.22,0.35,1)
        _SecondCloudColorN ("Cloud2 Night", Color) = (0.15,0.18,0.3,1)
        _FirstCloudBrightColor ("Cloud1 Bright", Range(0,1.5)) = 0.7
        _SecondCloudBrightColor ("Cloud2 Bright", Range(0,1.5)) = 0.5
        _FirstCloudBrightColorN ("Cloud1 Bright N", Range(0,1.5)) = 0.4
        _SecondCloudBrightColorN ("Cloud2 Bright N", Range(0,1.5)) = 0.3

        _FlareTex ("Lens Flare", 2D) = "white" {}
        _FlareIntensity ("Flare Intensity", Range(0,1.5)) = 0.4
    }

    SubShader
    {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
        Pass
        {
            ZWrite Off Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata { float4 vertex : POSITION; };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.vertex.xyz;
                return o;
            }

            float _Exposure, _HighlightsExposure;

            float _SunRadius, _MoonRadius, _HorizonHeight, _HorizonIntensity, _MidLightIntensity, _HorizonBrightness;
            float _BloomPower, _CloudSpeed, _DistorTexSpeed, _DistorTexScale, _CloudNoiseScale;
            float _CloudCutoff, _CloudCutoffTwo, _CloudSmooth, _CloudLevel, _FlareIntensity;
            float3 _SunColor, _MoonColor;
            float3 _DayBottomColor, _DayMidColor, _DayTopColor;
            float3 _NightBottomColor, _NightMidColor, _NightTopColor;
            float3 _HorizonColorDay, _HorizonColorNight, _HorizonLightDay, _HorizonLightNight, _SunBloom;
            float3 _FirstCloudColor, _SecondCloudColor, _FirstCloudColorN, _SecondCloudColorN;
            float _FirstCloudBrightColor, _SecondCloudBrightColor, _FirstCloudBrightColorN, _SecondCloudBrightColorN;
            sampler2D _CloudShapeTex, _DistorTex, _CloudNoise, _FlareTex;

            float3 ACESToneMapping(float3 color, float adaptedLit)
            {
                float a = 2.51;
                float b = 0.03;
                float c = 2.43;
                float d = 0.59;
                float e = 0.14;
                return saturate((color * (a * color + b)) / (color * (c * color + d) + e));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 dir = normalize(i.uv);
                float dayFactor = saturate(_WorldSpaceLightPos0.y * 10);
                float nightFactor = saturate(-_WorldSpaceLightPos0.y * 10);

                float sun = distance(dir, normalize(_WorldSpaceLightPos0.xyz));
                float sunDisc = 1 - smoothstep(0.7, 1.0, sun / _SunRadius);
                sunDisc = min(sunDisc, 0.8);

                float moon = distance(dir, normalize(-_WorldSpaceLightPos0.xyz));
                float moonDisc = 1 - smoothstep(0.7, 1.0, moon / _MoonRadius);
                moonDisc = min(moonDisc, 0.6);

                float h = saturate(dir.y);
                float3 gradientDay = lerp(lerp(_DayBottomColor, _DayMidColor, h), _DayTopColor, h);
                float3 gradientNight = lerp(lerp(_NightBottomColor, _NightMidColor, h), _NightTopColor, h);
                float3 sky = lerp(gradientNight, gradientDay, dayFactor);

                sky *= 0.7;

                float horizonLine = abs(dir.y * _HorizonIntensity - _HorizonHeight);
                float midline = saturate(1 - horizonLine * _MidLightIntensity);
                float3 horizonCol =
                    saturate(1 - horizonLine) *
                    ((_HorizonColorDay + midline * _HorizonLightDay) * dayFactor +
                     (_HorizonColorNight + midline * _HorizonLightNight) * nightFactor) *
                    _HorizonBrightness;
                sky = lerp(sky, horizonCol, saturate(1 - abs(dir.y) * 6.0) * 0.5);

                float bloomMask = pow(saturate(dot(normalize(_WorldSpaceLightPos0.xyz), dir)), _BloomPower);
                bloomMask = min(bloomMask, 0.3);
                float3 bloomColor = lerp(_SunBloom, gradientDay, h) * bloomMask;
                sky += bloomColor * _HighlightsExposure;

                float2 skyuv = dir.xz / clamp(dir.y, 0.001, 10000);
                float3 shape = tex2D(_CloudShapeTex, skyuv + float2(_CloudSpeed, _CloudSpeed) * _Time.x);
                float distort = tex2D(_DistorTex, (skyuv + _Time.x * _DistorTexSpeed) * _DistorTexScale);
                float noise = tex2D(_CloudNoise, ((skyuv + distort) - _Time.x * _CloudSpeed) * _CloudNoiseScale);
                float finalNoise = saturate(noise) * 2.5 * saturate(dir.y);
                float cloud = saturate(smoothstep(_CloudCutoff, _CloudCutoff + _CloudSmooth, finalNoise));
                float cloudLevel = saturate(smoothstep(_CloudCutoffTwo, _CloudCutoffTwo + _CloudSmooth + _CloudLevel, finalNoise));

                float3 cloudDay = cloud * _FirstCloudColor * _FirstCloudBrightColor
                               + cloudLevel * _SecondCloudColor * _SecondCloudBrightColor;
                float3 cloudNight = cloud * _FirstCloudColorN * _FirstCloudBrightColorN
                                 + cloudLevel * _SecondCloudColorN * _SecondCloudBrightColorN;
                float3 finalCloud = lerp(cloudNight, cloudDay, dayFactor);
                sky = lerp(sky, finalCloud, cloud * saturate(dir.y * 3) * 0.8); 

                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float flareAxis = dot(dir, lightDir);
                float2 flareUV = float2(flareAxis * 0.5 + 0.5, 0.5);
                float4 flare = tex2D(_FlareTex, flareUV);
                float flareMask = saturate(flareAxis * 2.0 + 0.5);
                sky += flare.rgb * flare.a * _FlareIntensity * dayFactor * flareMask * 0.5;

                sky += _SunColor * saturate(sunDisc) * _HighlightsExposure;
                sky += _MoonColor * saturate(moonDisc) * _HighlightsExposure * 0.7;

                sky *= _Exposure;

                sky = ACESToneMapping(sky, 1.0);

                sky = pow(sky, 0.95);

                return fixed4(sky, 1);
            }
            ENDCG
        }
    }

    FallBack "Skybox/Cubemap"
}