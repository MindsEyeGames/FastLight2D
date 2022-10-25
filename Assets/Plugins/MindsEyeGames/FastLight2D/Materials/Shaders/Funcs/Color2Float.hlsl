//UNITY_SHADER_NO_UPGRADE
#ifndef COLOR2FLOAT_INCLUDED
#define COLOR2FLOAT_INCLUDED

void Color2Float_float(float4 In, out float Out)
{
    float4 kDecodeDot = float4(1.0, 1/255.0, 1/65025.0, 1/16581375.0);
    Out = dot( In, kDecodeDot );
}

#endif //COLOR2FLOAT_INCLUDED