using UnityEngine;

[RequireComponent(typeof(Camera))]
public class EnableDepthTexture : MonoBehaviour
{
    private Camera _cam;

    void Awake()
    {
        _cam = GetComponent<Camera>();
    }

    void OnEnable()
    {
        _cam.depthTextureMode |= DepthTextureMode.Depth;
    }
}