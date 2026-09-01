Shader "Custom/URP/StylizedBeach"
{
    Properties
    {
        [Header(Base Color)]
        _BaseMap ("Albedo", 2D) = "white" {}
        _BaseColor ("Color Tint", Color) = (1, 0.95, 0.8, 1)

        [Header(OrenNayar Diffuse)]
        _Roughness ("Roughness (Sigma)", Range(0, 1)) = 0.85
        _DiffuseBrightness ("Diffuse Brightness", Range(0, 2)) = 1.1

        [Header(Normal Mapping)]
        [Normal] _NormalMapShallow ("Shallow Normal", 2D) = "bump" {}
        [Normal] _NormalMapSteep ("Steep Normal", 2D) = "bump" {}
        _NormalScale ("Overall Normal Scale", Float) = 1.0
        _ShallowBumpScale ("Shallow Bump Scale", Float) = 1.0
        _SteepBumpScale ("Steep Bump Scale", Float) = 1.5
        
        [Header(Specular Highlight)]
        _SpecularColor ("Specular Color", Color) = (1, 0.9, 0.7, 1)
        _Shininess ("Shininess", Range(1, 128)) = 32
        _SpecularIntensity ("Specular Intensity", Range(0, 5)) = 0.5

        [Header(Glitter Effect)]
        _GlitterTex ("Glitter Noise", 2D) = "white" {}
        _GlitterColor ("Glitter Color", Color) = (1, 1, 0.8, 1)
        _GlitterMultiplier ("Glitter Multiplier", Range(1, 50)) = 15
        _GlitterSpeed ("Glitter Speed (XY)", Vector) = (0.1, 0.1, 0, 0)
        _GlitterScale ("Glitter Scale", Float) = 5.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" "Queue"="Geometry" }
        LOD 300

        CGINCLUDE
        float3 LerpWhiteTo(float3 b, float t)
        {
            return lerp(float3(1, 1, 1), b, t);
        }
        ENDCG

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
                float3 viewDirWS : TEXCOORD5;
                float fogFactor : TEXCOORD6;
            };

            // Textures
            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMapShallow); SAMPLER(sampler_NormalMapShallow);
            TEXTURE2D(_NormalMapSteep); SAMPLER(sampler_NormalMapSteep);
            TEXTURE2D(_GlitterTex); SAMPLER(sampler_GlitterTex);

            // Constant Buffer
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _BaseColor;
                float _Roughness;
                float _DiffuseBrightness;
                float _NormalScale;
                float _ShallowBumpScale;
                float _SteepBumpScale;
                float4 _SpecularColor;
                float _Shininess;
                float _SpecularIntensity;
                float4 _GlitterColor;
                float _GlitterMultiplier;
                float2 _GlitterSpeed;
                float _GlitterScale;
            CBUFFER_END

            float OrenNayarDiffuse(float3 lightDir, float3 viewDir, float3 normal, float roughness)
            {

                float VdotN = dot(viewDir, normal);

                float LdotN = saturate(4.0 * dot(lightDir, normal * float3(1, 0.5, 1))); 

                float cos_theta_i = LdotN;
                float theta_r = acos(VdotN);
                float theta_i = acos(cos_theta_i);

                float3 viewProj = normalize(viewDir - normal * VdotN);
                float3 lightProj = normalize(lightDir - normal * LdotN);
                float cos_phi_diff = dot(viewProj, lightProj);

                float alpha = max(theta_i, theta_r);
                float beta = min(theta_i, theta_r);

                float sigma2 = roughness * roughness;
                float A = 1.0 - 0.5 * sigma2 / (sigma2 + 0.33);
                float B = 0.45 * sigma2 / (sigma2 + 0.09);

                float tan_beta = (beta == 0.0) ? 0.0 : tan(beta);
                float finalVal = cos_theta_i * (A + B * saturate(cos_phi_diff) * sin(alpha) * tan_beta);

                return saturate(finalVal);
            }

            float3 GetBlendedNormal(float2 uv, float3 viewDirTan)
            {

                float tempNormalY = saturate(abs(viewDirTan.y));
                float steepness = atan(1.0 / max(0.001, tempNormalY));
                steepness = saturate(steepness / 1.57);

                float3 shallowNormal = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMapShallow, sampler_NormalMapShallow, uv), _ShallowBumpScale);
                float3 steepNormal = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMapSteep, sampler_NormalMapSteep, uv), _SteepBumpScale);

                float3 blendedNormal = lerp(shallowNormal, steepNormal, steepness * _NormalScale);
                return normalize(blendedNormal);
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.tangentWS = TransformObjectToWorldDir(IN.tangentOS.xyz);
                OUT.bitangentWS = cross(OUT.normalWS, OUT.tangentWS) * IN.tangentOS.w;
                OUT.viewDirWS = GetWorldSpaceViewDir(OUT.positionWS);
                OUT.fogFactor = ComputeFogFactor(OUT.positionCS.z);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                Light mainLight = GetMainLight(TransformWorldToShadowCoord(IN.positionWS));
                float3 lightDirWS = normalize(mainLight.direction);
                float3 viewDirWS = normalize(IN.viewDirWS);

                float3x3 TBN = float3x3(IN.tangentWS, IN.bitangentWS, IN.normalWS);
                float3 viewDirTan = mul(TBN, viewDirWS);

                half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;

                float3 normalTS = GetBlendedNormal(IN.uv, viewDirTan);
                float3 normalWS = normalize(mul(normalTS, TBN));

                float diffuseFactor = OrenNayarDiffuse(lightDirWS, viewDirWS, normalWS, _Roughness);

                diffuseFactor = lerp(0.5, 1.0, diffuseFactor) * _DiffuseBrightness;
                half3 diffuse = albedo.rgb * diffuseFactor * mainLight.color;

                half3 ambient = SampleSH(normalWS) * albedo.rgb * 0.4;

                float3 halfDir = normalize(lightDirWS + viewDirWS);
                float specBase = pow(max(0, dot(halfDir, normalWS)), _Shininess);
                float specDetail = pow(max(0, dot(halfDir, normalWS)), _Shininess * 0.5);
                half3 specular = _SpecularColor.rgb * (specBase * specDetail) * _SpecularIntensity;

                float2 glitterUV = IN.uv * _GlitterScale + _Time.y * _GlitterSpeed;
                float2 viewOffset = viewDirTan.xy * 0.005;
                
                float p1 = SAMPLE_TEXTURE2D(_GlitterTex, sampler_GlitterTex, glitterUV + float2(0, _Time.y * 0.0005 + viewOffset.x)).r;
                float p2 = SAMPLE_TEXTURE2D(_GlitterTex, sampler_GlitterTex, glitterUV + float2(_Time.y * 0.001, _Time.y * 0.001 + viewOffset.y)).g;
                
                float glitterSum = p1 * p2;
                float glitter = max(0, pow(glitterSum * _GlitterMultiplier, 2.0) - 0.5);
                glitter = saturate(glitter * 2.0);
                
                half3 glitterColor = glitter * _GlitterColor.rgb * albedo.rgb;

                half3 finalColor = diffuse + ambient + specular + glitterColor;
                finalColor = MixFog(finalColor, IN.fogFactor);

                return half4(finalColor, albedo.a);
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            float3 _LightDirection;

            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output;
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
                return output;
            }

            half4 ShadowPassFragment(Varyings input) : SV_TARGET
            {
                return 0;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            ZWrite On
            ColorMask R
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}