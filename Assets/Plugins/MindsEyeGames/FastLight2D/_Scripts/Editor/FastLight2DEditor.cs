using UnityEditor;
using UnityEngine;
using MEG.FL2D;

[CustomEditor(typeof(FastLight2D))]
public class FastLight2DEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        FastLight2D i = (FastLight2D)target;
        if (GUILayout.Button("Refresh Light"))
        {
            i.RefreshAllLightValues();
        }
    }
}
