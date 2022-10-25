Shader "FL2D/ShadowMap Mesh"
{
    Properties
    {
        _Light_Penetration_Dist("Light Penetration Dist", Float) = 0.1
        _Layer_Mask("Layer Mask", Color) = (1, 1, 1, 1)
        [HideInInspector]_BUILTIN_QueueOffset("Float", Float) = 0
        [HideInInspector]_BUILTIN_QueueControl("Float", Float) = -1
    }
        SubShader
    {
        Tags
        {
            // RenderPipeline: <None>
            "RenderType" = "Transparent"
            "BuiltInMaterialType" = "Unlit"
            "Queue" = "Transparent"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "BuiltInUnlitSubTarget"
        }
        Pass
        {
            Name "Pass"
            Tags
            {
                "LightMode" = "ForwardBase"
            }

        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        BlendOp Min
        ZTest LEqual
        ZWrite Off
        ColorMask RGB

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile_fwdbase
        #pragma vertex vert
        #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_TEXCOORD3
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 uv3 : TEXCOORD3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
             float4 World_AxyBxy;
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float4 World_AxyBxy;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ViewSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ViewSpaceTangent;
             float3 WorldSpaceTangent;
             float3 ObjectSpaceBiTangent;
             float3 ViewSpaceBiTangent;
             float3 WorldSpaceBiTangent;
             float3 ObjectSpacePosition;
             float4 uv0;
             float4 uv1;
             float4 uv2;
             float4 uv3;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings(Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            output.interp1.xyzw = input.World_AxyBxy;
            return output;
        }

        Varyings UnpackVaryings(PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            output.World_AxyBxy = input.interp1.xyzw;
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Light_Penetration_Dist;
        float4 _Layer_Mask;
        CBUFFER_END

            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            float _MAX_LIGHT_Y;
            TEXTURE2D(_LIGHT_DATA);
            SAMPLER(sampler_LIGHT_DATA);
            float4 _LIGHT_DATA_TexelSize;
            float4 _LIGHT_BOUNDS_RECT;
            float _LIGHT_RADIUS_FACTOR;

            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif

            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif

            // Graph Includes
            #include "Assets/Plugins/MindsEyeGames/FastLight2D/Materials/Shaders/Funcs/Color2Float.hlsl"
            #include "Assets/Plugins/MindsEyeGames/FastLight2D/Materials/Shaders/Funcs/Compute Shadow Collision Func.hlsl"
            #include "Assets/Plugins/MindsEyeGames/FastLight2D/Materials/Shaders/Funcs/Int Bitmask via Colors.hlsl"

            // Graph Functions

            void Unity_Distance_float3(float3 A, float3 B, out float Out)
            {
                Out = distance(A, B);
            }

            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
            Out = A * B;
            }

            struct Bindings_RetrieveShadowMapMeshData_0e25fbbc00721d049be2fae54a1fa55f_float
            {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpaceBiTangent;
            half4 uv1;
            half4 uv2;
            half4 uv3;
            };

            void SG_RetrieveShadowMapMeshData_0e25fbbc00721d049be2fae54a1fa55f_float(Bindings_RetrieveShadowMapMeshData_0e25fbbc00721d049be2fae54a1fa55f_float IN, out float4 World_AxyBxy_1, out float Radius_2)
            {
            float4 _UV_4b6bc125c1ea4208b43486b5a0859776_Out_0 = IN.uv1;
            float3 _Transform_6cbdfa2a1d644ba2ae242b930853cd8a_Out_1 = TransformObjectToWorld((_UV_4b6bc125c1ea4208b43486b5a0859776_Out_0.xyz).xyz);
            float _Split_16c9bb15a95b4cbf9059397a7267dd42_R_1 = _Transform_6cbdfa2a1d644ba2ae242b930853cd8a_Out_1[0];
            float _Split_16c9bb15a95b4cbf9059397a7267dd42_G_2 = _Transform_6cbdfa2a1d644ba2ae242b930853cd8a_Out_1[1];
            float _Split_16c9bb15a95b4cbf9059397a7267dd42_B_3 = _Transform_6cbdfa2a1d644ba2ae242b930853cd8a_Out_1[2];
            float _Split_16c9bb15a95b4cbf9059397a7267dd42_A_4 = 0;
            float4 _UV_deab2ae5ae2b47ce97106597abac61d6_Out_0 = IN.uv2;
            float3 _Transform_11d719f6ebac45a88e2cea10f5455ba5_Out_1 = TransformObjectToWorld((_UV_deab2ae5ae2b47ce97106597abac61d6_Out_0.xyz).xyz);
            float _Split_1a1b01f8b47a4c6d960c68da853e100e_R_1 = _Transform_11d719f6ebac45a88e2cea10f5455ba5_Out_1[0];
            float _Split_1a1b01f8b47a4c6d960c68da853e100e_G_2 = _Transform_11d719f6ebac45a88e2cea10f5455ba5_Out_1[1];
            float _Split_1a1b01f8b47a4c6d960c68da853e100e_B_3 = _Transform_11d719f6ebac45a88e2cea10f5455ba5_Out_1[2];
            float _Split_1a1b01f8b47a4c6d960c68da853e100e_A_4 = 0;
            float4 _Vector4_b55474ae5ac44691a0f5f271ae3d251f_Out_0 = float4(_Split_16c9bb15a95b4cbf9059397a7267dd42_R_1, _Split_16c9bb15a95b4cbf9059397a7267dd42_G_2, _Split_1a1b01f8b47a4c6d960c68da853e100e_R_1, _Split_1a1b01f8b47a4c6d960c68da853e100e_G_2);
            float4 _UV_4ce55d2abdce4601a1dffc45c748b7c6_Out_0 = IN.uv3;
            float _Split_f79a3a237a414d46966e6688a3ace7ba_R_1 = _UV_4ce55d2abdce4601a1dffc45c748b7c6_Out_0[0];
            float _Split_f79a3a237a414d46966e6688a3ace7ba_G_2 = _UV_4ce55d2abdce4601a1dffc45c748b7c6_Out_0[1];
            float _Split_f79a3a237a414d46966e6688a3ace7ba_B_3 = _UV_4ce55d2abdce4601a1dffc45c748b7c6_Out_0[2];
            float _Split_f79a3a237a414d46966e6688a3ace7ba_A_4 = _UV_4ce55d2abdce4601a1dffc45c748b7c6_Out_0[3];
            float3 _Transform_efbcf69f79444999a5b8d5ab6bec8c3e_Out_1 = TransformObjectToWorld(float3 (0, 0, 0).xyz);
            float3 _Vector3_451b4a02310643e891350bb6fc49f770_Out_0 = float3(0.7071068, 0.7071068, 0);
            float3 _Transform_9b8ae0a1c89c43e2bc085104b9f1ac21_Out_1 = TransformObjectToWorld(_Vector3_451b4a02310643e891350bb6fc49f770_Out_0.xyz);
            float _Distance_9dc0d43c5fd54dce873192f177031a0a_Out_2;
            Unity_Distance_float3(_Transform_efbcf69f79444999a5b8d5ab6bec8c3e_Out_1, _Transform_9b8ae0a1c89c43e2bc085104b9f1ac21_Out_1, _Distance_9dc0d43c5fd54dce873192f177031a0a_Out_2);
            float _Distance_05c20507e9fc4136aa6354462883f001_Out_2;
            Unity_Distance_float3(float3(0, 0, 0), _Vector3_451b4a02310643e891350bb6fc49f770_Out_0, _Distance_05c20507e9fc4136aa6354462883f001_Out_2);
            float _Divide_9eb3fe7a747e432582ffe74c84efa38d_Out_2;
            Unity_Divide_float(_Distance_9dc0d43c5fd54dce873192f177031a0a_Out_2, _Distance_05c20507e9fc4136aa6354462883f001_Out_2, _Divide_9eb3fe7a747e432582ffe74c84efa38d_Out_2);
            float _Multiply_e867d958b7af4240944c8371e0c7dd06_Out_2;
            Unity_Multiply_float_float(_Split_f79a3a237a414d46966e6688a3ace7ba_R_1, _Divide_9eb3fe7a747e432582ffe74c84efa38d_Out_2, _Multiply_e867d958b7af4240944c8371e0c7dd06_Out_2);
            World_AxyBxy_1 = _Vector4_b55474ae5ac44691a0f5f271ae3d251f_Out_0;
            Radius_2 = _Multiply_e867d958b7af4240944c8371e0c7dd06_Out_2;
            }

            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
            Out = A * B;
            }

            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }

            struct Bindings_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float
            {
            float3 ViewSpaceNormal;
            float3 ViewSpaceTangent;
            float3 ViewSpaceBiTangent;
            half4 uv0;
            };

            void SG_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float(float _MAX_LIGHT_Y, Bindings_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float IN, out float3 Render_Pos_1)
            {
            float4 _UV_0c5fc72cff8e49e69d2b536d2079bce5_Out_0 = IN.uv0;
            float4 _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2;
            Unity_Multiply_float4_float4(_UV_0c5fc72cff8e49e69d2b536d2079bce5_Out_0, float4(2, 2, 1, 1), _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2);
            float _Split_729dec92120d403f9c283d8f2eb53693_R_1 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[0];
            float _Split_729dec92120d403f9c283d8f2eb53693_G_2 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[1];
            float _Split_729dec92120d403f9c283d8f2eb53693_B_3 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[2];
            float _Split_729dec92120d403f9c283d8f2eb53693_A_4 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[3];
            float _Subtract_507e32db10514b0f8c9b54eecc49551e_Out_2;
            Unity_Subtract_float(_Split_729dec92120d403f9c283d8f2eb53693_R_1, 1, _Subtract_507e32db10514b0f8c9b54eecc49551e_Out_2);
            float _Multiply_f668bbea335543e0bab3f513cf18ab81_Out_2;
            Unity_Multiply_float_float(_Subtract_507e32db10514b0f8c9b54eecc49551e_Out_2, unity_OrthoParams.x, _Multiply_f668bbea335543e0bab3f513cf18ab81_Out_2);
            float _Property_5761738ad30d407ba2f64b21946346cb_Out_0 = _MAX_LIGHT_Y;
            float _Multiply_a4d96df35e444398bb4e9f791e9e0f86_Out_2;
            Unity_Multiply_float_float(_Split_729dec92120d403f9c283d8f2eb53693_G_2, _Property_5761738ad30d407ba2f64b21946346cb_Out_0, _Multiply_a4d96df35e444398bb4e9f791e9e0f86_Out_2);
            float _Subtract_a0279ded92b94d14ae19bbf9a48c193f_Out_2;
            Unity_Subtract_float(_Multiply_a4d96df35e444398bb4e9f791e9e0f86_Out_2, 1, _Subtract_a0279ded92b94d14ae19bbf9a48c193f_Out_2);
            float _Multiply_2838e47c5c304495a9ccc3f45a2fed62_Out_2;
            Unity_Multiply_float_float(_Subtract_a0279ded92b94d14ae19bbf9a48c193f_Out_2, unity_OrthoParams.y, _Multiply_2838e47c5c304495a9ccc3f45a2fed62_Out_2);
            float3 _Vector3_04dbb23a96b044268454f33a0758b573_Out_0 = float3(_Multiply_f668bbea335543e0bab3f513cf18ab81_Out_2, _Multiply_2838e47c5c304495a9ccc3f45a2fed62_Out_2, -1);
            float3 _Transform_289eaae8876145b2af01d6cb5419a047_Out_1 = TransformWorldToObject(mul(UNITY_MATRIX_I_V, float4(_Vector3_04dbb23a96b044268454f33a0758b573_Out_0.xyz, 1)).xyz);
            Render_Pos_1 = _Transform_289eaae8876145b2af01d6cb5419a047_Out_1;
            }

            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A - B;
            }

            struct Bindings_ShadowMapMeshRenderedCoords_9f89163cb8cb6ba4bb33e57610505d7a_float
            {
            float4 ScreenPosition;
            };

            void SG_ShadowMapMeshRenderedCoords_9f89163cb8cb6ba4bb33e57610505d7a_float(Bindings_ShadowMapMeshRenderedCoords_9f89163cb8cb6ba4bb33e57610505d7a_float IN, out float ShadowMap_X_1, out float Light_Y_2)
            {
            float4 _ScreenPosition_f635cd1353f748b492bb48b29fc7710b_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float _Split_b0060147955f4c49be0b676452ae2ff1_R_1 = _ScreenPosition_f635cd1353f748b492bb48b29fc7710b_Out_0[0];
            float _Split_b0060147955f4c49be0b676452ae2ff1_G_2 = _ScreenPosition_f635cd1353f748b492bb48b29fc7710b_Out_0[1];
            float _Split_b0060147955f4c49be0b676452ae2ff1_B_3 = _ScreenPosition_f635cd1353f748b492bb48b29fc7710b_Out_0[2];
            float _Split_b0060147955f4c49be0b676452ae2ff1_A_4 = _ScreenPosition_f635cd1353f748b492bb48b29fc7710b_Out_0[3];
            ShadowMap_X_1 = _Split_b0060147955f4c49be0b676452ae2ff1_R_1;
            Light_Y_2 = _Split_b0060147955f4c49be0b676452ae2ff1_G_2;
            }

            struct Bindings_Color2Float_78b51c9af79c2034d80062c6e608cb9f_float
            {
            };

            void SG_Color2Float_78b51c9af79c2034d80062c6e608cb9f_float(float4 _Input, Bindings_Color2Float_78b51c9af79c2034d80062c6e608cb9f_float IN, out float Out_1)
            {
            float4 _Property_9fb14782df1d47c58d526d41557dc049_Out_0 = _Input;
            float _Color2FloatCustomFunction_9817d556113e4354a521fc2a4db5febc_Out_1;
            Color2Float_float(_Property_9fb14782df1d47c58d526d41557dc049_Out_0, _Color2FloatCustomFunction_9817d556113e4354a521fc2a4db5febc_Out_1);
            Out_1 = _Color2FloatCustomFunction_9817d556113e4354a521fc2a4db5febc_Out_1;
            }

            struct Bindings_RetrieveLightData_f8cabe0f2253dd640a2513df996521d2_float
            {
            };

            void SG_RetrieveLightData_f8cabe0f2253dd640a2513df996521d2_float(UnityTexture2D _LIGHT_DATA, float _Light_Y, Bindings_RetrieveLightData_f8cabe0f2253dd640a2513df996521d2_float IN, out float Light_XVal_1, out float Light_YVal_2, out float Light_RVal_3, out float4 Light_Layer_Color_4)
            {
            UnityTexture2D _Property_76e06a7fe93d402cb12c2ec18e0456ca_Out_0 = _LIGHT_DATA;
            float _Property_fc60db085e5e4a149067a75f3cd3934d_Out_0 = _Light_Y;
            float2 _Vector2_9c1c0a1b90ec494dae6d556910ec5747_Out_0 = float2(0.125, _Property_fc60db085e5e4a149067a75f3cd3934d_Out_0);
            float4 _SampleTexture2D_9bebdaf4990a44e68105236b69c0faa0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_76e06a7fe93d402cb12c2ec18e0456ca_Out_0.tex, _Property_76e06a7fe93d402cb12c2ec18e0456ca_Out_0.samplerstate, _Property_76e06a7fe93d402cb12c2ec18e0456ca_Out_0.GetTransformedUV(_Vector2_9c1c0a1b90ec494dae6d556910ec5747_Out_0));
            float _SampleTexture2D_9bebdaf4990a44e68105236b69c0faa0_R_4 = _SampleTexture2D_9bebdaf4990a44e68105236b69c0faa0_RGBA_0.r;
            float _SampleTexture2D_9bebdaf4990a44e68105236b69c0faa0_G_5 = _SampleTexture2D_9bebdaf4990a44e68105236b69c0faa0_RGBA_0.g;
            float _SampleTexture2D_9bebdaf4990a44e68105236b69c0faa0_B_6 = _SampleTexture2D_9bebdaf4990a44e68105236b69c0faa0_RGBA_0.b;
            float _SampleTexture2D_9bebdaf4990a44e68105236b69c0faa0_A_7 = _SampleTexture2D_9bebdaf4990a44e68105236b69c0faa0_RGBA_0.a;
            Bindings_Color2Float_78b51c9af79c2034d80062c6e608cb9f_float _Color2Float_3f45111a6d95440e9b2bd911aeeb3606;
            float _Color2Float_3f45111a6d95440e9b2bd911aeeb3606_Out_1;
            SG_Color2Float_78b51c9af79c2034d80062c6e608cb9f_float(_SampleTexture2D_9bebdaf4990a44e68105236b69c0faa0_RGBA_0, _Color2Float_3f45111a6d95440e9b2bd911aeeb3606, _Color2Float_3f45111a6d95440e9b2bd911aeeb3606_Out_1);
            float2 _Vector2_683decbd14bd4d12b56834b892fed66e_Out_0 = float2(0.375, _Property_fc60db085e5e4a149067a75f3cd3934d_Out_0);
            float4 _SampleTexture2D_7f14cdf8fba44f138e8c9dce9bc7fccf_RGBA_0 = SAMPLE_TEXTURE2D(_Property_76e06a7fe93d402cb12c2ec18e0456ca_Out_0.tex, _Property_76e06a7fe93d402cb12c2ec18e0456ca_Out_0.samplerstate, _Property_76e06a7fe93d402cb12c2ec18e0456ca_Out_0.GetTransformedUV(_Vector2_683decbd14bd4d12b56834b892fed66e_Out_0));
            float _SampleTexture2D_7f14cdf8fba44f138e8c9dce9bc7fccf_R_4 = _SampleTexture2D_7f14cdf8fba44f138e8c9dce9bc7fccf_RGBA_0.r;
            float _SampleTexture2D_7f14cdf8fba44f138e8c9dce9bc7fccf_G_5 = _SampleTexture2D_7f14cdf8fba44f138e8c9dce9bc7fccf_RGBA_0.g;
            float _SampleTexture2D_7f14cdf8fba44f138e8c9dce9bc7fccf_B_6 = _SampleTexture2D_7f14cdf8fba44f138e8c9dce9bc7fccf_RGBA_0.b;
            float _SampleTexture2D_7f14cdf8fba44f138e8c9dce9bc7fccf_A_7 = _SampleTexture2D_7f14cdf8fba44f138e8c9dce9bc7fccf_RGBA_0.a;
            Bindings_Color2Float_78b51c9af79c2034d80062c6e608cb9f_float _Color2Float_38c0aa91ad284e54ac55ac6e9fadb090;
            float _Color2Float_38c0aa91ad284e54ac55ac6e9fadb090_Out_1;
            SG_Color2Float_78b51c9af79c2034d80062c6e608cb9f_float(_SampleTexture2D_7f14cdf8fba44f138e8c9dce9bc7fccf_RGBA_0, _Color2Float_38c0aa91ad284e54ac55ac6e9fadb090, _Color2Float_38c0aa91ad284e54ac55ac6e9fadb090_Out_1);
            float2 _Vector2_2e14e04ed9344bf08fa27a35c1312b7d_Out_0 = float2(0.625, _Property_fc60db085e5e4a149067a75f3cd3934d_Out_0);
            float4 _SampleTexture2D_d5c50eab46d64fdeb5012ee3c2cd17aa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_76e06a7fe93d402cb12c2ec18e0456ca_Out_0.tex, _Property_76e06a7fe93d402cb12c2ec18e0456ca_Out_0.samplerstate, _Property_76e06a7fe93d402cb12c2ec18e0456ca_Out_0.GetTransformedUV(_Vector2_2e14e04ed9344bf08fa27a35c1312b7d_Out_0));
            float _SampleTexture2D_d5c50eab46d64fdeb5012ee3c2cd17aa_R_4 = _SampleTexture2D_d5c50eab46d64fdeb5012ee3c2cd17aa_RGBA_0.r;
            float _SampleTexture2D_d5c50eab46d64fdeb5012ee3c2cd17aa_G_5 = _SampleTexture2D_d5c50eab46d64fdeb5012ee3c2cd17aa_RGBA_0.g;
            float _SampleTexture2D_d5c50eab46d64fdeb5012ee3c2cd17aa_B_6 = _SampleTexture2D_d5c50eab46d64fdeb5012ee3c2cd17aa_RGBA_0.b;
            float _SampleTexture2D_d5c50eab46d64fdeb5012ee3c2cd17aa_A_7 = _SampleTexture2D_d5c50eab46d64fdeb5012ee3c2cd17aa_RGBA_0.a;
            Bindings_Color2Float_78b51c9af79c2034d80062c6e608cb9f_float _Color2Float_86e5eec3e1134cdba80bb6e13142dab5;
            float _Color2Float_86e5eec3e1134cdba80bb6e13142dab5_Out_1;
            SG_Color2Float_78b51c9af79c2034d80062c6e608cb9f_float(_SampleTexture2D_d5c50eab46d64fdeb5012ee3c2cd17aa_RGBA_0, _Color2Float_86e5eec3e1134cdba80bb6e13142dab5, _Color2Float_86e5eec3e1134cdba80bb6e13142dab5_Out_1);
            float2 _Vector2_3ae65ca4dccd48cf97c206050bfc9a7e_Out_0 = float2(0.875, _Property_fc60db085e5e4a149067a75f3cd3934d_Out_0);
            float4 _SampleTexture2D_923853dc2d8a45f0a20b87f0a94abae3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_76e06a7fe93d402cb12c2ec18e0456ca_Out_0.tex, _Property_76e06a7fe93d402cb12c2ec18e0456ca_Out_0.samplerstate, _Property_76e06a7fe93d402cb12c2ec18e0456ca_Out_0.GetTransformedUV(_Vector2_3ae65ca4dccd48cf97c206050bfc9a7e_Out_0));
            float _SampleTexture2D_923853dc2d8a45f0a20b87f0a94abae3_R_4 = _SampleTexture2D_923853dc2d8a45f0a20b87f0a94abae3_RGBA_0.r;
            float _SampleTexture2D_923853dc2d8a45f0a20b87f0a94abae3_G_5 = _SampleTexture2D_923853dc2d8a45f0a20b87f0a94abae3_RGBA_0.g;
            float _SampleTexture2D_923853dc2d8a45f0a20b87f0a94abae3_B_6 = _SampleTexture2D_923853dc2d8a45f0a20b87f0a94abae3_RGBA_0.b;
            float _SampleTexture2D_923853dc2d8a45f0a20b87f0a94abae3_A_7 = _SampleTexture2D_923853dc2d8a45f0a20b87f0a94abae3_RGBA_0.a;
            Light_XVal_1 = _Color2Float_3f45111a6d95440e9b2bd911aeeb3606_Out_1;
            Light_YVal_2 = _Color2Float_38c0aa91ad284e54ac55ac6e9fadb090_Out_1;
            Light_RVal_3 = _Color2Float_86e5eec3e1134cdba80bb6e13142dab5_Out_1;
            Light_Layer_Color_4 = _SampleTexture2D_923853dc2d8a45f0a20b87f0a94abae3_RGBA_0;
            }

            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }

            struct Bindings_LightDataToWorldValues_6437acaa6b9948e4a98c0c9c4d509415_float
            {
            };

            void SG_LightDataToWorldValues_6437acaa6b9948e4a98c0c9c4d509415_float(float _Light_XVal, float _Light_YVal, float _Light_RVal, float4 _LIGHT_BOUNDS_RECT, float _LIGHT_RADIUS_FACTOR, Bindings_LightDataToWorldValues_6437acaa6b9948e4a98c0c9c4d509415_float IN, out float2 Light_Pos_1, out float Light_Radius_2)
            {
            float4 _Property_92571dd34a794b1fa962bf9ea543fbf7_Out_0 = _LIGHT_BOUNDS_RECT;
            float _Split_3b06496ae6f2458285a8306f85d41951_R_1 = _Property_92571dd34a794b1fa962bf9ea543fbf7_Out_0[0];
            float _Split_3b06496ae6f2458285a8306f85d41951_G_2 = _Property_92571dd34a794b1fa962bf9ea543fbf7_Out_0[1];
            float _Split_3b06496ae6f2458285a8306f85d41951_B_3 = _Property_92571dd34a794b1fa962bf9ea543fbf7_Out_0[2];
            float _Split_3b06496ae6f2458285a8306f85d41951_A_4 = _Property_92571dd34a794b1fa962bf9ea543fbf7_Out_0[3];
            float _Property_6c97e3931ca74a1ab56909d290fddda3_Out_0 = _Light_XVal;
            float _Multiply_4add5ca2e5a2403cadaeec5934fb7837_Out_2;
            Unity_Multiply_float_float(_Property_6c97e3931ca74a1ab56909d290fddda3_Out_0, _Split_3b06496ae6f2458285a8306f85d41951_B_3, _Multiply_4add5ca2e5a2403cadaeec5934fb7837_Out_2);
            float _Add_d46ea0fb9b224746ab33f3489aca5f3b_Out_2;
            Unity_Add_float(_Split_3b06496ae6f2458285a8306f85d41951_R_1, _Multiply_4add5ca2e5a2403cadaeec5934fb7837_Out_2, _Add_d46ea0fb9b224746ab33f3489aca5f3b_Out_2);
            float _Property_095d39b1b74247148087e7c1e125e6e6_Out_0 = _Light_YVal;
            float _Multiply_0ac468e417a847c0a32c4df4d9e0be90_Out_2;
            Unity_Multiply_float_float(_Property_095d39b1b74247148087e7c1e125e6e6_Out_0, _Split_3b06496ae6f2458285a8306f85d41951_A_4, _Multiply_0ac468e417a847c0a32c4df4d9e0be90_Out_2);
            float _Add_3f1a60715fdb4a26b9915d6e8566cab8_Out_2;
            Unity_Add_float(_Split_3b06496ae6f2458285a8306f85d41951_G_2, _Multiply_0ac468e417a847c0a32c4df4d9e0be90_Out_2, _Add_3f1a60715fdb4a26b9915d6e8566cab8_Out_2);
            float2 _Vector2_7b073c372a7f4fa7ac4bad225502736c_Out_0 = float2(_Add_d46ea0fb9b224746ab33f3489aca5f3b_Out_2, _Add_3f1a60715fdb4a26b9915d6e8566cab8_Out_2);
            float _Property_94068dfda4e04a3ea049bec6d13f0603_Out_0 = _Light_RVal;
            float _Property_96f2fabe13e0430fb70aa9655131e8ea_Out_0 = _LIGHT_RADIUS_FACTOR;
            float _Multiply_ab2d9011304844479a7cf074a3bba42a_Out_2;
            Unity_Multiply_float_float(_Property_94068dfda4e04a3ea049bec6d13f0603_Out_0, _Property_96f2fabe13e0430fb70aa9655131e8ea_Out_0, _Multiply_ab2d9011304844479a7cf074a3bba42a_Out_2);
            Light_Pos_1 = _Vector2_7b073c372a7f4fa7ac4bad225502736c_Out_0;
            Light_Radius_2 = _Multiply_ab2d9011304844479a7cf074a3bba42a_Out_2;
            }

            void Unity_Cosine_float(float In, out float Out)
            {
                Out = cos(In);
            }

            void Unity_Sine_float(float In, out float Out)
            {
                Out = sin(In);
            }

            struct Bindings_ShadowMapXToLightDir_ef84d5379730af24ca8d54f264203c99_float
            {
            };

            void SG_ShadowMapXToLightDir_ef84d5379730af24ca8d54f264203c99_float(float _ShadowMap_X, Bindings_ShadowMapXToLightDir_ef84d5379730af24ca8d54f264203c99_float IN, out float2 Light_Dir_2)
            {
            float _Property_b3f779055f5a49a6b464f686a3fd6c31_Out_0 = _ShadowMap_X;
            float Constant_ef621ca8f1f744278ab49f630fb2df11 = 3.141593;
            float _Multiply_7d3348dd80254ae09b65064d4638958c_Out_2;
            Unity_Multiply_float_float(Constant_ef621ca8f1f744278ab49f630fb2df11, 2, _Multiply_7d3348dd80254ae09b65064d4638958c_Out_2);
            float _Multiply_1384838518c74d4b995da23daa014fac_Out_2;
            Unity_Multiply_float_float(_Property_b3f779055f5a49a6b464f686a3fd6c31_Out_0, _Multiply_7d3348dd80254ae09b65064d4638958c_Out_2, _Multiply_1384838518c74d4b995da23daa014fac_Out_2);
            float _Subtract_3408ff719eb04dff901b3f6c80ee6902_Out_2;
            Unity_Subtract_float(_Multiply_1384838518c74d4b995da23daa014fac_Out_2, Constant_ef621ca8f1f744278ab49f630fb2df11, _Subtract_3408ff719eb04dff901b3f6c80ee6902_Out_2);
            float _Cosine_ccf2ddf83caa4b3c8f674cc46291d10c_Out_1;
            Unity_Cosine_float(_Subtract_3408ff719eb04dff901b3f6c80ee6902_Out_2, _Cosine_ccf2ddf83caa4b3c8f674cc46291d10c_Out_1);
            float _Sine_ededdfd634bb4c27b921e4decaa806bc_Out_1;
            Unity_Sine_float(_Subtract_3408ff719eb04dff901b3f6c80ee6902_Out_2, _Sine_ededdfd634bb4c27b921e4decaa806bc_Out_1);
            float2 _Vector2_aeef7a0b2dae423f8af181bbe1d5df59_Out_0 = float2(_Cosine_ccf2ddf83caa4b3c8f674cc46291d10c_Out_1, _Sine_ededdfd634bb4c27b921e4decaa806bc_Out_1);
            Light_Dir_2 = _Vector2_aeef7a0b2dae423f8af181bbe1d5df59_Out_0;
            }

            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A * B;
            }

            struct Bindings_ComputeShadowCollisionDist_795ffb83f84919d488a0a48f552d820e_float
            {
            };

            void SG_ComputeShadowCollisionDist_795ffb83f84919d488a0a48f552d820e_float(float2 _Shadow_Barrier_Start, float2 _Shadow_Barrier_Extent, float2 _Light_Pos, float2 _Light_Extent, float _Shadow_Soft_Penetration_Factor, Bindings_ComputeShadowCollisionDist_795ffb83f84919d488a0a48f552d820e_float IN, out float Shadow_Start_Dist_0, out float Shadow_Full_Dist_1)
            {
            float2 _Property_ddb6a1321a144ae8b8b6db7e179ac813_Out_0 = _Shadow_Barrier_Start;
            float2 _Property_26320a98ee484528af9060415269b9fe_Out_0 = _Shadow_Barrier_Extent;
            float2 _Property_c3b228131e654ec3b8a265c88bc08c5d_Out_0 = _Light_Pos;
            float2 _Property_109b26448c78426a9f6b5568f0e7f1f4_Out_0 = _Light_Extent;
            float _ShadowCollisionCustomFunction_ee53c3e2387c41a081d56e7b416fc132_IntersectVal_4;
            ShadowCollision_float(_Property_ddb6a1321a144ae8b8b6db7e179ac813_Out_0, _Property_26320a98ee484528af9060415269b9fe_Out_0, _Property_c3b228131e654ec3b8a265c88bc08c5d_Out_0, _Property_109b26448c78426a9f6b5568f0e7f1f4_Out_0, _ShadowCollisionCustomFunction_ee53c3e2387c41a081d56e7b416fc132_IntersectVal_4);
            float _Property_30cbe1d09a4e46919993bef836a4ddd1_Out_0 = _Shadow_Soft_Penetration_Factor;
            float _Add_7cd4284a1f0c492e9cdb673a98671afc_Out_2;
            Unity_Add_float(_ShadowCollisionCustomFunction_ee53c3e2387c41a081d56e7b416fc132_IntersectVal_4, _Property_30cbe1d09a4e46919993bef836a4ddd1_Out_0, _Add_7cd4284a1f0c492e9cdb673a98671afc_Out_2);
            Shadow_Start_Dist_0 = _ShadowCollisionCustomFunction_ee53c3e2387c41a081d56e7b416fc132_IntersectVal_4;
            Shadow_Full_Dist_1 = _Add_7cd4284a1f0c492e9cdb673a98671afc_Out_2;
            }

            struct Bindings_IntBitmaskviaColors_12a1259bd5b1b214c9650d16c5f761f0_float
            {
            };

            void SG_IntBitmaskviaColors_12a1259bd5b1b214c9650d16c5f761f0_float(float4 _Color_A, float4 _Color_B, Bindings_IntBitmaskviaColors_12a1259bd5b1b214c9650d16c5f761f0_float IN, out float Out_1)
            {
            float4 _Property_b5b821db88bb41619509ce639e00bcc5_Out_0 = _Color_A;
            float4 _Property_f0e0c3f040dd4cdfa3b7d4b00453a5e7_Out_0 = _Color_B;
            float _IntBitmaskViaColorsCustomFunction_9817d556113e4354a521fc2a4db5febc_Out_1;
            IntBitmaskViaColors_float(_Property_b5b821db88bb41619509ce639e00bcc5_Out_0, _Property_f0e0c3f040dd4cdfa3b7d4b00453a5e7_Out_0, _IntBitmaskViaColorsCustomFunction_9817d556113e4354a521fc2a4db5febc_Out_1);
            Out_1 = _IntBitmaskViaColorsCustomFunction_9817d556113e4354a521fc2a4db5febc_Out_1;
            }

            void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
            {
                Out = lerp(A, B, T);
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
                float4 World_AxyBxy;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                Bindings_RetrieveShadowMapMeshData_0e25fbbc00721d049be2fae54a1fa55f_float _RetrieveShadowMapMeshData_f63f7926e3d242a4a7a0aa832f18d6c4;
                _RetrieveShadowMapMeshData_f63f7926e3d242a4a7a0aa832f18d6c4.ObjectSpaceNormal = IN.ObjectSpaceNormal;
                _RetrieveShadowMapMeshData_f63f7926e3d242a4a7a0aa832f18d6c4.ObjectSpaceTangent = IN.ObjectSpaceTangent;
                _RetrieveShadowMapMeshData_f63f7926e3d242a4a7a0aa832f18d6c4.ObjectSpaceBiTangent = IN.ObjectSpaceBiTangent;
                _RetrieveShadowMapMeshData_f63f7926e3d242a4a7a0aa832f18d6c4.uv1 = IN.uv1;
                _RetrieveShadowMapMeshData_f63f7926e3d242a4a7a0aa832f18d6c4.uv2 = IN.uv2;
                _RetrieveShadowMapMeshData_f63f7926e3d242a4a7a0aa832f18d6c4.uv3 = IN.uv3;
                float4 _RetrieveShadowMapMeshData_f63f7926e3d242a4a7a0aa832f18d6c4_WorldAxyBxy_1;
                float _RetrieveShadowMapMeshData_f63f7926e3d242a4a7a0aa832f18d6c4_Radius_2;
                SG_RetrieveShadowMapMeshData_0e25fbbc00721d049be2fae54a1fa55f_float(_RetrieveShadowMapMeshData_f63f7926e3d242a4a7a0aa832f18d6c4, _RetrieveShadowMapMeshData_f63f7926e3d242a4a7a0aa832f18d6c4_WorldAxyBxy_1, _RetrieveShadowMapMeshData_f63f7926e3d242a4a7a0aa832f18d6c4_Radius_2);
                float _Property_49e2b6dc4b404117843f849765aae6ff_Out_0 = _MAX_LIGHT_Y;
                Bindings_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06;
                _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.ViewSpaceNormal = IN.ViewSpaceNormal;
                _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.ViewSpaceTangent = IN.ViewSpaceTangent;
                _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.ViewSpaceBiTangent = IN.ViewSpaceBiTangent;
                _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.uv0 = IN.uv0;
                float3 _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06_RenderPos_1;
                SG_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float(_Property_49e2b6dc4b404117843f849765aae6ff_Out_0, _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06, _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06_RenderPos_1);
                description.Position = _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06_RenderPos_1;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                description.World_AxyBxy = _RetrieveShadowMapMeshData_f63f7926e3d242a4a7a0aa832f18d6c4_WorldAxyBxy_1;
                return description;
            }

            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            output.World_AxyBxy = input.World_AxyBxy;
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float Alpha;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Split_954ef1de09c941a795903bba9eb26174_R_1 = IN.World_AxyBxy[0];
                float _Split_954ef1de09c941a795903bba9eb26174_G_2 = IN.World_AxyBxy[1];
                float _Split_954ef1de09c941a795903bba9eb26174_B_3 = IN.World_AxyBxy[2];
                float _Split_954ef1de09c941a795903bba9eb26174_A_4 = IN.World_AxyBxy[3];
                float2 _Vector2_591ae19bf55f449c947cd20fcee8e28a_Out_0 = float2(_Split_954ef1de09c941a795903bba9eb26174_R_1, _Split_954ef1de09c941a795903bba9eb26174_G_2);
                float2 _Vector2_8e8c69650feb411b91cf8440542b7ce1_Out_0 = float2(_Split_954ef1de09c941a795903bba9eb26174_B_3, _Split_954ef1de09c941a795903bba9eb26174_A_4);
                float2 _Subtract_39168fd19b9740ed8393f020b7c24a82_Out_2;
                Unity_Subtract_float2(_Vector2_8e8c69650feb411b91cf8440542b7ce1_Out_0, _Vector2_591ae19bf55f449c947cd20fcee8e28a_Out_0, _Subtract_39168fd19b9740ed8393f020b7c24a82_Out_2);
                UnityTexture2D _Property_93cefd2915a14d31833e8ea9a4aa47fe_Out_0 = UnityBuildTexture2DStructNoScale(_LIGHT_DATA);
                Bindings_ShadowMapMeshRenderedCoords_9f89163cb8cb6ba4bb33e57610505d7a_float _ShadowMapMeshRenderedCoords_5baac292ade645f3b38b4aa5a6737b82;
                _ShadowMapMeshRenderedCoords_5baac292ade645f3b38b4aa5a6737b82.ScreenPosition = IN.ScreenPosition;
                float _ShadowMapMeshRenderedCoords_5baac292ade645f3b38b4aa5a6737b82_ShadowMapX_1;
                float _ShadowMapMeshRenderedCoords_5baac292ade645f3b38b4aa5a6737b82_LightY_2;
                SG_ShadowMapMeshRenderedCoords_9f89163cb8cb6ba4bb33e57610505d7a_float(_ShadowMapMeshRenderedCoords_5baac292ade645f3b38b4aa5a6737b82, _ShadowMapMeshRenderedCoords_5baac292ade645f3b38b4aa5a6737b82_ShadowMapX_1, _ShadowMapMeshRenderedCoords_5baac292ade645f3b38b4aa5a6737b82_LightY_2);
                Bindings_RetrieveLightData_f8cabe0f2253dd640a2513df996521d2_float _RetrieveLightData_e2c40d6c48b646289d3717a3198e0b20;
                float _RetrieveLightData_e2c40d6c48b646289d3717a3198e0b20_LightXVal_1;
                float _RetrieveLightData_e2c40d6c48b646289d3717a3198e0b20_LightYVal_2;
                float _RetrieveLightData_e2c40d6c48b646289d3717a3198e0b20_LightRVal_3;
                float4 _RetrieveLightData_e2c40d6c48b646289d3717a3198e0b20_LightLayerColor_4;
                SG_RetrieveLightData_f8cabe0f2253dd640a2513df996521d2_float(_Property_93cefd2915a14d31833e8ea9a4aa47fe_Out_0, _ShadowMapMeshRenderedCoords_5baac292ade645f3b38b4aa5a6737b82_LightY_2, _RetrieveLightData_e2c40d6c48b646289d3717a3198e0b20, _RetrieveLightData_e2c40d6c48b646289d3717a3198e0b20_LightXVal_1, _RetrieveLightData_e2c40d6c48b646289d3717a3198e0b20_LightYVal_2, _RetrieveLightData_e2c40d6c48b646289d3717a3198e0b20_LightRVal_3, _RetrieveLightData_e2c40d6c48b646289d3717a3198e0b20_LightLayerColor_4);
                float4 _Property_45abb271de1f4dde86f0570b251a0759_Out_0 = _LIGHT_BOUNDS_RECT;
                float _Property_2e4e2417640d44c89f1d652e3983c14d_Out_0 = _LIGHT_RADIUS_FACTOR;
                Bindings_LightDataToWorldValues_6437acaa6b9948e4a98c0c9c4d509415_float _LightDataToWorldValues_621a83fd8be54cb99e469b5973546216;
                float2 _LightDataToWorldValues_621a83fd8be54cb99e469b5973546216_LightPos_1;
                float _LightDataToWorldValues_621a83fd8be54cb99e469b5973546216_LightRadius_2;
                SG_LightDataToWorldValues_6437acaa6b9948e4a98c0c9c4d509415_float(_RetrieveLightData_e2c40d6c48b646289d3717a3198e0b20_LightXVal_1, _RetrieveLightData_e2c40d6c48b646289d3717a3198e0b20_LightYVal_2, _RetrieveLightData_e2c40d6c48b646289d3717a3198e0b20_LightRVal_3, _Property_45abb271de1f4dde86f0570b251a0759_Out_0, _Property_2e4e2417640d44c89f1d652e3983c14d_Out_0, _LightDataToWorldValues_621a83fd8be54cb99e469b5973546216, _LightDataToWorldValues_621a83fd8be54cb99e469b5973546216_LightPos_1, _LightDataToWorldValues_621a83fd8be54cb99e469b5973546216_LightRadius_2);
                Bindings_ShadowMapXToLightDir_ef84d5379730af24ca8d54f264203c99_float _ShadowMapXToLightDir_297b1e95e76f452cb6004f937a4bb434;
                float2 _ShadowMapXToLightDir_297b1e95e76f452cb6004f937a4bb434_LightDir_2;
                SG_ShadowMapXToLightDir_ef84d5379730af24ca8d54f264203c99_float(_ShadowMapMeshRenderedCoords_5baac292ade645f3b38b4aa5a6737b82_ShadowMapX_1, _ShadowMapXToLightDir_297b1e95e76f452cb6004f937a4bb434, _ShadowMapXToLightDir_297b1e95e76f452cb6004f937a4bb434_LightDir_2);
                float2 _Multiply_21c6cbdaf76f4ebf82bb4c8a99a24783_Out_2;
                Unity_Multiply_float2_float2(_ShadowMapXToLightDir_297b1e95e76f452cb6004f937a4bb434_LightDir_2, (_LightDataToWorldValues_621a83fd8be54cb99e469b5973546216_LightRadius_2.xx), _Multiply_21c6cbdaf76f4ebf82bb4c8a99a24783_Out_2);
                float _Property_899a702f1e934825b2eb316170959569_Out_0 = _Light_Penetration_Dist;
                float _Divide_d2bc28d5a7a141d0a09c6cda36f4f298_Out_2;
                Unity_Divide_float(_Property_899a702f1e934825b2eb316170959569_Out_0, _LightDataToWorldValues_621a83fd8be54cb99e469b5973546216_LightRadius_2, _Divide_d2bc28d5a7a141d0a09c6cda36f4f298_Out_2);
                Bindings_ComputeShadowCollisionDist_795ffb83f84919d488a0a48f552d820e_float _ComputeShadowCollisionDist_3ba8cdc7861a4cdbb8b41d4d6639b6f5;
                float _ComputeShadowCollisionDist_3ba8cdc7861a4cdbb8b41d4d6639b6f5_ShadowStartDist_0;
                float _ComputeShadowCollisionDist_3ba8cdc7861a4cdbb8b41d4d6639b6f5_ShadowFullDist_1;
                SG_ComputeShadowCollisionDist_795ffb83f84919d488a0a48f552d820e_float(_Vector2_591ae19bf55f449c947cd20fcee8e28a_Out_0, _Subtract_39168fd19b9740ed8393f020b7c24a82_Out_2, _LightDataToWorldValues_621a83fd8be54cb99e469b5973546216_LightPos_1, _Multiply_21c6cbdaf76f4ebf82bb4c8a99a24783_Out_2, _Divide_d2bc28d5a7a141d0a09c6cda36f4f298_Out_2, _ComputeShadowCollisionDist_3ba8cdc7861a4cdbb8b41d4d6639b6f5, _ComputeShadowCollisionDist_3ba8cdc7861a4cdbb8b41d4d6639b6f5_ShadowStartDist_0, _ComputeShadowCollisionDist_3ba8cdc7861a4cdbb8b41d4d6639b6f5_ShadowFullDist_1);
                float3 _Vector3_1f56e7eca9bf4baba044ba563a4637a6_Out_0 = float3(_ComputeShadowCollisionDist_3ba8cdc7861a4cdbb8b41d4d6639b6f5_ShadowStartDist_0, _ComputeShadowCollisionDist_3ba8cdc7861a4cdbb8b41d4d6639b6f5_ShadowFullDist_1, 0);
                float4 _Property_90db7cfef9ff4540990051b6230f1d9f_Out_0 = _Layer_Mask;
                Bindings_IntBitmaskviaColors_12a1259bd5b1b214c9650d16c5f761f0_float _IntBitmaskviaColors_72fbf0dd62264c2ebfcf268f43e3cf18;
                float _IntBitmaskviaColors_72fbf0dd62264c2ebfcf268f43e3cf18_Out_1;
                SG_IntBitmaskviaColors_12a1259bd5b1b214c9650d16c5f761f0_float(_Property_90db7cfef9ff4540990051b6230f1d9f_Out_0, _RetrieveLightData_e2c40d6c48b646289d3717a3198e0b20_LightLayerColor_4, _IntBitmaskviaColors_72fbf0dd62264c2ebfcf268f43e3cf18, _IntBitmaskviaColors_72fbf0dd62264c2ebfcf268f43e3cf18_Out_1);
                float3 _Lerp_544340f24b7b4795a39496933a35c27c_Out_3;
                Unity_Lerp_float3(float3(1, 1, 1), _Vector3_1f56e7eca9bf4baba044ba563a4637a6_Out_0, (_IntBitmaskviaColors_72fbf0dd62264c2ebfcf268f43e3cf18_Out_1.xxx), _Lerp_544340f24b7b4795a39496933a35c27c_Out_3);
                surface.BaseColor = _Lerp_544340f24b7b4795a39496933a35c27c_Out_3;
                surface.Alpha = 1;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                output.ViewSpaceNormal = TransformWorldToViewDir(output.WorldSpaceNormal);
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                output.ViewSpaceTangent = TransformWorldToViewDir(output.WorldSpaceTangent);
                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                output.ViewSpaceBiTangent = TransformWorldToViewDir(output.WorldSpaceBiTangent);
                output.ObjectSpacePosition = input.positionOS;
                output.uv0 = input.uv0;
                output.uv1 = input.uv1;
                output.uv2 = input.uv2;
                output.uv3 = input.uv3;

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                output.World_AxyBxy = input.World_AxyBxy;





                output.WorldSpacePosition = input.positionWS;
                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                    return output;
            }

            void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
            {
                result.vertex = float4(attributes.positionOS, 1);
                result.tangent = attributes.tangentOS;
                result.normal = attributes.normalOS;
                result.texcoord = attributes.uv0;
                result.texcoord1 = attributes.uv1;
                result.texcoord2 = attributes.uv2;
                result.texcoord3 = attributes.uv3;
                result.vertex = float4(vertexDescription.Position, 1);
                result.normal = vertexDescription.Normal;
                result.tangent = float4(vertexDescription.Tangent, 0);
                #if UNITY_ANY_INSTANCING_ENABLED
                #endif
            }

            void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
            {
                result.pos = varyings.positionCS;
                result.worldPos = varyings.positionWS;
                // World Tangent isn't an available input on v2f_surf


                #if UNITY_ANY_INSTANCING_ENABLED
                #endif
                #if UNITY_SHOULD_SAMPLE_SH
                #endif
                #if defined(LIGHTMAP_ON)
                #endif
                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                    result.fogCoord = varyings.fogFactorAndVertexLight.x;
                    COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                #endif

                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
            }

            void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
            {
                result.positionCS = surfVertex.pos;
                result.positionWS = surfVertex.worldPos;
                // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                // World Tangent isn't an available input on v2f_surf

                #if UNITY_ANY_INSTANCING_ENABLED
                #endif
                #if UNITY_SHOULD_SAMPLE_SH
                #endif
                #if defined(LIGHTMAP_ON)
                #endif
                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                    result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                    COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                #endif

                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

            ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }

                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite On
                ColorMask 0

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 3.0
                #pragma multi_compile_shadowcaster
                #pragma vertex vert
                #pragma fragment frag

                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>

                // Keywords
                #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                // GraphKeywords: <None>

                // Defines
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_SHADOWCASTER
                #define BUILTIN_TARGET_API 1
                #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                #endif
                #ifdef _BUILTIN_ALPHATEST_ON
                #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                #endif
                #ifdef _BUILTIN_AlphaClip
                #define _AlphaClip _BUILTIN_AlphaClip
                #endif
                #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                #endif


                // custom interpolator pre-include
                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                // Includes
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                // custom interpolators pre packing
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ViewSpaceNormal;
                     float3 WorldSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ViewSpaceTangent;
                     float3 WorldSpaceTangent;
                     float3 ObjectSpaceBiTangent;
                     float3 ViewSpaceBiTangent;
                     float3 WorldSpaceBiTangent;
                     float3 ObjectSpacePosition;
                     float4 uv0;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }


                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _Light_Penetration_Dist;
                float4 _Layer_Mask;
                CBUFFER_END

                    // Object and Global properties
                    SAMPLER(SamplerState_Linear_Repeat);
                    float _MAX_LIGHT_Y;
                    TEXTURE2D(_LIGHT_DATA);
                    SAMPLER(sampler_LIGHT_DATA);
                    float4 _LIGHT_DATA_TexelSize;
                    float4 _LIGHT_BOUNDS_RECT;
                    float _LIGHT_RADIUS_FACTOR;

                    // -- Property used by ScenePickingPass
                    #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                    #endif

                    // -- Properties used by SceneSelectionPass
                    #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                    #endif

                    // Graph Includes
                    // GraphIncludes: <None>

                    // Graph Functions

                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                    {
                    Out = A * B;
                    }

                    void Unity_Subtract_float(float A, float B, out float Out)
                    {
                        Out = A - B;
                    }

                    void Unity_Multiply_float_float(float A, float B, out float Out)
                    {
                    Out = A * B;
                    }

                    struct Bindings_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float
                    {
                    float3 ViewSpaceNormal;
                    float3 ViewSpaceTangent;
                    float3 ViewSpaceBiTangent;
                    half4 uv0;
                    };

                    void SG_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float(float _MAX_LIGHT_Y, Bindings_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float IN, out float3 Render_Pos_1)
                    {
                    float4 _UV_0c5fc72cff8e49e69d2b536d2079bce5_Out_0 = IN.uv0;
                    float4 _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2;
                    Unity_Multiply_float4_float4(_UV_0c5fc72cff8e49e69d2b536d2079bce5_Out_0, float4(2, 2, 1, 1), _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2);
                    float _Split_729dec92120d403f9c283d8f2eb53693_R_1 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[0];
                    float _Split_729dec92120d403f9c283d8f2eb53693_G_2 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[1];
                    float _Split_729dec92120d403f9c283d8f2eb53693_B_3 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[2];
                    float _Split_729dec92120d403f9c283d8f2eb53693_A_4 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[3];
                    float _Subtract_507e32db10514b0f8c9b54eecc49551e_Out_2;
                    Unity_Subtract_float(_Split_729dec92120d403f9c283d8f2eb53693_R_1, 1, _Subtract_507e32db10514b0f8c9b54eecc49551e_Out_2);
                    float _Multiply_f668bbea335543e0bab3f513cf18ab81_Out_2;
                    Unity_Multiply_float_float(_Subtract_507e32db10514b0f8c9b54eecc49551e_Out_2, unity_OrthoParams.x, _Multiply_f668bbea335543e0bab3f513cf18ab81_Out_2);
                    float _Property_5761738ad30d407ba2f64b21946346cb_Out_0 = _MAX_LIGHT_Y;
                    float _Multiply_a4d96df35e444398bb4e9f791e9e0f86_Out_2;
                    Unity_Multiply_float_float(_Split_729dec92120d403f9c283d8f2eb53693_G_2, _Property_5761738ad30d407ba2f64b21946346cb_Out_0, _Multiply_a4d96df35e444398bb4e9f791e9e0f86_Out_2);
                    float _Subtract_a0279ded92b94d14ae19bbf9a48c193f_Out_2;
                    Unity_Subtract_float(_Multiply_a4d96df35e444398bb4e9f791e9e0f86_Out_2, 1, _Subtract_a0279ded92b94d14ae19bbf9a48c193f_Out_2);
                    float _Multiply_2838e47c5c304495a9ccc3f45a2fed62_Out_2;
                    Unity_Multiply_float_float(_Subtract_a0279ded92b94d14ae19bbf9a48c193f_Out_2, unity_OrthoParams.y, _Multiply_2838e47c5c304495a9ccc3f45a2fed62_Out_2);
                    float3 _Vector3_04dbb23a96b044268454f33a0758b573_Out_0 = float3(_Multiply_f668bbea335543e0bab3f513cf18ab81_Out_2, _Multiply_2838e47c5c304495a9ccc3f45a2fed62_Out_2, -1);
                    float3 _Transform_289eaae8876145b2af01d6cb5419a047_Out_1 = TransformWorldToObject(mul(UNITY_MATRIX_I_V, float4(_Vector3_04dbb23a96b044268454f33a0758b573_Out_0.xyz, 1)).xyz);
                    Render_Pos_1 = _Transform_289eaae8876145b2af01d6cb5419a047_Out_1;
                    }

                    // Custom interpolators pre vertex
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                    // Graph Vertex
                    struct VertexDescription
                    {
                        float3 Position;
                        float3 Normal;
                        float3 Tangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        float _Property_49e2b6dc4b404117843f849765aae6ff_Out_0 = _MAX_LIGHT_Y;
                        Bindings_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06;
                        _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.ViewSpaceNormal = IN.ViewSpaceNormal;
                        _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.ViewSpaceTangent = IN.ViewSpaceTangent;
                        _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.ViewSpaceBiTangent = IN.ViewSpaceBiTangent;
                        _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.uv0 = IN.uv0;
                        float3 _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06_RenderPos_1;
                        SG_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float(_Property_49e2b6dc4b404117843f849765aae6ff_Out_0, _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06, _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06_RenderPos_1);
                        description.Position = _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06_RenderPos_1;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Custom interpolators, pre surface
                    #ifdef FEATURES_GRAPH_VERTEX
                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                    {
                    return output;
                    }
                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                    #endif

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float Alpha;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        surface.Alpha = 1;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs

                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                        output.ViewSpaceNormal = TransformWorldToViewDir(output.WorldSpaceNormal);
                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                        output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                        output.ViewSpaceTangent = TransformWorldToViewDir(output.WorldSpaceTangent);
                        output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                        output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                        output.ViewSpaceBiTangent = TransformWorldToViewDir(output.WorldSpaceBiTangent);
                        output.ObjectSpacePosition = input.positionOS;
                        output.uv0 = input.uv0;

                        return output;
                    }
                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                    #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                    #endif
                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                            return output;
                    }

                    void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                    {
                        result.vertex = float4(attributes.positionOS, 1);
                        result.tangent = attributes.tangentOS;
                        result.normal = attributes.normalOS;
                        result.texcoord = attributes.uv0;
                        result.vertex = float4(vertexDescription.Position, 1);
                        result.normal = vertexDescription.Normal;
                        result.tangent = float4(vertexDescription.Tangent, 0);
                        #if UNITY_ANY_INSTANCING_ENABLED
                        #endif
                    }

                    void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                    {
                        result.pos = varyings.positionCS;
                        // World Tangent isn't an available input on v2f_surf


                        #if UNITY_ANY_INSTANCING_ENABLED
                        #endif
                        #if UNITY_SHOULD_SAMPLE_SH
                        #endif
                        #if defined(LIGHTMAP_ON)
                        #endif
                        #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                            result.fogCoord = varyings.fogFactorAndVertexLight.x;
                            COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                        #endif

                        DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                    }

                    void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                    {
                        result.positionCS = surfVertex.pos;
                        // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                        // World Tangent isn't an available input on v2f_surf

                        #if UNITY_ANY_INSTANCING_ENABLED
                        #endif
                        #if UNITY_SHOULD_SAMPLE_SH
                        #endif
                        #if defined(LIGHTMAP_ON)
                        #endif
                        #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                            result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                            COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                        #endif

                        DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                    }

                    // --------------------------------------------------
                    // Main

                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                    ENDHLSL
                    }
                    Pass
                    {
                        Name "SceneSelectionPass"
                        Tags
                        {
                            "LightMode" = "SceneSelectionPass"
                        }

                        // Render State
                        Cull Off

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 3.0
                        #pragma multi_compile_instancing
                        #pragma vertex vert
                        #pragma fragment frag

                        // DotsInstancingOptions: <None>
                        // HybridV1InjectedBuiltinProperties: <None>

                        // Keywords
                        // PassKeywords: <None>
                        // GraphKeywords: <None>

                        // Defines
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD0
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SceneSelectionPass
                        #define BUILTIN_TARGET_API 1
                        #define SCENESELECTIONPASS 1
                        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                        #endif
                        #ifdef _BUILTIN_ALPHATEST_ON
                        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                        #endif
                        #ifdef _BUILTIN_AlphaClip
                        #define _AlphaClip _BUILTIN_AlphaClip
                        #endif
                        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                        #endif


                        // custom interpolator pre-include
                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                        // Includes
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        // custom interpolators pre packing
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                        struct Attributes
                        {
                             float3 positionOS : POSITION;
                             float3 normalOS : NORMAL;
                             float4 tangentOS : TANGENT;
                             float4 uv0 : TEXCOORD0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                             float4 positionCS : SV_POSITION;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };
                        struct SurfaceDescriptionInputs
                        {
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 ViewSpaceNormal;
                             float3 WorldSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 ViewSpaceTangent;
                             float3 WorldSpaceTangent;
                             float3 ObjectSpaceBiTangent;
                             float3 ViewSpaceBiTangent;
                             float3 WorldSpaceBiTangent;
                             float3 ObjectSpacePosition;
                             float4 uv0;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            ZERO_INITIALIZE(PackedVaryings, output);
                            output.positionCS = input.positionCS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }


                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float _Light_Penetration_Dist;
                        float4 _Layer_Mask;
                        CBUFFER_END

                            // Object and Global properties
                            SAMPLER(SamplerState_Linear_Repeat);
                            float _MAX_LIGHT_Y;
                            TEXTURE2D(_LIGHT_DATA);
                            SAMPLER(sampler_LIGHT_DATA);
                            float4 _LIGHT_DATA_TexelSize;
                            float4 _LIGHT_BOUNDS_RECT;
                            float _LIGHT_RADIUS_FACTOR;

                            // -- Property used by ScenePickingPass
                            #ifdef SCENEPICKINGPASS
                            float4 _SelectionID;
                            #endif

                            // -- Properties used by SceneSelectionPass
                            #ifdef SCENESELECTIONPASS
                            int _ObjectId;
                            int _PassValue;
                            #endif

                            // Graph Includes
                            // GraphIncludes: <None>

                            // Graph Functions

                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                            {
                            Out = A * B;
                            }

                            void Unity_Subtract_float(float A, float B, out float Out)
                            {
                                Out = A - B;
                            }

                            void Unity_Multiply_float_float(float A, float B, out float Out)
                            {
                            Out = A * B;
                            }

                            struct Bindings_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float
                            {
                            float3 ViewSpaceNormal;
                            float3 ViewSpaceTangent;
                            float3 ViewSpaceBiTangent;
                            half4 uv0;
                            };

                            void SG_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float(float _MAX_LIGHT_Y, Bindings_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float IN, out float3 Render_Pos_1)
                            {
                            float4 _UV_0c5fc72cff8e49e69d2b536d2079bce5_Out_0 = IN.uv0;
                            float4 _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2;
                            Unity_Multiply_float4_float4(_UV_0c5fc72cff8e49e69d2b536d2079bce5_Out_0, float4(2, 2, 1, 1), _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2);
                            float _Split_729dec92120d403f9c283d8f2eb53693_R_1 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[0];
                            float _Split_729dec92120d403f9c283d8f2eb53693_G_2 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[1];
                            float _Split_729dec92120d403f9c283d8f2eb53693_B_3 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[2];
                            float _Split_729dec92120d403f9c283d8f2eb53693_A_4 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[3];
                            float _Subtract_507e32db10514b0f8c9b54eecc49551e_Out_2;
                            Unity_Subtract_float(_Split_729dec92120d403f9c283d8f2eb53693_R_1, 1, _Subtract_507e32db10514b0f8c9b54eecc49551e_Out_2);
                            float _Multiply_f668bbea335543e0bab3f513cf18ab81_Out_2;
                            Unity_Multiply_float_float(_Subtract_507e32db10514b0f8c9b54eecc49551e_Out_2, unity_OrthoParams.x, _Multiply_f668bbea335543e0bab3f513cf18ab81_Out_2);
                            float _Property_5761738ad30d407ba2f64b21946346cb_Out_0 = _MAX_LIGHT_Y;
                            float _Multiply_a4d96df35e444398bb4e9f791e9e0f86_Out_2;
                            Unity_Multiply_float_float(_Split_729dec92120d403f9c283d8f2eb53693_G_2, _Property_5761738ad30d407ba2f64b21946346cb_Out_0, _Multiply_a4d96df35e444398bb4e9f791e9e0f86_Out_2);
                            float _Subtract_a0279ded92b94d14ae19bbf9a48c193f_Out_2;
                            Unity_Subtract_float(_Multiply_a4d96df35e444398bb4e9f791e9e0f86_Out_2, 1, _Subtract_a0279ded92b94d14ae19bbf9a48c193f_Out_2);
                            float _Multiply_2838e47c5c304495a9ccc3f45a2fed62_Out_2;
                            Unity_Multiply_float_float(_Subtract_a0279ded92b94d14ae19bbf9a48c193f_Out_2, unity_OrthoParams.y, _Multiply_2838e47c5c304495a9ccc3f45a2fed62_Out_2);
                            float3 _Vector3_04dbb23a96b044268454f33a0758b573_Out_0 = float3(_Multiply_f668bbea335543e0bab3f513cf18ab81_Out_2, _Multiply_2838e47c5c304495a9ccc3f45a2fed62_Out_2, -1);
                            float3 _Transform_289eaae8876145b2af01d6cb5419a047_Out_1 = TransformWorldToObject(mul(UNITY_MATRIX_I_V, float4(_Vector3_04dbb23a96b044268454f33a0758b573_Out_0.xyz, 1)).xyz);
                            Render_Pos_1 = _Transform_289eaae8876145b2af01d6cb5419a047_Out_1;
                            }

                            // Custom interpolators pre vertex
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                            // Graph Vertex
                            struct VertexDescription
                            {
                                float3 Position;
                                float3 Normal;
                                float3 Tangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                float _Property_49e2b6dc4b404117843f849765aae6ff_Out_0 = _MAX_LIGHT_Y;
                                Bindings_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06;
                                _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.ViewSpaceNormal = IN.ViewSpaceNormal;
                                _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.ViewSpaceTangent = IN.ViewSpaceTangent;
                                _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.ViewSpaceBiTangent = IN.ViewSpaceBiTangent;
                                _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.uv0 = IN.uv0;
                                float3 _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06_RenderPos_1;
                                SG_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float(_Property_49e2b6dc4b404117843f849765aae6ff_Out_0, _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06, _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06_RenderPos_1);
                                description.Position = _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06_RenderPos_1;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Custom interpolators, pre surface
                            #ifdef FEATURES_GRAPH_VERTEX
                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                            {
                            return output;
                            }
                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                            #endif

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                                float Alpha;
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                surface.Alpha = 1;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs

                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                output.ViewSpaceNormal = TransformWorldToViewDir(output.WorldSpaceNormal);
                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                output.ViewSpaceTangent = TransformWorldToViewDir(output.WorldSpaceTangent);
                                output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                output.ViewSpaceBiTangent = TransformWorldToViewDir(output.WorldSpaceBiTangent);
                                output.ObjectSpacePosition = input.positionOS;
                                output.uv0 = input.uv0;

                                return output;
                            }
                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                            #else
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                            #endif
                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                    return output;
                            }

                            void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                            {
                                result.vertex = float4(attributes.positionOS, 1);
                                result.tangent = attributes.tangentOS;
                                result.normal = attributes.normalOS;
                                result.texcoord = attributes.uv0;
                                result.vertex = float4(vertexDescription.Position, 1);
                                result.normal = vertexDescription.Normal;
                                result.tangent = float4(vertexDescription.Tangent, 0);
                                #if UNITY_ANY_INSTANCING_ENABLED
                                #endif
                            }

                            void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                            {
                                result.pos = varyings.positionCS;
                                // World Tangent isn't an available input on v2f_surf


                                #if UNITY_ANY_INSTANCING_ENABLED
                                #endif
                                #if UNITY_SHOULD_SAMPLE_SH
                                #endif
                                #if defined(LIGHTMAP_ON)
                                #endif
                                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                    result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                    COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                #endif

                                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                            }

                            void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                            {
                                result.positionCS = surfVertex.pos;
                                // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                // World Tangent isn't an available input on v2f_surf

                                #if UNITY_ANY_INSTANCING_ENABLED
                                #endif
                                #if UNITY_SHOULD_SAMPLE_SH
                                #endif
                                #if defined(LIGHTMAP_ON)
                                #endif
                                #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                    result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                    COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                #endif

                                DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                            }

                            // --------------------------------------------------
                            // Main

                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                            ENDHLSL
                            }
                            Pass
                            {
                                Name "ScenePickingPass"
                                Tags
                                {
                                    "LightMode" = "Picking"
                                }

                                // Render State
                                Cull Off

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 3.0
                                #pragma multi_compile_instancing
                                #pragma vertex vert
                                #pragma fragment frag

                                // DotsInstancingOptions: <None>
                                // HybridV1InjectedBuiltinProperties: <None>

                                // Keywords
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define ATTRIBUTES_NEED_TEXCOORD0
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS ScenePickingPass
                                #define BUILTIN_TARGET_API 1
                                #define SCENEPICKINGPASS 1
                                #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                                #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                #endif
                                #ifdef _BUILTIN_ALPHATEST_ON
                                #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                #endif
                                #ifdef _BUILTIN_AlphaClip
                                #define _AlphaClip _BUILTIN_AlphaClip
                                #endif
                                #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                #endif


                                // custom interpolator pre-include
                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                // Includes
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                // custom interpolators pre packing
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                struct Attributes
                                {
                                     float3 positionOS : POSITION;
                                     float3 normalOS : NORMAL;
                                     float4 tangentOS : TANGENT;
                                     float4 uv0 : TEXCOORD0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };
                                struct SurfaceDescriptionInputs
                                {
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 ViewSpaceNormal;
                                     float3 WorldSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 ViewSpaceTangent;
                                     float3 WorldSpaceTangent;
                                     float3 ObjectSpaceBiTangent;
                                     float3 ViewSpaceBiTangent;
                                     float3 WorldSpaceBiTangent;
                                     float3 ObjectSpacePosition;
                                     float4 uv0;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    ZERO_INITIALIZE(PackedVaryings, output);
                                    output.positionCS = input.positionCS;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }

                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }


                                // --------------------------------------------------
                                // Graph

                                // Graph Properties
                                CBUFFER_START(UnityPerMaterial)
                                float _Light_Penetration_Dist;
                                float4 _Layer_Mask;
                                CBUFFER_END

                                    // Object and Global properties
                                    SAMPLER(SamplerState_Linear_Repeat);
                                    float _MAX_LIGHT_Y;
                                    TEXTURE2D(_LIGHT_DATA);
                                    SAMPLER(sampler_LIGHT_DATA);
                                    float4 _LIGHT_DATA_TexelSize;
                                    float4 _LIGHT_BOUNDS_RECT;
                                    float _LIGHT_RADIUS_FACTOR;

                                    // -- Property used by ScenePickingPass
                                    #ifdef SCENEPICKINGPASS
                                    float4 _SelectionID;
                                    #endif

                                    // -- Properties used by SceneSelectionPass
                                    #ifdef SCENESELECTIONPASS
                                    int _ObjectId;
                                    int _PassValue;
                                    #endif

                                    // Graph Includes
                                    // GraphIncludes: <None>

                                    // Graph Functions

                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                    {
                                    Out = A * B;
                                    }

                                    void Unity_Subtract_float(float A, float B, out float Out)
                                    {
                                        Out = A - B;
                                    }

                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                    {
                                    Out = A * B;
                                    }

                                    struct Bindings_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float
                                    {
                                    float3 ViewSpaceNormal;
                                    float3 ViewSpaceTangent;
                                    float3 ViewSpaceBiTangent;
                                    half4 uv0;
                                    };

                                    void SG_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float(float _MAX_LIGHT_Y, Bindings_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float IN, out float3 Render_Pos_1)
                                    {
                                    float4 _UV_0c5fc72cff8e49e69d2b536d2079bce5_Out_0 = IN.uv0;
                                    float4 _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2;
                                    Unity_Multiply_float4_float4(_UV_0c5fc72cff8e49e69d2b536d2079bce5_Out_0, float4(2, 2, 1, 1), _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2);
                                    float _Split_729dec92120d403f9c283d8f2eb53693_R_1 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[0];
                                    float _Split_729dec92120d403f9c283d8f2eb53693_G_2 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[1];
                                    float _Split_729dec92120d403f9c283d8f2eb53693_B_3 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[2];
                                    float _Split_729dec92120d403f9c283d8f2eb53693_A_4 = _Multiply_e918b06d91324ddd973b5ef349c18f74_Out_2[3];
                                    float _Subtract_507e32db10514b0f8c9b54eecc49551e_Out_2;
                                    Unity_Subtract_float(_Split_729dec92120d403f9c283d8f2eb53693_R_1, 1, _Subtract_507e32db10514b0f8c9b54eecc49551e_Out_2);
                                    float _Multiply_f668bbea335543e0bab3f513cf18ab81_Out_2;
                                    Unity_Multiply_float_float(_Subtract_507e32db10514b0f8c9b54eecc49551e_Out_2, unity_OrthoParams.x, _Multiply_f668bbea335543e0bab3f513cf18ab81_Out_2);
                                    float _Property_5761738ad30d407ba2f64b21946346cb_Out_0 = _MAX_LIGHT_Y;
                                    float _Multiply_a4d96df35e444398bb4e9f791e9e0f86_Out_2;
                                    Unity_Multiply_float_float(_Split_729dec92120d403f9c283d8f2eb53693_G_2, _Property_5761738ad30d407ba2f64b21946346cb_Out_0, _Multiply_a4d96df35e444398bb4e9f791e9e0f86_Out_2);
                                    float _Subtract_a0279ded92b94d14ae19bbf9a48c193f_Out_2;
                                    Unity_Subtract_float(_Multiply_a4d96df35e444398bb4e9f791e9e0f86_Out_2, 1, _Subtract_a0279ded92b94d14ae19bbf9a48c193f_Out_2);
                                    float _Multiply_2838e47c5c304495a9ccc3f45a2fed62_Out_2;
                                    Unity_Multiply_float_float(_Subtract_a0279ded92b94d14ae19bbf9a48c193f_Out_2, unity_OrthoParams.y, _Multiply_2838e47c5c304495a9ccc3f45a2fed62_Out_2);
                                    float3 _Vector3_04dbb23a96b044268454f33a0758b573_Out_0 = float3(_Multiply_f668bbea335543e0bab3f513cf18ab81_Out_2, _Multiply_2838e47c5c304495a9ccc3f45a2fed62_Out_2, -1);
                                    float3 _Transform_289eaae8876145b2af01d6cb5419a047_Out_1 = TransformWorldToObject(mul(UNITY_MATRIX_I_V, float4(_Vector3_04dbb23a96b044268454f33a0758b573_Out_0.xyz, 1)).xyz);
                                    Render_Pos_1 = _Transform_289eaae8876145b2af01d6cb5419a047_Out_1;
                                    }

                                    // Custom interpolators pre vertex
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                    // Graph Vertex
                                    struct VertexDescription
                                    {
                                        float3 Position;
                                        float3 Normal;
                                        float3 Tangent;
                                    };

                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                    {
                                        VertexDescription description = (VertexDescription)0;
                                        float _Property_49e2b6dc4b404117843f849765aae6ff_Out_0 = _MAX_LIGHT_Y;
                                        Bindings_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06;
                                        _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.ViewSpaceNormal = IN.ViewSpaceNormal;
                                        _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.ViewSpaceTangent = IN.ViewSpaceTangent;
                                        _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.ViewSpaceBiTangent = IN.ViewSpaceBiTangent;
                                        _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06.uv0 = IN.uv0;
                                        float3 _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06_RenderPos_1;
                                        SG_ShadowMapMeshRenderPos_aa2c3f5491974c049835a54041d8279a_float(_Property_49e2b6dc4b404117843f849765aae6ff_Out_0, _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06, _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06_RenderPos_1);
                                        description.Position = _ShadowMapMeshRenderPos_4a596f4114894493865f0ca119cf1f06_RenderPos_1;
                                        description.Normal = IN.ObjectSpaceNormal;
                                        description.Tangent = IN.ObjectSpaceTangent;
                                        return description;
                                    }

                                    // Custom interpolators, pre surface
                                    #ifdef FEATURES_GRAPH_VERTEX
                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                    {
                                    return output;
                                    }
                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                    #endif

                                    // Graph Pixel
                                    struct SurfaceDescription
                                    {
                                        float Alpha;
                                    };

                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                    {
                                        SurfaceDescription surface = (SurfaceDescription)0;
                                        surface.Alpha = 1;
                                        return surface;
                                    }

                                    // --------------------------------------------------
                                    // Build Graph Inputs

                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                    {
                                        VertexDescriptionInputs output;
                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                        output.ObjectSpaceNormal = input.normalOS;
                                        output.WorldSpaceNormal = TransformObjectToWorldNormal(input.normalOS);
                                        output.ViewSpaceNormal = TransformWorldToViewDir(output.WorldSpaceNormal);
                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                        output.WorldSpaceTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                                        output.ViewSpaceTangent = TransformWorldToViewDir(output.WorldSpaceTangent);
                                        output.ObjectSpaceBiTangent = normalize(cross(input.normalOS, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
                                        output.WorldSpaceBiTangent = TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
                                        output.ViewSpaceBiTangent = TransformWorldToViewDir(output.WorldSpaceBiTangent);
                                        output.ObjectSpacePosition = input.positionOS;
                                        output.uv0 = input.uv0;

                                        return output;
                                    }
                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                    {
                                        SurfaceDescriptionInputs output;
                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                    #else
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                    #endif
                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                            return output;
                                    }

                                    void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                    {
                                        result.vertex = float4(attributes.positionOS, 1);
                                        result.tangent = attributes.tangentOS;
                                        result.normal = attributes.normalOS;
                                        result.texcoord = attributes.uv0;
                                        result.vertex = float4(vertexDescription.Position, 1);
                                        result.normal = vertexDescription.Normal;
                                        result.tangent = float4(vertexDescription.Tangent, 0);
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                        #endif
                                    }

                                    void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                    {
                                        result.pos = varyings.positionCS;
                                        // World Tangent isn't an available input on v2f_surf


                                        #if UNITY_ANY_INSTANCING_ENABLED
                                        #endif
                                        #if UNITY_SHOULD_SAMPLE_SH
                                        #endif
                                        #if defined(LIGHTMAP_ON)
                                        #endif
                                        #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                            result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                            COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                        #endif

                                        DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                    }

                                    void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                    {
                                        result.positionCS = surfVertex.pos;
                                        // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                        // World Tangent isn't an available input on v2f_surf

                                        #if UNITY_ANY_INSTANCING_ENABLED
                                        #endif
                                        #if UNITY_SHOULD_SAMPLE_SH
                                        #endif
                                        #if defined(LIGHTMAP_ON)
                                        #endif
                                        #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                            result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                            COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                        #endif

                                        DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                    }

                                    // --------------------------------------------------
                                    // Main

                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                    ENDHLSL
                                    }
    }
        CustomEditorForRenderPipeline "UnityEditor.Rendering.BuiltIn.ShaderGraph.BuiltInUnlitGUI" ""
                                        CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                        FallBack "Hidden/Shader Graph/FallbackError"
}