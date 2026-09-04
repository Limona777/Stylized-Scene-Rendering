Shader "Custom/HeatWavePostProcess"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _NoiseTex ("Heat Wave Noise Texture", 2D) = "white" {}
        _DistortTimeFactor ("Distortion Speed", Range(0, 2)) = 0.5
        _LuminosityAmount ("Distortion Intensity", Range(0, 0.2)) = 0.03
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }
        LOD 100
        ZTest Always
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            float _DistortTimeFactor;
            float _LuminosityAmount;

            fixed4 frag (v2f_img i) : SV_Target
            {
                float4 noise = tex2D(_NoiseTex, i.uv - _Time.xy * _DistortTimeFactor);
                float2 offset = noise.xy * _LuminosityAmount;
                return tex2D(_MainTex, i.uv + offset);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}