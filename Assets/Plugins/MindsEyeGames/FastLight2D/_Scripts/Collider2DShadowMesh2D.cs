using UnityEngine;

namespace MEG.FL2D
{
    public class Collider2DShadowMesh2D : BaseShadowMesh2D
    {
        [Space(10)]

        [SerializeField] private Collider2D[] _colliders;
        public Collider2D[] Colliders
        {
            get { return _colliders; }
            set { _colliders = value; }
        }

        [Tooltip("Set this to true if this shadow mesh is the parent of (potentially many) child colliders that should be combined into a single shadow map.")]
        [SerializeField] private bool _detectCollidersInChildren = false;
        public bool DetectCollidersInChildren
        {
            get { return _detectCollidersInChildren; }
            set { _detectCollidersInChildren = value; }
        }

        protected virtual Collider2D[] DetectColliders()
        {
            if (DetectCollidersInChildren) return GetComponentsInChildren<Collider2D>();
            return GetComponents<Collider2D>();
        }

        public override void Rebuild()
        {
            if (Colliders == null || Colliders.Length == 0) Colliders = DetectColliders();
            base.Rebuild();
        }

        #region Mesh
        protected override void BuildMesh(Mesh m)
        {
            int numLines = 0;
            foreach (var c in Colliders) numLines += NumLinesFor(c);

            Vector3[] v = new Vector3[numLines * 4];
            Vector2[] screenPoint = new Vector2[v.Length]; // Target render area
            Vector2[] linePointA = new Vector2[v.Length]; // in object space
            Vector2[] linePointB = new Vector2[v.Length]; // in object space
            Vector2[] radius = new Vector2[v.Length]; // in object space
            int[] tris = new int[numLines * 6];

            int vI = 0;
            int tI = 0;
            foreach (var c in Colliders) PushLinesFor(c, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);

            Mesh.vertices = v;
            Mesh.uv = screenPoint;
            Mesh.uv2 = linePointA;
            Mesh.uv3 = linePointB;
            Mesh.uv4 = radius;
            Mesh.triangles = tris;
        }

        protected virtual int NumLinesFor(Collider2D c)
        {
            if (c == null) return 0;

            if (c.usedByComposite) return 0; // Presumes we have the composite in our list and it does NOT have used by composite set to true

            if (c is BoxCollider2D) return 4;
            if (c is CircleCollider2D) return 1;
            if (c is CapsuleCollider2D) return 1;
            if (c is EdgeCollider2D) return ((EdgeCollider2D)c).pointCount - 1;
            if (c is PolygonCollider2D) return ((PolygonCollider2D)c).GetTotalPointCount();
            if (c is CompositeCollider2D)
            {
                CompositeCollider2D comp = (CompositeCollider2D)c;
                int numLines = 0;
                for (int i = 0; i < comp.pathCount; i++) numLines += comp.GetPathPointCount(i);
                return numLines;
            }

            Debug.LogWarningFormat("Unhandled Collider2D to ShadowMesh2D: {0}, collider will be skipped when building mesh", c);
            return 0;
        }

        protected virtual void PushLinesFor(Collider2D c, Vector3[] v, Vector2[] screenPoint, Vector2[] linePointA, Vector2[] linePointB, Vector2[] radius, int[] tris, ref int vI, ref int tI)
        {
            if (c == null) return;
            if (c.usedByComposite) return;
            else if (c is EdgeCollider2D) PushLinesForEdge((EdgeCollider2D)c, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);
            else if (c is BoxCollider2D) PushLinesForBox((BoxCollider2D)c, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);
            else if (c is CircleCollider2D) PushLinesForCircle((CircleCollider2D)c, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);
            else if (c is CapsuleCollider2D) PushLinesForCapsule((CapsuleCollider2D)c, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);
            else if (c is PolygonCollider2D) PushLinesForPolygon((PolygonCollider2D)c, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);
            else if (c is CompositeCollider2D) PushLinesForComposite((CompositeCollider2D)c, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);
        }

        protected virtual void PushLinesForEdge(EdgeCollider2D e, Vector3[] v, Vector2[] screenPoint, Vector2[] linePointA, Vector2[] linePointB, Vector2[] radius, int[] tris, ref int vI, ref int tI)
        {
            Vector2[] p = e.points;
            for (int i = 1; i < p.Length; i++)
                PushLine(e.transform, p[i - 1], p[i], e.edgeRadius, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);
        }

        protected virtual void PushLinesForBox(BoxCollider2D b, Vector3[] v, Vector2[] screenPoint, Vector2[] linePointA, Vector2[] linePointB, Vector2[] radius, int[] tris, ref int vI, ref int tI)
        {
            Vector2 o = b.offset;
            Vector2 shiftA = b.size / 2;
            Vector2 shiftB = new Vector2(shiftA.x, -shiftA.y);
            PushLine(b.transform, o - shiftA, o - shiftB, b.edgeRadius, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);
            PushLine(b.transform, o + shiftA, o - shiftB, b.edgeRadius, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);
            PushLine(b.transform, o + shiftA, o + shiftB, b.edgeRadius, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);
            PushLine(b.transform, o - shiftA, o + shiftB, b.edgeRadius, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);
        }

