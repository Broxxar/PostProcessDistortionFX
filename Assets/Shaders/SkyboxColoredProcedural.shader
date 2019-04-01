Shader "MSLG/Skybox Colored Procedural"
{
	Properties
	{
		_SkyColor ("Sky Color", Color) = (1, 1, 1)
        _EquatorColor ("Equator Color", Color) = (0.5, 0.5, 0.5)
        _GroundColor ("Ground Color", Color) = (0, 0, 0)
	}
	SubShader
	{
		Tags
        {
            "Queue" = "Background"
            "PreviewType" = "Skybox"
        }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

            float4 _SkyColor;
            float4 _EquatorColor;
            float4 _GroundColor;
            
			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float uv : TEXCOORD0;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.vertex.y;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return i.uv < 0.0 ? lerp(_EquatorColor, _GroundColor, -i.uv) : lerp(_EquatorColor, _SkyColor, i.uv);
			}
			ENDCG
		}
	}
}
