using UnityEditor;
using UnityEngine;
using MEG.FL2D;

[CustomEditor(typeof(Collider2DShadowMesh2D))]
public class Collider2DShadowMesh2DEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        Collider2DShadowMesh2D i = (Collider2DShadowMesh2D)target;
        if (GUILayout.Button("Rebuild"))
        {
            i.Rebuild();
        }
    }
}
