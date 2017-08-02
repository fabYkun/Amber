// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Amber"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Blur("Blur", Range(0, 5)) = 1.0
		_Thickness("Thickness", Range(0,1)) = 0.2
		_FaceSmoothness("FaceSmoothness", Range(0.001,1)) = 0.5
		_BackSmoothness("BackSmoothness", Range(0.001,1)) = 0.5
	}

	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Opaque" }
		GrabPass { }

		Pass
		{
			Cull Front
			Tags{
				"LightMode" = "ForwardBase"
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityStandardBRDF.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal: NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				float3 clipWorldSpace : TEXCOORD4;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = ComputeGrabScreenPos(o.pos);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.clipWorldSpace = mul(unity_ObjectToWorld, o.pos);
				o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
				return o;
			}
			
			sampler2D									_GrabTexture;
			float4										_GrabTexture_TexelSize;
			float										_Blur;
			fixed4										_Color;
			float										_Thickness;
			float										_BackSmoothness;

			fixed4 frag (v2f i) : SV_Target
			{
				float3 normal = normalize(i.normal);
				float ndotv = saturate(1 - saturate(dot(normal, i.viewDir)));
				half4 pixelCol = half4(0, 0, 0, 0);
				const fixed4 transparent = half4(1, 1, 1, 1);
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				float3 clipDir = normalize(_WorldSpaceCameraPos - i.clipWorldSpace);
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 reflectionDir = reflect(-lightDir, i.normal); // Blinn-phong model tends to glitch witch backface-culling so we're using the blinn reflection model
				float3 lightColor = lerp(_LightColor0.rgb, _Color.rgb, _Thickness);

				// saturate => avoids bright pixels (HDR)
				#define ADDPIXEL(weight,kernelY) saturate(tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(float4(i.uv.x, i.uv.y + _GrabTexture_TexelSize.y * kernelY * _Blur * ndotv, i.uv.z, i.uv.w)))) * weight
				
				pixelCol += ADDPIXEL(0.05, 4.0);
				pixelCol += ADDPIXEL(0.09, 3.0);
				pixelCol += ADDPIXEL(0.12, 2.0);
				pixelCol += ADDPIXEL(0.15, 1.0);
				pixelCol += ADDPIXEL(0.18, 0.0);
				pixelCol += ADDPIXEL(0.15, -1.0);
				pixelCol += ADDPIXEL(0.12, -2.0);
				pixelCol += ADDPIXEL(0.09, -3.0);
				pixelCol += ADDPIXEL(0.05, -4.0);
				pixelCol *= _Color;

				float3 specular = (pow(DotClamped(viewDir, reflectionDir), _BackSmoothness * 100) * lightColor + pow(DotClamped(clipDir, reflectionDir), _BackSmoothness * 100) * lightColor);
				return saturate(float4(pixelCol + specular, 1));
			}
			ENDCG
		}
		GrabPass { }
		
		Pass
		{
			Cull Back
			Tags {
				"LightMode" = "ForwardBase"
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile_fog // fog
			#include "UnityStandardBRDF.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal: NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				UNITY_FOG_COORDS(4) // 4 for TEXCOORD4
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = ComputeGrabScreenPos(o.pos);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex)));
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				UNITY_TRANSFER_FOG(o, o.pos);
				return o;
			}
			
			sampler2D								_GrabTexture;
			float4									_GrabTexture_TexelSize;
			float									_Blur;
			fixed4									_Color;
			float									_Thickness;
			float									_FaceSmoothness;

			fixed4 frag(v2f i) : SV_Target
			{
				float3 normal = normalize(i.normal);
				float ndotv = saturate(1 - saturate(dot(normal, i.viewDir)));
				half4 pixelCol = half4(0, 0, 0, 0);
				const fixed4 transparent = half4(1, 1, 1, 1);
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 halfVector = normalize(lightDir + viewDir);
				float3 lightColor = _LightColor0.rgb;

				// saturate => avoids bright pixels (HDR)
				#define ADDPIXEL(weight,kernelX) saturate(tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(float4(i.uv.x + _GrabTexture_TexelSize.x * kernelX * _Blur * ndotv, i.uv.y, i.uv.z, i.uv.w)))) * weight
				
				pixelCol += ADDPIXEL(0.05, 4.0);
				pixelCol += ADDPIXEL(0.09, 3.0);
				pixelCol += ADDPIXEL(0.12, 2.0);
				pixelCol += ADDPIXEL(0.15, 1.0);
				pixelCol += ADDPIXEL(0.18, 0.0);
				pixelCol += ADDPIXEL(0.15, -1.0);
				pixelCol += ADDPIXEL(0.12, -2.0);
				pixelCol += ADDPIXEL(0.09, -3.0);
				pixelCol += ADDPIXEL(0.05, -4.0);
				pixelCol *= lerp(transparent, _Color, saturate(ndotv + _Thickness));
				pixelCol = float4(pow(DotClamped(halfVector, i.normal), _FaceSmoothness * 100) * lightColor, 1) + pixelCol;
				UNITY_APPLY_FOG(i.fogCoord, pixelCol);
				return (saturate(pixelCol));
			}
			ENDCG
		}
	}
}