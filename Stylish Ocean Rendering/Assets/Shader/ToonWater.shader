Shader "Custom/toon_water"
{
    Properties
    {
        [HideInInspector] _Foam_Distort_Noise("foam distort noise", 2D) = "white" {}

        [HideInInspector] _Ripple01_Size ("Ripple 01 Size", Float) = 10
        [HideInInspector] _Ripple01_Speed ("Ripple 01 Speed", Float) = 4
        [HideInInspector] _Ripple01_Amplitude ("Ripple 01 Amplitude", Float) = 0.5
        [HideInInspector] _Ripple01_Frequency ("Ripple 01 Frequency", Float) = 2
        
        [HideInInspector] _Ripple02_Size ("Ripple 02 Size", Float) = 10
        [HideInInspector] _Ripple02_Speed ("Ripple 02 Speed", Float) = 4
        [HideInInspector] _Ripple02_Amplitude ("Ripple 02 Amplitude", Float) = 0.5
        [HideInInspector] _Ripple02_Frequency ("Ripple 02 Frequency", Float) = 2
    }
    
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 200

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma shader_feature _SMOOTHNESS_ONEMINUS
            #pragma enable_d3d11_debug_symbols
            #pragma multi_compile _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment __SCREEN_SPACE_OCCLUSION
            #pragma multi_compile __ADDITIONAL_LIGHTS_VERTEX ADDITIONAL_LIGHTS
            #pragma multi_compile __ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment __SHADOWS_SOFT
            #pragma multi_compile_fog
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            float _Ripple01_Size;
            float _Ripple01_Speed;
            float _Ripple01_Amplitude;
            float _Ripple01_Frequency;

            float _Ripple02_Size;
            float _Ripple02_Speed;
            float _Ripple02_Amplitude;
            float _Ripple02_Frequency;

            float _specular;
            float _metallic;
            float _smoothness;
            float _normal_strength;
            float _max_visibility;
            float _refractive_strength;
            float _reflective_distort;
            float _sss_strength;
            float _sss_distort;
            float _sss_power;
            float _sss_scale;
            float3 _foam_color;
            float _foam_scope;
            float _foam_01_width;
            float _foam_01_interval;
            float _foam_01_speed;
            float _foam_01_distort_noise_scale;
            float _foam_02_width;
            float _foam_02_distort_strength;

            TEXTURE2D(_CameraDepthTexture);
            TEXTURE2D(_Water_Absorption_Scatter_Map);
            TEXTURE2D(_CameraOpaqueTexture);
            TEXTURE2D(_Planar_Reflection_Texture);

            struct custom_surfaceData
            {
                half3 albedo;
                half3 specular;
                half metallic;
                half smoothness;
                half3 normalTS;
                half occlusion;
            };

            struct custom_inputData
            {
                float3 positionWS;
                float4 positionCS;
                half3 normalWS;
                half3 viewDirectionWS;
                float2 normalizedScreenSpaceUV;
                half3x3 tangentToWorld;
                float4 shadowCoord;
                half3 bakeGI;
            };

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                half4 tangentWS : TEXCOORD3;
                float4 shadowCoord : TEXCOORD4;
                float fogFactor : TEXCOORD5;
                float4 positionCS : SV_POSITION;
            };

            float CalculateWaveHeight(float2 worldXZ, float time)
            {
                float ripple1 = _Ripple01_Amplitude * sin(
                    (worldXZ.x * _Ripple01_Frequency / _Ripple01_Size + 
                     worldXZ.y * _Ripple01_Frequency / _Ripple01_Size) + 
                    time * _Ripple01_Speed
                );

                float ripple2 = _Ripple02_Amplitude * sin(
                    (worldXZ.x * _Ripple02_Frequency / _Ripple02_Size + 
                     worldXZ.y * _Ripple02_Frequency / _Ripple02_Size) + 
                    time * _Ripple02_Speed
                );

                return ripple1 + ripple2;
            }

            float3 CalculateNormalFromWave(float2 worldXZ, float time)
            {
                float delta = 0.01;
                float height = CalculateWaveHeight(worldXZ, time);
                
                float heightX = CalculateWaveHeight(worldXZ + float2(delta, 0), time);
                float heightZ = CalculateWaveHeight(worldXZ + float2(0, delta), time);
                
                float3 tangent = float3(delta, heightX - height, 0);
                float3 bitangent = float3(0, heightZ - height, delta);
                
                return normalize(cross(tangent, bitangent));
            }

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float2 worldXZ = positionWS.xz;
                float time = _Time.y;

                float waveHeight = CalculateWaveHeight(worldXZ, time);

                float3 positionOS = input.positionOS.xyz;
                positionOS.y += waveHeight;

                float3 normalOS = CalculateNormalFromWave(worldXZ, time);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(positionOS);
                VertexNormalInputs normalInput = GetVertexNormalInputs(normalOS, input.tangentOS);

                output.uv = input.texcoord;
                output.normalWS = normalInput.normalWS;
                output.tangentWS = float4(normalInput.tangentWS, input.tangentOS.w);
                output.positionWS = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                output.shadowCoord = GetShadowCoord(vertexInput);
                output.fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

                return output;
            }

            custom_surfaceData Create_SurfaceData(
                float3 in_albedo,
                float in_specular,
                float in_metallic,
                float in_smoothness,
                float3 in_normalTS)
            {
                custom_surfaceData output = (custom_surfaceData)0;
                output.albedo = half3(in_albedo);
                output.specular = half3(in_specular, in_specular, in_specular);
                output.metallic = half(in_metallic);
                output.smoothness = half(in_smoothness);
                output.normalTS = half3(in_normalTS);
                output.occlusion = 1.0h;
                return output;
            }

            custom_inputData Create_InputData(Varyings input, custom_surfaceData surfaceData)
            {
                custom_inputData output = (custom_inputData)0;
                float crossSign = (input.tangentWS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale();
                float3 normalWS = float3(input.normalWS);
                float3 tangentWS = float3(input.tangentWS.xyz);
                float3 bitangent = crossSign * cross(normalWS, tangentWS);
                
                output.positionWS = input.positionWS;
                output.tangentToWorld = half3x3(tangentWS, bitangent, normalWS);
                output.normalWS = half3(TransformTangentToWorld(float3(surfaceData.normalTS), output.tangentToWorld));
                output.normalWS = normalize(output.normalWS);
                output.viewDirectionWS = half3(GetWorldSpaceNormalizeViewDir(input.positionWS));
                output.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
                output.positionCS = input.positionCS;
                output.shadowCoord = input.shadowCoord;
                output.bakeGI = half3(half(unity_SHAr.w), half(unity_SHAg.w), half(unity_SHAb.w));
                return output;
            }

            float4 Calculate_Foam(float depth, float2 texcoord)
            {
                float foam_scope = 1.0f - saturate(depth / _foam_scope);
                float foam_1 = _foam_01_width * sin(_foam_01_interval * depth - _Time.y * _foam_01_speed);
                foam_1 = step(1.0f, foam_1);
                foam_1 *= saturate(0.5f * 2.0f - 1.0f);
                foam_1 = step(0.1f, foam_1);
                
                float foam_2 = 1.0f - saturate((depth + sin(0.5f * 2.0f * PI) * _foam_02_distort_strength) / _foam_02_width);
                foam_2 = step(0.1f, foam_2);
                
                float foam = saturate(foam_1 + foam_2);
                foam *= foam_scope;
                return float4(foam * _foam_color, foam);
            }

            float3 Calculate_SSS(float depth, Light light, custom_inputData input_data)
            {
                float3 L = light.direction;
                float3 V = float3(input_data.viewDirectionWS);
                float3 N = float3(input_data.normalWS);
                float3 H = normalize(L + N * _sss_distort);
                float VdotH = pow(saturate(dot(V, -H)), _sss_power) * _sss_scale;
                float d = depth / _max_visibility;
                float3 I = _sss_strength * (VdotH + float3(input_data.bakeGI)) * d;
                float4 color_ramp = SAMPLE_TEXTURE2D(_Water_Absorption_Scatter_Map, sampler_PointClamp, float2(depth / _max_visibility, 0.75f));
                return light.color * I * color_ramp.rgb;
            }

            float3 Calculate_Reflection(custom_inputData input_data)
            {
                float3 WS_vertex_normal = TransformTangentToWorldDir(float3(0, 0, 1), input_data.tangentToWorld);
                float3 VS_vertex_normal = TransformWorldToViewDir(WS_vertex_normal);
                float3 VS_normal = TransformWorldToViewDir(float3(input_data.normalWS));
                float2 sceneUV_distort = (VS_vertex_normal.xy - VS_normal.xy) * _reflective_distort;
                float3 reflect_color = SAMPLE_TEXTURE2D(_Planar_Reflection_Texture, sampler_LinearRepeat, input_data.normalizedScreenSpaceUV + sceneUV_distort).rgb;
                return reflect_color;
            }

            float3 Calculate_Refraction(float depth, custom_inputData input_data)
            {
                float3 output;
                float4 color_ramp = SAMPLE_TEXTURE2D(_Water_Absorption_Scatter_Map, sampler_PointClamp, float2(depth / _max_visibility, 0.25f));
                float air_ior = 1.0f;
                float water_ior = 1.33f;
                float3 normal_VS = normalize(TransformWorldToViewDir(float3(input_data.normalWS)));
                float2 sceneUV_distort = input_data.normalizedScreenSpaceUV + normal_VS.xy * (water_ior - air_ior) * saturate((depth * 1.0f / _max_visibility)) * _refractive_strength * 0.05f;
                float3 scene_color = SAMPLE_TEXTURE2D_LOD(_CameraOpaqueTexture, sampler_LinearRepeat, sceneUV_distort, 0).rgb;
                output = lerp(scene_color, color_ramp.rgb, color_ramp.a);
                return output;
            }

            float2 Calculate_Depth(custom_inputData input_data)
            {
                float3 position_VS = TransformWorldToView(input_data.positionWS);
                float d = length(position_VS.xyz / position_VS.z);
                float rawD = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_LinearClamp, input_data.normalizedScreenSpaceUV);
                float bottom_depth_VS = LinearEyeDepth(rawD, _ZBufferParams) * d;
                float water_depth_VS = length(GetCameraPositionWS().xyz - input_data.positionWS);
                float diff_depth_VS = abs(bottom_depth_VS - water_depth_VS);
                return float2(diff_depth_VS, 0.0f);
            }

            half3 Simple_Specular_BRDF(custom_inputData input_data, custom_surfaceData surface_data, Light main_light)
            {
                float NdotL = saturate(dot(input_data.normalWS, main_light.direction));
                float3 halfDir = SafeNormalize(main_light.direction + float3(input_data.viewDirectionWS));
                float NdotH = dot(float3(input_data.normalWS), halfDir);
                float NdotV = dot(float3(input_data.normalWS), float3(input_data.viewDirectionWS));
                half3 radiance = half3(main_light.color) * half(main_light.distanceAttenuation * main_light.shadowAttenuation * NdotL);
                float denominator = 4.0f * saturate(NdotL) * saturate(NdotV) + 0.0001f;
                float smoothness = float(surface_data.smoothness);
                float d1 = (2.0f / (smoothness * smoothness + 0.000001f)) - 2.0f;
                float d2 = 1.0f / (PI * smoothness * smoothness + 0.000001f);
                float D = d2 * pow(saturate(NdotH), d1);
                float3 specularColor = float3(surface_data.specular);
                float F = specularColor.r + (1.0f - specularColor.r) * pow(saturate(1.0f - dot(float3(input_data.viewDirectionWS), halfDir)), 5.0f);
                float g1 = smoothness * 2.0f / PI;
                float gl = saturate(NdotL) * (1.0f - g1) + g1;
                float gv = saturate(NdotV) * (1.0f - g1) + g1;
                float G = (1.0f / (gl * gv + 1e-5f)) * 0.25f;
                float specular = D * F * G / denominator;
                half3 output = radiance * half(specular);
                return output;
            }

            void frag(Varyings IN, out half4 finalColor : SV_Target0)
            {
                float3 normalTS = float3(0, 0, 1);
                custom_surfaceData surface_data = Create_SurfaceData(
                    float3(0.5f, 0.5f, 0.5f),
                    _specular,
                    _metallic,
                    _smoothness,
                    normalTS
                );

                custom_inputData input_data = Create_InputData(IN, surface_data);
                Light mainLight = GetMainLight(TransformWorldToShadowCoord(IN.positionWS));
                float depth = Calculate_Depth(input_data).r;
                float3 refraction = Calculate_Refraction(depth, input_data);
                float3 reflection = Calculate_Reflection(input_data);
                float Fresnel = saturate(pow(1.0f - dot(float3(input_data.normalWS), float3(input_data.viewDirectionWS)), 5.0f));
                float3 specular = Simple_Specular_BRDF(input_data, surface_data, mainLight);
                float3 sss = Calculate_SSS(depth, mainLight, input_data);
                float4 foam = Calculate_Foam(depth, IN.uv);

                #ifdef _ADDITIONAL_LIGHTS
                uint pixelLightCount = GetAdditionalLightsCount();
                for (uint lightIndex = 0; lightIndex < pixelLightCount; ++lightIndex)
                {
                    Light light = GetAdditionalLight(lightIndex, input_data.positionWS);
                    specular += Simple_Specular_BRDF(input_data, surface_data, light);
                    sss += Calculate_SSS(depth, light, input_data);
                }
                #endif

                float3 water_color = lerp(refraction, reflection, Fresnel) + specular + sss;
                float3 foam_color = foam.rgb;
                float3 final_color = lerp(water_color, foam_color, foam.a);
                final_color.rgb = MixFog(final_color.rgb, IN.fogFactor);
                finalColor = half4(final_color, 1.0h);
            }
            ENDHLSL
        }
    }
}