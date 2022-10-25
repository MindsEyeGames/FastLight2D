//UNITY_SHADER_NO_UPGRADE
#ifndef FLOAT2COLOR_INCLUDED
#define FLOAT2COLOR_INCLUDED

void Float2Color_float(float In, out float4 Out)
{
	float4 kEncodeMul = float4(1.0, 255.0, 65025.0, 16581375.0);
	float kEncodeBit = 1.0/255.0;
	Out = kEncodeMul * In;
	Out = frac (Out);
	Out -= Out.yzww * kEncodeBit;
}

#endif //FLOAT2COLOR_INCLUDED