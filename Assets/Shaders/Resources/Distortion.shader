Shader "Hidden/Custom/Distortion"
{
    HLSLINCLUDE
        
        // This include uses a relative path, and may need to be updated if shaders are moved or
        // a different version of Unity's PostFX stack is being used (eg. if your version of the
        // project imports the PostFX stack from Package Manager).
        #include "../../PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        TEXTURE2D_SAMPLER2D(_GlobalDistortionTex, sampler_GlobalDistortionTex);
        float4 _MainTex_TexelSize;
        float _Magnitude;

        float4 Frag(VaryingsDefault i) : SV_Target
        {
            float2 mag = _Magnitude * _MainTex_TexelSize.xy;
            float2 distortion = SAMPLE_TEXTURE2D(_GlobalDistortionTex, sampler_GlobalDistortionTex, i.texcoord).xy * mag;
            float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + distortion);
            return color;
        }

    ENDHLSL

    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            HLSLPROGRAM

                #pragma vertex VertDefault
                #pragma fragment Frag

            ENDHLSL
        }
    }
}