        protected virtual void PushLinesForCircle(CircleCollider2D c, Vector3[] v, Vector2[] screenPoint, Vector2[] linePointA, Vector2[] linePointB, Vector2[] radius, int[] tris, ref int vI, ref int tI)
        {
            Vector2 o = c.offset;
            Vector2 shift = new Vector2(0.001f, 0); // To give edge math something to work with, expected to be small enough to not be noticeable
            PushLine(c.transform, o - shift, o + shift, c.radius, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);
        }

        protected virtual void PushLinesForCapsule(CapsuleCollider2D c, Vector3[] v, Vector2[] screenPoint, Vector2[] linePointA, Vector2[] linePointB, Vector2[] radius, int[] tris, ref int vI, ref int tI)
        {
            Vector2 o = c.offset;
            Vector2 s = c.size / 2;
            float r = c.direction == CapsuleDirection2D.Horizontal ? s.y : s.x;
            float e = Mathf.Max((c.direction == CapsuleDirection2D.Horizontal ? s.x : s.y) - r, 0.001f);
            Vector2 shift = c.direction == CapsuleDirection2D.Horizontal ? new Vector2(e, 0) : new Vector2(0, e);
            PushLine(c.transform, o - shift, o + shift, r, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);
        }

        protected virtual void PushLinesForPolygon(PolygonCollider2D p, Vector3[] v, Vector2[] screenPoint, Vector2[] linePointA, Vector2[] linePointB, Vector2[] radius, int[] tris, ref int vI, ref int tI)
        {
            Vector2 o = p.offset;
            for (int i = 0; i < p.pathCount; i++)
            {
                var path = p.GetPath(i);
                for(int pI = 0; pI < path.Length; pI++)
                    PushLine(p.transform, o + path[pI], o + path[(pI + 1) % path.Length], 0, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);
            }
        }

        /// Only really used for composite colliders. If you need to expand this array for your game go for it, it should have minimal impact on anything.
        private static readonly Vector2[] COLLIDER_POINTS = new Vector2[100];

        protected virtual void PushLinesForComposite(CompositeCollider2D c, Vector3[] v, Vector2[] screenPoint, Vector2[] linePointA, Vector2[] linePointB, Vector2[] radius, int[] tris, ref int vI, ref int tI)
        {
            Vector2 o = c.offset;
            float r = c.edgeRadius;
            for (int i = 0; i < c.pathCount; i++)
            {
                int numPoints = c.GetPath(i, COLLIDER_POINTS);
                for (int pI = 0; pI < numPoints; pI++)
                    PushLine(c.transform, o + COLLIDER_POINTS[pI], o + COLLIDER_POINTS[(pI + 1) % numPoints], r, v, screenPoint, linePointA, linePointB, radius, tris, ref vI, ref tI);
            }
        }

        protected virtual void PushLine(Transform t, Vector2 a, Vector2 b, float r, Vector3[] v, Vector2[] screenPoint, Vector2[] linePointA, Vector2[] linePointB, Vector2[] radius, int[] tris, ref int vI, ref int tI)
        {
            if (t != transform)
            {
                Vector3 posA = t.TransformPoint(new Vector3(a.x, a.y, 0));
                posA = transform.InverseTransformPoint(posA);
                a = new Vector2(posA.x, posA.y);

                Vector3 posB = t.TransformPoint(new Vector3(b.x, b.y, 0));
                posB = transform.InverseTransformPoint(posB);
                b = new Vector2(posB.x, posB.y);

                Vector3 rA = transform.InverseTransformPoint(t.TransformPoint(Vector3.zero));
                Vector3 rB = transform.InverseTransformPoint(t.TransformPoint(new Vector3(0.70710678f * r, 0.70710678f * r, 0)));
                r = Vector2.Distance(rA, rB);
            }

            v[vI + 0] = new Vector3(a.x, a.y, -0.25f);
            v[vI + 1] = new Vector3(a.x, a.y, 0.25f);
            v[vI + 2] = new Vector3(b.x, b.y, 0.25f);
            v[vI + 3] = new Vector3(b.x, b.y, -0.25f);

            screenPoint[vI + 0] = new Vector2(0, 0);
            screenPoint[vI + 1] = new Vector2(0, 1);
            screenPoint[vI + 2] = new Vector2(1, 1);
            screenPoint[vI + 3] = new Vector2(1, 0);

            linePointA[vI + 0] = a;
            linePointA[vI + 1] = a;
            linePointA[vI + 2] = a;
            linePointA[vI + 3] = a;

            linePointB[vI + 0] = b;
            linePointB[vI + 1] = b;
            linePointB[vI + 2] = b;
            linePointB[vI + 3] = b;

            Vector2 rUV = new Vector2(r, 0);
            radius[vI + 0] = rUV;
            radius[vI + 1] = rUV;
            radius[vI + 2] = rUV;
            radius[vI + 3] = rUV;

            tris[tI + 0] = vI;
            tris[tI + 1] = vI + 1;
            tris[tI + 2] = vI + 2;
            tris[tI + 3] = vI;
            tris[tI + 4] = vI + 2;
            tris[tI + 5] = vI + 3;

            vI += 4;
            tI += 6;
        }
        #endregion
    }
}