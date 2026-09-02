Shader "Sand/ReceiveTerrain"
{
    Properties
    {
        _MainTex("Texture", 2D) = "black" {}
        _SandState("Sand State", 2D) = "black" {}
        _FloorHeight("_FloorHeight", 2D) = "white" {}
        _SandMaxHeight("_SandMaxHeight", Float) = 1
        _SandFarPlane("_SandFarPlane", Float) = 10
        _ColorImpactStrength("_ColorImpactStrength", Float) = 0.5
        _HeightImpactStrength("_HeightImpactStrength", Float) = 1
        _SandSmoothMultiplier("_SandSmoothMultiplier", Float )= 1
    }

    SubShader
    {
        Tags{ "RenderType" = "Opaque" }
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
            sampler2D _SandState;
            sampler2D _FloorHeight;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            float _SandMaxHeight;
            float _SandFarPlane;
            float _ColorImpactStrength;
            float _HeightImpactStrength;
            float _SandSmoothMultiplier;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                fixed4 o;
                float2 uv = float2(i.uv.x,i.uv.y);
                float2 uv2 = float2(i.uv.x, 1-i.uv.y);
                float floor = tex2D(_FloorHeight, uv2).x;
                float4 current = tex2D(_SandState, uv2);
                float4 receive = tex2D(_MainTex, uv);
                float receivePart = tex2D(_MainTex, uv2).g;
                float currentFloorBias = (current.x - floor) / ((floor - (_SandMaxHeight / _SandFarPlane)) - floor);
                float particleFloorBias =(receivePart - floor) / ((floor - (_SandMaxHeight / _SandFarPlane)) - floor);

                receive.y = 1-particleFloorBias;
                current.x = 1-currentFloorBias;

                float3 realoff = float3(-1 * _MainTex_TexelSize.x , 0, 1 * _MainTex_TexelSize.y);

                float3 h00 = saturate(tex2D(_MainTex, float2(uv.x + realoff.x, uv.y + realoff.x)).xyz);
                float3 h10 = saturate(tex2D(_MainTex, float2(uv.x + realoff.y, uv.y + realoff.x)).xyz);
                float3 h20 = saturate(tex2D(_MainTex, float2(uv.x + realoff.z, uv.y + realoff.x)).xyz);
                float3 h01 = saturate(tex2D(_MainTex, float2(uv.x + realoff.x, uv.y + realoff.y)).xyz);
                float3 h11 = saturate(tex2D(_MainTex, float2(uv.x + realoff.y, uv.y + realoff.y)).xyz);
                float3 h21 = saturate(tex2D(_MainTex, float2(uv.x + realoff.z, uv.y + realoff.y)).xyz);
                float3 h02 = saturate(tex2D(_MainTex, float2(uv.x + realoff.x, uv.y + realoff.z)).xyz);
                float3 h12 = saturate(tex2D(_MainTex, float2(uv.x + realoff.y, uv.y + realoff.z)).xyz);
                float3 h22 = saturate(tex2D(_MainTex, float2(uv.x + realoff.z, uv.y + realoff.z)).xyz);

                float3 maxNH = max(max(max(max(max(max(max(max(h00, h10), h20), h01), h11), h21), h02), h12), h22);
                float3 minNH = min(min(min(min(min(min(min(min(h00, h10), h20), h01), h11), h21), h02), h12), h22);

                float3 nH = h00 + h10 + h20 + h01 + h21 + h02 + h12 + h22;
                nH /= 8;

                receive.xyz = lerp(receive.xyz, nH.xyz, abs(h11.x - nH.x) * _SandSmoothMultiplier);
                float receiveDepth = current.r;
                float receiveParticle = receive.g;
                float part = 1.0f / (_SandMaxHeight);
                float partCheck = 1 -step(0.1, abs(receive.x - receiveParticle));
                part = part * partCheck;
                float heightCheck = 1 - step(0, receive.x - current.x);
                current.x *= heightCheck;
                _HeightImpactStrength *= 0.01;
                float height = max(receiveDepth, receive.x) - _HeightImpactStrength * part;
                float groundedParticle = saturate(receive.z + part * _ColorImpactStrength) - current.x;

                o.r = height;
                o.g = 0.0f;
                o.b = groundedParticle;
                o.a = 0;

                return o;
            }
            ENDCG
        }
    }
}