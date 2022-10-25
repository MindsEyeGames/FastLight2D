//UNITY_SHADER_NO_UPGRADE
#ifndef SHADOWCOLLISION_RADIUS_INCLUDED
#define SHADOWCOLLISION_RADIUS_INCLUDED

float SCR_CircleIntersectVal(float2 SPos, float SR, float2 LPos, float2 LVec) {
    float lenL2 = dot(LVec, LVec);
    if (lenL2 <= 0.0000001) {
        return 1;
    }

    float2 Offset = SPos - LPos;
    const float t = dot(Offset, LVec) / lenL2;
    if (t <= 0) { // Behind light ray, ignore
        return 1;
    }

    float2 LClosest = LPos + (t * LVec);
    float2 D = SPos - LClosest;
    float lenD2 = dot(D, D);
    float R2 = SR * SR;

    if (R2 < lenD2) { // Beyond radius of light.
        return 1;
    }

    float lenM = sqrt(R2 - lenD2);
    float lenL = sqrt(lenL2);
    return max(0, min(1, (distance(LPos, LClosest) - lenM) / lenL));
}

// SPos = Start of shadow line segment
// SVec = Extent of shadow line segment
// LPos = Position of light
// LVec = Extend of light vector for this sample of the shadow map
// IntersectVal = multiplier of LVec that the light can maximally extend (or 1 if the light should not be blocked)
float SCR_LineIntersectVal(float2 SPos, float2 SVec, float2 LPos, float2 LVec)
{
    float lI = (-SVec.y * (SPos.x - LPos.x) + SVec.x * (SPos.y - LPos.y)) / (-LVec.x * SVec.y + SVec.x * LVec.y);
    float sI = (LVec.x * (SPos.y - LPos.y) - LVec.y * (SPos.x - LPos.x)) / (-LVec.x * SVec.y + SVec.x * LVec.y);
    if (lI <= 0 || lI > 1 || sI <= 0 || sI > 1) {
        return 1;
    }
    return lI;
}

// SPos = Start of shadow line segment
// SVec = Extent of shadow line segment
// SR = Radius of the shadow line segment
// LPos = Position of light
// LVec = Extent of light vector for this sample of the shadow map
// IntersectVal = multiplier of LVec that the light can maximally extend (or 1 if the light should not be blocked)
void ShadowCollision_Radius_float(float2 SPos, float2 SVec, float SR, float2 LPos, float2 LVec, out float IntersectVal)
{
    float shiftMult = SR / length(SVec);
    float2 SMidShift = float2(-SVec.y * shiftMult, SVec.x * shiftMult);

    // NOTE: This is a bit inefficient - we do 4 operations for every pixel in the
    // shadow map - but the core approach should be so fast and the alternatives I've
    // have been sufficiently annoying that I think this simple solution is good for now.
    IntersectVal = min(
        min(
            SCR_CircleIntersectVal(SPos, SR, LPos, LVec),
            SCR_CircleIntersectVal(SPos + SVec, SR, LPos, LVec)
        ),
        min(
            SCR_LineIntersectVal(SPos + SMidShift, SVec, LPos, LVec),
            SCR_LineIntersectVal(SPos - SMidShift, SVec, LPos, LVec)
        )
    );
}

#endif //SHADOWCOLLISION_RADIUS_INCLUDED