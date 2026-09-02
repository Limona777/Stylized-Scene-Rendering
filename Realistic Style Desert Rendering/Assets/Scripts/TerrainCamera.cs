using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TerrainCamera : MonoBehaviour
{
    private RenderTexture _rT1;
    private RenderTexture _rT2;
    private RenderTexture _rTFloor;

    private bool rtFlag = true;
    private bool firstFrame = true;
    private Camera cam;

    [Header("Materials and Shaders")]
    public Material sandReceiveMat;
    private Material sandRenderMat;
    public Shader showDepthShader;
    public string replacementShaderTag = "TerrainEffect";

    [Header("Terrain")]
    public GameObject floorObj;
    public TerrainDeformCollider sandCollider;

    [Header("Initial HeightMap")]
    public Texture initHeight;
    public float tillingInit;
    [Range(0.0f, 1.0f)] public float initMin = 0.0f;
    [Range(0.0f, 1.0f)] public float initMax = 1.0f;
    public Material tillingInitMat;

    [Header("General Settings")]
    [Range(0.001f, 100.0f)] public float sandThickness = 1.0f;
    public float sandFarPlane = 10.0f;
    public Vector2 planeSize = new Vector2(10.0f, 10.0f);
    public int renderTextureSize = 512;
    public float sandSmoothMultiplier = 1.5f;

    [Header("Collect Particles Setup")]
    public bool useParticle = false;
    public float heightImpactStrength = 1.0f;
    public float colorImpactStrength = 1.0f;

    void Start()
    {
        cam = GetComponent<Camera>();
        if (cam == null)
            cam = gameObject.AddComponent<Camera>();

        sandRenderMat = floorObj.GetComponent<Renderer>().material;

        cam.transform.position = floorObj.transform.position - floorObj.transform.up;
        cam.transform.LookAt(floorObj.transform.position + floorObj.transform.up, floorObj.transform.forward);

        int zBuffSize;

        if (useParticle)
            zBuffSize = 0;
        else
            zBuffSize = 16;

        _rT1 = new RenderTexture(renderTextureSize, renderTextureSize, zBuffSize);
        _rT2 = new RenderTexture(renderTextureSize, renderTextureSize, zBuffSize);

        _rTFloor = new RenderTexture(renderTextureSize, renderTextureSize, 0);

        SetupRenderToTexture(_rT1);
        SetupRenderToTexture(_rT2);
        SetupRenderToTexture(_rTFloor);

        tillingInitMat.SetFloat("_Tilling", tillingInit);
        tillingInitMat.SetFloat("_Max", initMax);
        tillingInitMat.SetFloat("_Min", initMin);

        Graphics.Blit(initHeight, _rT1, tillingInitMat);

        cam.nearClipPlane = 0.0f;
        cam.orthographic = true;
        cam.aspect = 1.0f;
        cam.clearFlags = CameraClearFlags.Color;
        cam.backgroundColor = Color.black;
    }

    void SetupRenderToTexture(RenderTexture rt)
    {
        rt.antiAliasing = 2;
        rt.format = RenderTextureFormat.ARGBFloat;
        rt.useMipMap = false;
    }

    void UpdateCamera()
    {
        cam.farClipPlane = sandFarPlane;
        cam.orthographicSize = planeSize.x / 2;

        sandReceiveMat.SetFloat("_SandMaxHeight", sandThickness);
        sandReceiveMat.SetFloat("_SandFarPlane", sandFarPlane);
        sandReceiveMat.SetFloat("_HeightImpactStrength", heightImpactStrength);
        sandReceiveMat.SetFloat("_ColorImpactStrength", colorImpactStrength);
        sandReceiveMat.SetFloat("_SandSmoothMultiplier", sandSmoothMultiplier);

        sandRenderMat.SetFloat("_SandMaxHeight", sandThickness);
        sandRenderMat.SetFloat("_Scale", floorObj.transform.lossyScale.y);

        if (firstFrame)
        {
            cam.SetReplacementShader(showDepthShader, "SandFloor");
            sandReceiveMat.SetTexture("_FloorHeight", _rTFloor);
            cam.targetTexture = _rTFloor;
            cam.Render();
        }
        else
        {
            cam.SetReplacementShader(showDepthShader, replacementShaderTag);

            if (sandCollider != null)
                sandCollider.SetMaxHeight(sandThickness);

            if (rtFlag)
            {
                if (sandCollider != null)
                    sandCollider.SetHeightTexture(_rT2);

                sandRenderMat.SetTexture("_DisplaceTex", _rT2);
                sandReceiveMat.SetTexture("_SandState", _rT2);
                sandReceiveMat.SetTexture("_MainTex", _rT1);
                cam.targetTexture = _rT2;
            }
            else
            {
                if (sandCollider != null)
                    sandCollider.SetHeightTexture(_rT1);

                sandRenderMat.SetTexture("_DisplaceTex", _rT1);
                sandReceiveMat.SetTexture("_SandState", _rT1);
                sandReceiveMat.SetTexture("_MainTex", _rT2);
                cam.targetTexture = _rT1;
            }
        }
    }

    void Update()
    {
        UpdateCamera();
    }

    void OnPostRender()
    {
        if (!firstFrame)
        {
            RenderTexture temp = RenderTexture.GetTemporary(_rT1.descriptor);

            if (rtFlag)
            {
                Graphics.Blit(_rT1, temp, sandReceiveMat);
                Graphics.Blit(temp, _rT2);
            }
            else
            {
                Graphics.Blit(_rT2, temp, sandReceiveMat);
                Graphics.Blit(temp, _rT1);
            }

            RenderTexture.ReleaseTemporary(temp);
            rtFlag = !rtFlag;
        }

        firstFrame = false;
    }

    public Texture GetFloorHeight()
    {
        return _rTFloor;
    }
}