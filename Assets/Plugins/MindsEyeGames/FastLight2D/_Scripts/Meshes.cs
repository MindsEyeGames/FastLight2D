using System;
using UnityEngine;

namespace MEG.FL2D
{
    public class Meshes
    {
        public class MeshDef
        {
            public Mesh Instance { get; private set; }
            public Func<Mesh> BuildFunc { get; private set; }

            public MeshDef(Func<Mesh> buildFunc)
            {
                Instance = null;
                BuildFunc = buildFunc;
            }

            public Mesh Get()
            {
                if (Instance == null) Instance = BuildFunc();
                return Instance;
            }

            public void Clear()
            {
                if(Instance != null) UnityEngine.Object.Destroy(Instance);
                Instance = null;
            }
        }

        public static MeshDef SIMPLE_LIGHT_QUAD { get; private set; } = new MeshDef(() => {
            Mesh mesh = new Mesh();
            mesh.name = "FL2D - Simple Light Quad";

            int numV = 4;
            Vector3[] verts = new Vector3[numV]; // vertex
            Vector2[] uv = new Vector2[numV]; // regular UV
            Vector2[] uv2 = new Vector2[numV]; // light direction UV

            verts[0] = new Vector3(-1, -1, 0);
            uv[0] = new Vector2(0, 0);
            uv2[0] = new Vector2(-1, -1);

            verts[1] = new Vector3(-1, 1, 0);
            uv[1] = new Vector2(0, 1);
            uv2[1] = new Vector2(-1, 1);

            verts[2] = new Vector3(1, 1, 0);
            uv[2] = new Vector2(1, 1);
            uv2[2] = new Vector2(1, 1);

            verts[3] = new Vector3(1, -1, 0);
            uv[3] = new Vector2(1, 0);
            uv2[3] = new Vector2(1, -1);

            int numT = 6;
            int[] tris = new int[numT];

            tris[0] = 0;
            tris[1] = 1;
            tris[2] = 2;

            tris[3] = 0;
            tris[4] = 2;
            tris[5] = 3;

            mesh.vertices = verts;
            mesh.uv = uv;
            mesh.uv2 = uv2;
            mesh.triangles = tris;

            mesh.UploadMeshData(true);
            return mesh;
        });
    }
}