//UNITY_SHADER_NO_UPGRADE
#ifndef SHADOWCOLLISION_INCLUDED
#define SHADOWCOLLISION_INCLUDED

// SPos = Start of shadow line segment
// SVec = Extent of shadow line segment
// LPos = Position of light
// LVec = Extend of light vector for this sample of the shadow map
// IntersectVal = multiplier of LVec that the light can maximally extend (or 1 if the light should not be blocked)
void ShadowCollision_float(float2 SPos, float2 SVec, float2 LPos, float2 LVec, out float IntersectVal)
{
	float shadowIntersect;
	IntersectVal =
		(-SVec.y * (SPos.x - LPos.x) + SVec.x * (SPos.y - LPos.y))
		/ (-LVec.x * SVec.y + SVec.x * LVec.y);
	shadowIntersect =
		(LVec.x * (SPos.y - LPos.y) - LVec.y * (SPos.x - LPos.x))
		/ (-LVec.x * SVec.y + SVec.x * LVec.y);
	if (IntersectVal <= 0 || shadowIntersect <= 0 || IntersectVal > 1 || shadowIntersect > 1 ) {
		IntersectVal = 1;
	}
}

#endif //SHADOWCOLLISION_INCLUDED