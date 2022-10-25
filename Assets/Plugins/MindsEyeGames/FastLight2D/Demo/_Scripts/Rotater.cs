using UnityEngine;

public class Rotater : MonoBehaviour
{
    public float SpinRate = 360f;
    
    public virtual void Update()
    {
        Vector3 rot = transform.localEulerAngles;
        rot.z += SpinRate * Time.deltaTime;
        transform.localEulerAngles = rot;
    }
}
