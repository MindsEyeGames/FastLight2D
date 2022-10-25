using System.Collections;
using UnityEngine;

public class SetToMousePos : MonoBehaviour
{
    public Camera Camera;

    public virtual void LateUpdate()
    {
        Vector3 targetPos = Camera.ScreenToWorldPoint(Input.mousePosition);
        targetPos.z = transform.position.z;
        transform.position = targetPos;
    }
}