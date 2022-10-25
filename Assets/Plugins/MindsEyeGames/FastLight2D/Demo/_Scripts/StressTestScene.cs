using MEG.FL2D;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StressTestScene : MonoBehaviour
{
    public static Vector3 RandUnitXY()
    {
        float rad = Random.value * Mathf.PI * 2;
        return new Vector3(Mathf.Cos(rad), Mathf.Sin(rad), 0);
    }

    public GameObject LightPrefab;
    public Transform[] LightParents = { };
    public AnimationCurve LightRandOffset = AnimationCurve.Linear(0, 1, 1, 10);
    public Gradient LightColor = new Gradient();
    public AnimationCurve LightRadius = AnimationCurve.Linear(0, 1, 1, 5);

    public virtual void AddLight()
    {
        Transform parent = LightParents[Random.Range(0, LightParents.Length)];
        GameObject newL = Instantiate(LightPrefab, parent);
        newL.transform.localPosition = LightRandOffset.Evaluate(Random.value) * RandUnitXY();

        FastLight2D light = newL.GetComponent<FastLight2D>();
        light.Color = LightColor.Evaluate(Random.value);
        light.Radius = LightRadius.Evaluate(Random.value);
    }

    public virtual void DeleteLight()
    {
        if (FastLight2D.ActiveLights.Count == 0) return;
        Destroy(FastLight2D.ActiveLights[Random.Range(0, FastLight2D.ActiveLights.Count)].gameObject);
    }

    [Space(10)]

    public List<GameObject> ShadowMeshes = new List<GameObject>();
    public GameObject[] ShadowMeshPrefabs = { };
    public Transform[] ShadowMeshParents = { };
    public AnimationCurve ShadowMeshRandOffset = AnimationCurve.Linear(0, 1, 1, 15);

    public virtual void AddShadowMesh()
    {
        GameObject prefab = ShadowMeshPrefabs[Random.Range(0, ShadowMeshPrefabs.Length)];
        Transform parent = ShadowMeshParents[Random.Range(0, ShadowMeshParents.Length)];
        GameObject newSM = Instantiate(prefab, parent);
        newSM.transform.localPosition = ShadowMeshRandOffset.Evaluate(Random.value) * RandUnitXY();
        newSM.transform.localEulerAngles = new Vector3(0, 0, Random.value * 360f);
        ShadowMeshes.Add(newSM);
    }

    public virtual void DeleteShadowMesh()
    {
        if (ShadowMeshes.Count == 0) return;
        Destroy(ShadowMeshes[Random.Range(0, ShadowMeshes.Count)].gameObject);
    }

    [Space(10)]

    public KeyCode KeyAddLight = KeyCode.A;
    public KeyCode KeyDeleteLight = KeyCode.D;
    public KeyCode KeyAddShadowMesh = KeyCode.Q;
    public KeyCode KeyDeleteShadowMesh = KeyCode.E;

    public virtual void Update()
    {
        if (Input.GetKeyDown(KeyAddLight)) AddLight();
        if (Input.GetKeyDown(KeyDeleteLight)) DeleteLight();
        if (Input.GetKeyDown(KeyAddShadowMesh)) AddShadowMesh();
        if (Input.GetKeyDown(KeyDeleteShadowMesh)) DeleteShadowMesh();
    }
}
