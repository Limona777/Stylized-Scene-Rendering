Shader "Custom/TerrainDeformation"
{
    Properties
    {
        _MainTex ("Height State", 2D) = "black" {}
        _DepthTex ("Object Depth", 2D) = "black" {}
        _FloorTex ("Floor Height", 2D) = "white" {}
        
        _MaxHeight ("Max Height", Float) = 1.0
        _FarPlane ("Far Plane", Float) = 10.0
        _ImpactStrength ("Impact Strength", Float) = 1.0
        _Smoothness ("Smoothness", Float) = 1.0
        _RecoverySpeed ("Recovery Speed", Float) = 0.0
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            sampler2D _MainTex;
            sampler2D _DepthTex;
            sampler2D _FloorTex;
            float4 _MainTex_TexelSize;
            
            float _MaxHeight;
            float _FarPlane;
            float _ImpactStrength;
            float _Smoothness;
            float _RecoverySpeed;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 flippedUV = float2(i.uv.x, 1.0 - i.uv.y);

                float4 currentState = tex2D(_MainTex, i.uv);

                float4 objectDepth = tex2D(_DepthTex, flippedUV);

                float floorHeight = tex2D(_FloorTex, flippedUV).r;

                float normalizedDepth = saturate((objectDepth.r - floorHeight) / (_MaxHeight / _FarPlane));

                float newHeight = min(currentState.r, normalizedDepth);

                newHeight += _RecoverySpeed * 0.01;
                newHeight = saturate(newHeight);

                float2 offset = _MainTex_TexelSize.xy;
                float surroundingAvg = 0.0;
                float weightSum = 0.0;
                
                for (int x = -1; x <= 1; x++)
                {
                    for (int y = -1; y <= 1; y++)
                    {
                        float2 sampleUV = i.uv + float2(x, y) * offset;
                        float sampleHeight = tex2D(_MainTex, sampleUV).r;
                        float weight = 1.0 - abs(x) * 0.3 - abs(y) * 0.3;
                        surroundingAvg += sampleHeight * weight;
                        weightSum += weight;
                    }
                }
                surroundingAvg /= weightSum;

                float smoothFactor = abs(currentState.r - surroundingAvg) * _Smoothness;
                newHeight = lerp(newHeight, surroundingAvg, smoothFactor);

                fixed4 output;
                output.r = saturate(newHeight);
                output.g = 0.0;
                output.b = currentState.b;
                output.a = 0.0;
                
                return output;
            }
            ENDCG
        }
    }
}