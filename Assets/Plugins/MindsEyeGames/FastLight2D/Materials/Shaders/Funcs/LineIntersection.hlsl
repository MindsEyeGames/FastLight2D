//UNITY_SHADER_NO_UPGRADE
#ifndef LINEINTERSECTION_INCLUDED
#define LINEINTERSECTION_INCLUDED

void LineIntersection_float(float2 AStart, float2 ADir, float2 BStart, float2 BDir, out float AIntersect, out float BIntersect)
{
	AIntersect = (-ADir.y * (AStart.x - BStart.x) + ADir.x * (AStart.y - BStart.y)) / (-BDir.x * ADir.y + ADir.x * BDir.y);
    BIntersect = ( BDir.x * (AStart.y - BStart.y) - BDir.y * (AStart.x - BStart.x)) / (-BDir.x * ADir.y + ADir.x * BDir.y);
}

#endif //LINEINTERSECTION_INCLUDED