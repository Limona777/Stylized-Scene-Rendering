Shader "Custom/TerrainRender"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _HeightMap ("Height Map", 2D) = "black" {}

        _MaxHeight ("Max Height", Float) = 1.0
        _Scale ("Scale", Float) = 1.0

        _Ambient ("Ambient Intensity", Range(0,1)) = 0.4
        _Roughness ("Roughness", Range(0,1)) = 0.8
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _SpecularPower ("Specular Power", Range(1,100)) = 20

        _SparkleTex ("Sparkle Noise", 2D) = "black" {}
        _SparkleIntensity ("Sparkle Intensity", Range(0,1)) = 0.3
        _SparkleScale ("Sparkle Scale", Float) = 3.0

        _FogColor ("Fog Color", Color) = (0.6,0.6,0.6,1)
        _FogDensity ("Fog Density", Range(0,0.1)) = 0.02
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "DepthCapture"="True" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "UnityStandardUtils.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 worldTangent : TEXCOORD3;
                float3 worldBinormal : TEXCOORD4;
                float4 vertex : SV_POSITION;
                float3 viewDir : TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            sampler2D _HeightMap;
            float4 _HeightMap_ST;
            sampler2D _SparkleTex;
            float4 _SparkleTex_ST;

            float _MaxHeight;
            float _Scale;
            float _Ambient;
            float _Roughness;
            float3 _SpecularColor;
            float _SpecularPower;
            float _SparkleIntensity;
            float _SparkleScale;
            float3 _FogColor;
            float _FogDensity;

            v2f vert (appdata v)
            {
                v2f o;
                float height = tex2Dlod(_HeightMap, float4(v.uv, 0, 0)).r;
                float displacement = saturate(1.0 - height) * _MaxHeight * (1.0 / _Scale);
                v.vertex.y += displacement;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldPos = worldPos;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
                o.viewDir = normalize(_WorldSpaceCameraPos - worldPos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 albedo = tex2D(_MainTex, i.uv);
                float3 tangentNormal = UnpackNormal(tex2D(_NormalMap, i.uv));
                float3x3 TBN = float3x3(i.worldTangent, i.worldBinormal, i.worldNormal);
                float3 worldNormal = normalize(mul(TBN, tangentNormal));

                float3 lightDir = normalize(float3(0.5, 1.0, 0.3));
                float3 viewDir = normalize(i.viewDir);

                float NDotL = max(dot(worldNormal, lightDir), 0.0);
                float NDotV = max(dot(worldNormal, viewDir), 0.0);
                float VDotL = max(dot(viewDir, lightDir), 0.0);

                float roughness = _Roughness * _Roughness;
                float A = 1.0 - 0.5 * (roughness / (roughness + 0.57));
                float B = 0.45 * (roughness / (roughness + 0.09));
                float alpha = max(acos(NDotL), acos(NDotV));
                float beta = min(acos(NDotL), acos(NDotV));
                float gamma = VDotL;
                float orenNayar = NDotL * (A + B * max(0.0, gamma) * sin(alpha) * tan(beta));
                float diffuse = lerp(_Ambient, 1.0, orenNayar);

                float3 halfDir = normalize(lightDir + viewDir);
                float spec = pow(max(dot(worldNormal, halfDir), 0.0), _SpecularPower);
                float3 specular = _SpecularColor * spec * 0.6;

                float2 sparkleUV = i.uv * _SparkleScale;
                float sparkleNoise = tex2D(_SparkleTex, sparkleUV).r;
                float sparkle = step(0.97, sparkleNoise) * _SparkleIntensity;
                sparkle *= saturate(NDotL * 2.0);

                float3 finalColor = albedo.rgb * diffuse + specular + sparkle * albedo.rgb;

                float depth = length(i.worldPos - _WorldSpaceCameraPos);
                float fogFactor = exp(-_FogDensity * _FogDensity * depth * depth);
                fogFactor = saturate(1.0 - fogFactor);
                finalColor = lerp(finalColor, _FogColor, fogFactor);

                return fixed4(finalColor, albedo.a);
            }
            ENDCG
        }
    }
}