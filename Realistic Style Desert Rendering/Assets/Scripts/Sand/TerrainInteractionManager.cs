using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TerrainInteractionManager : MonoBehaviour
{
    [Header("Camera")]
    [SerializeField] private Camera terrainCamera;
    [SerializeField] private LayerMask interactionLayers = -1;

    [Header("Mat & Shader")]
    [SerializeField] private Material deformationMaterial;
    [SerializeField] private Material renderMaterial;
    [SerializeField] private Shader depthCaptureShader;

    [Header("Terrain")]
    [SerializeField] private GameObject terrainObject;
    [SerializeField] private TerrainCollisionUpdater collisionUpdater;

    [Header("Height Map")]
    [SerializeField] private Texture2D initialHeightMap;
    [SerializeField] private float textureTiling = 1.0f;
    [SerializeField] private float minHeight = 0.0f;
    [SerializeField] private float maxHeight = 1.0f;

    [Header("Settings")]
    [SerializeField] private float sandThickness = 1.0f;
    [SerializeField] private float cameraDistance = 10.0f;
    [SerializeField] private Vector2 terrainSize = new Vector2(10f, 10f);
    [SerializeField] private int textureResolution = 512;
    [SerializeField] private float smoothMultiplier = 1.5f;

    [Header("Interaction")]
    [SerializeField] private bool enableParticleInteraction = false;
    [SerializeField] private float heightImpact = 1.0f;
    [SerializeField] private float colorImpact = 1.0f;

    [Header("Camera Mode")]
    [SerializeField] private bool useOrthographic = true;
    [SerializeField] private float perspectiveFOV = 60f;

    private RenderTexture heightMapA;
    private RenderTexture heightMapB;
    private RenderTexture floorHeightMap;

    private bool useFirstBuffer = true;
    private bool isFirstFrame = true;

    void Start()
    {
        InitializeSystem();
    }

    void InitializeSystem()
    {
        if (terrainCamera == null)
        {
            terrainCamera = GetComponent<Camera>();
            if (terrainCamera == null)
                terrainCamera = gameObject.AddComponent<Camera>();
        }

        if (terrainObject == null)
        {
            Debug.LogError("Lack Terrain");
            return;
        }

        renderMaterial = terrainObject.GetComponent<Renderer>().material;

        PositionCameraBelowTerrain();
        CreateRenderTextures();
        InitializeHeightMap();
        ConfigureCamera();
    }

    void PositionCameraBelowTerrain()
    {
        Vector3 terrainCenter = terrainObject.transform.position;
        Vector3 downDir = -terrainObject.transform.up;

        if (useOrthographic)
        {
            terrainCamera.transform.position = terrainCenter + downDir * 1.0f;
        }
        else
        {
            float fov = perspectiveFOV * Mathf.Deg2Rad;
            float halfHeight = terrainSize.y * 0.5f;
            float halfWidth = terrainSize.x * 0.5f;
            float distance = Mathf.Max(halfHeight, halfWidth) / Mathf.Tan(fov * 0.5f);
            distance = Mathf.Max(distance, cameraDistance);
            terrainCamera.transform.position = terrainCenter - downDir * distance;
        }
        terrainCamera.transform.LookAt(terrainCenter + terrainObject.transform.up, terrainObject.transform.forward);
    }

    void CreateRenderTextures()
    {
        int depthBufferSize = enableParticleInteraction ? 0 : 16;

        heightMapA = new RenderTexture(textureResolution, textureResolution, depthBufferSize);
        heightMapB = new RenderTexture(textureResolution, textureResolution, depthBufferSize);
        floorHeightMap = new RenderTexture(textureResolution, textureResolution, 0);

        ConfigureRenderTexture(heightMapA);
        ConfigureRenderTexture(heightMapB);
        ConfigureRenderTexture(floorHeightMap);
    }

    void ConfigureRenderTexture(RenderTexture rt)
    {
        rt.antiAliasing = 2;
        rt.format = RenderTextureFormat.ARGBFloat;
        rt.useMipMap = false;
    }

    void InitializeHeightMap()
    {
        Material initMaterial = new Material(Shader.Find("Custom/HeightMapInitializer"));
        initMaterial.SetFloat("_Tiling", textureTiling);
        initMaterial.SetFloat("_Min", minHeight);
        initMaterial.SetFloat("_Max", maxHeight);

        Graphics.Blit(initialHeightMap, heightMapA, initMaterial);
        Destroy(initMaterial);
    }

    void ConfigureCamera()
    {
        terrainCamera.nearClipPlane = 0.01f;
        terrainCamera.aspect = 1.0f;
        terrainCamera.clearFlags = CameraClearFlags.Color;
        terrainCamera.backgroundColor = Color.black;
        terrainCamera.farClipPlane = cameraDistance;

        if (useOrthographic)
        {
            terrainCamera.orthographic = true;
            terrainCamera.orthographicSize = terrainSize.x / 2;
        }
        else
        {
            terrainCamera.orthographic = false;
            terrainCamera.fieldOfView = perspectiveFOV;
        }
    }

    void Update()
    {
        UpdateShaderParameters();

        if (isFirstFrame)
        {
            CaptureFloorHeight();
        }
        else
        {
            ProcessTerrainInteraction();
        }
    }

    void UpdateShaderParameters()
    {
        if (deformationMaterial != null)
        {
            deformationMaterial.SetFloat("_MaxHeight", sandThickness);
            deformationMaterial.SetFloat("_FarPlane", cameraDistance);
            deformationMaterial.SetFloat("_ImpactStrength", heightImpact);
            deformationMaterial.SetFloat("_Smoothness", smoothMultiplier);
        }
        if (renderMaterial != null)
        {
            renderMaterial.SetFloat("_MaxHeight", sandThickness);
            renderMaterial.SetFloat("_Scale", terrainObject.transform.lossyScale.y);
        }
    }

    void CaptureFloorHeight()
    {
        terrainCamera.SetReplacementShader(depthCaptureShader, "DepthCapture");
        deformationMaterial.SetTexture("_FloorTex", floorHeightMap);
        terrainCamera.targetTexture = floorHeightMap;
        terrainCamera.Render();
    }

    void ProcessTerrainInteraction()
    {
        terrainCamera.SetReplacementShader(depthCaptureShader, "DepthCapture");
        terrainCamera.cullingMask = interactionLayers;

        if (collisionUpdater != null)
            collisionUpdater.SetMaxHeight(sandThickness);

        if (useFirstBuffer)
        {
            if (collisionUpdater != null)
                collisionUpdater.SetHeightTexture(heightMapB);

            renderMaterial.SetTexture("_HeightMap", heightMapB);
            deformationMaterial.SetTexture("_DepthTex", heightMapB);
            deformationMaterial.SetTexture("_MainTex", heightMapA);
            terrainCamera.targetTexture = heightMapB;
        }
        else
        {
            if (collisionUpdater != null)
                collisionUpdater.SetHeightTexture(heightMapA);

            renderMaterial.SetTexture("_HeightMap", heightMapA);
            deformationMaterial.SetTexture("_DepthTex", heightMapA);
            deformationMaterial.SetTexture("_MainTex", heightMapB);
            terrainCamera.targetTexture = heightMapA;
        }
    }

    void OnPostRender()
    {
        if (!isFirstFrame)
        {
            RenderTexture tempBuffer = RenderTexture.GetTemporary(heightMapA.descriptor);

            if (useFirstBuffer)
            {
                Graphics.Blit(heightMapA, tempBuffer, deformationMaterial);
                Graphics.Blit(tempBuffer, heightMapB);
            }
            else
            {
                Graphics.Blit(heightMapB, tempBuffer, deformationMaterial);
                Graphics.Blit(tempBuffer, heightMapA);
            }

            RenderTexture.ReleaseTemporary(tempBuffer);
            useFirstBuffer = !useFirstBuffer;
        }

        isFirstFrame = false;
    }

    public Texture GetFloorHeightMap()
    {
        return floorHeightMap;
    }

    void OnDestroy()
    {
        if (heightMapA != null) heightMapA.Release();
        if (heightMapB != null) heightMapB.Release();
        if (floorHeightMap != null) floorHeightMap.Release();
    }
}