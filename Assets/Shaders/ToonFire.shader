Shader "MSLG/Toon Fire"
{
	Properties
	{
		_MaskTex0 ("Mask 0 Tex", 2D) = "white" {}
        _MaskXScollSpeed0("Mask 0 X Scroll Speed", Float) = 0
        _MaskYScollSpeed0("Mask 0 Y Scroll Speed", Float) = 0
        _MaskTex1 ("Mask 1 Tex", 2D) = "white" {}
		_MaskXScollSpeed1("Mask 1 X Scroll Speed", Float) = 0
        _MaskYScollSpeed1("Mask 1 Y Scroll Speed", Float) = 0
        _MaskReduce ("Mask Reduce", Range(0, 1)) = 0
		_MaskContrast("Mask Contrast", Range(0, 3)) = 1
        _Alpha("Alpha", Range(0, 4)) = 1
        _ColorRamp ("Color Ramp", 2D) = "white" {}
	}
	SubShader
	{
		Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
        CGINCLUDE
            #include "UnityCG.cginc"

            sampler2D _MaskTex0;
            float4 _MaskTex0_ST;
            float _MaskXScollSpeed0;
            float _MaskYScollSpeed0;
            sampler2D _MaskTex1;
            float _MaskXScollSpeed1;
            float _MaskYScollSpeed1;
            float4 _MaskTex1_ST;
            sampler2D _ColorRamp;
			float _MaskReduce;
			float _MaskContrast;
            float _Alpha;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float verticalFade : TEXCOORD2; 
            };

            v2f vert (appdata v)
            {
                v2f o;
                
                float noise = tex2Dlod(_MaskTex1, half4(v.uv, 0, 0));
                
                v.vertex.xz *= 1 - pow(v.uv.y, 2 + sin((-_Time.y + v.uv.y + noise) * 4) * 0.5);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv0 = TRANSFORM_TEX(v.uv, _MaskTex0);
                o.uv1 = TRANSFORM_TEX(v.uv, _MaskTex1);
                o.verticalFade = 1 - v.uv.y;
                
                return o;
            }
            
			float Contrast(float value, float c)
			{
				return saturate(lerp(0.5, value, c));
			}

            fixed4 frag (v2f i) : SV_Target
            {
                float mask0 = tex2D(_MaskTex0, i.uv0 + _Time.x * float2(_MaskXScollSpeed0, _MaskYScollSpeed0));
                float mask1 = tex2D(_MaskTex1, i.uv1 + _Time.x * float2(_MaskXScollSpeed1, _MaskYScollSpeed1));
				float mask = Contrast(mask0 + mask1 - _MaskReduce, _MaskContrast);
                float ramp = 1 - mask * i.verticalFade;
                
                fixed4 color = tex2D(_ColorRamp, mask);
                color.a *= _Alpha * pow(i.verticalFade, 4);
                
                return color;
            }   
        ENDCG
        
		Pass
		{
            ZWrite Off
            Cull Front
            Blend SrcAlpha OneMinusSrcAlpha
        
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

		Pass
		{
            ZWrite Off
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha
        
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
