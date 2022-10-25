//UNITY_SHADER_NO_UPGRADE
#ifndef INTBITMASK_VIACOLORS_INCLUDED
#define INTBITMASK_VIACOLORS_INCLUDED

uint IBVC_ColorToUint(float4 C) {
    return (uint) (C.x * 255.9) |
        ((uint) (C.y * 255.9) << 8) |
        ((uint) (C.z * 255.9) << 16) |
        ((uint) (C.w * 255.9) << 24);
}

void IntBitmaskViaColors_float(float4 A, float4 B, out float Out)
{
    if ((IBVC_ColorToUint(A) & IBVC_ColorToUint(B)) != 0) {
        Out = 1;
    }
    else {
        Out = 0;
    }
}

#endif //INTBITMASK_VIACOLORS_INCLUDED