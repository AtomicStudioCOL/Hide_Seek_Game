Shader "Unlit/LightOrb" {
    Properties { // input data
        _Color ("Color A", Color) = (1, 1, 1, 1)
        _Intensity ("Intensity", Range (.1, 5)) = 1
        _Attenuation ("Attenuation", Range (.1, 5)) = 1
    }
    SubShader {
        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        Pass {

            Cull Off
            ZWrite Off
            Blend One One // multiply

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.2831855

            float4 _Color;
            float _Intensity;
            float _Attenuation;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 uv0 : TEXCOORD0;
            };

            struct v2f {
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v) {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex); // localspace to clipspace
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv0;

                return o;
            }

            float InverseLerp ( float a, float b, float v) {
                return (v-a) / (b-a);
            }

            float4 frag (v2f i) : SV_Target { 

                float2 uvsCentered = i.uv * 2 - 1;
                float radialDistance = length(uvsCentered);
                float intensityVariation = cos((2* _Time.y * 0.1) * TAU) * 0.5 + 0.6;

                return ((_Color / 3 * _Intensity * intensityVariation) /_Attenuation);
            }
            ENDCG
        }
    }
}
