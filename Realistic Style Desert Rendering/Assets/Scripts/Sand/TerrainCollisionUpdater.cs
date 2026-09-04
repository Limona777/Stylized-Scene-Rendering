using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TerrainCollisionUpdater : MonoBehaviour
{
    [SerializeField] private ComputeShader terrainComputeShader;

    [SerializeField] private TerrainInteractionManager interactionManager;

    private Vector3[] vertexPositions;
    private Vector2[] vertexUVs;
    private Vector3[] vertexNormals;
    private int[] triangleIndices;

    private MeshFilter meshFilter;
    private MeshCollider meshCollider;
    private Mesh dynamicMesh;

    private ComputeBuffer inputVertexBuffer;
    private ComputeBuffer outputVertexBuffer;

    private VertexInputData[] inputData;
    private VertexOutputData[] outputData;

    private float maxHeight;
    private Texture heightTexture;

    private const int WARP_SIZE = 32;
    private int dispatchGroups;
    private int vertexCount;

    struct VertexInputData
    {
        public Vector3 position;
        public Vector2 uv;
    }

    struct VertexOutputData
    {
        public Vector3 position;
    }

    void Start()
    {
        InitializeMeshData();
        InitializeComputeBuffers();
    }

    void InitializeMeshData()
    {
        meshFilter = GetComponent<MeshFilter>();
        meshCollider = GetComponent<MeshCollider>();

        if (meshFilter == null || meshCollider == null)
        {
            Debug.LogError("Lack MeshFilter or MeshCollider");
            return;
        }

        dynamicMesh = Instantiate(meshFilter.sharedMesh);
        dynamicMesh.MarkDynamic();
        meshFilter.sharedMesh = dynamicMesh;
        meshCollider.sharedMesh = dynamicMesh;
        meshCollider.convex = false;

        vertexPositions = dynamicMesh.vertices;
        vertexUVs = dynamicMesh.uv;
        vertexNormals = dynamicMesh.normals;
        triangleIndices = dynamicMesh.triangles;

        vertexCount = vertexPositions.Length;
        dispatchGroups = vertexCount / WARP_SIZE + 1;

        inputData = new VertexInputData[vertexCount];
        outputData = new VertexOutputData[vertexCount];

        for (int i = 0; i < vertexCount; i++)
        {
            inputData[i].position = vertexPositions[i];
            inputData[i].uv = vertexUVs[i];
            outputData[i].position = vertexPositions[i];
        }
    }

    void InitializeComputeBuffers()
    {
        int count = vertexPositions.Length;

        inputVertexBuffer = new ComputeBuffer(count, 20);
        outputVertexBuffer = new ComputeBuffer(count, 12);

        inputVertexBuffer.SetData(inputData);
        outputVertexBuffer.SetData(outputData);

        int kernelIndex = terrainComputeShader.FindKernel("TerrainDeform");
        terrainComputeShader.SetBuffer(kernelIndex, "vertexBufferIn", inputVertexBuffer);
        terrainComputeShader.SetBuffer(kernelIndex, "vertexBufferOut", outputVertexBuffer);

        terrainComputeShader.SetInt("vertexCount", vertexCount);
        terrainComputeShader.SetFloat("hasHeightTexture", 0.0f);
    }

    void Update()
    {
        if (terrainComputeShader == null) return;

        int kernelIndex = terrainComputeShader.FindKernel("TerrainDeform");

        if (heightTexture != null)
        {
            terrainComputeShader.SetTexture(kernelIndex, "heightMap", heightTexture);
            terrainComputeShader.SetFloat("hasHeightTexture", 1.0f);
        }
        else
        {
            terrainComputeShader.SetFloat("hasHeightTexture", 0.0f);
        }

        terrainComputeShader.SetFloat("maxHeight", maxHeight);

        terrainComputeShader.Dispatch(kernelIndex, dispatchGroups, 1, 1);

        outputVertexBuffer.GetData(outputData);

        for (int i = 0; i < vertexCount; i++)
        {
            vertexPositions[i] = outputData[i].position;
        }

        UpdateDynamicMesh();
    }

    void UpdateDynamicMesh()
    {
        dynamicMesh.Clear();
        dynamicMesh.vertices = vertexPositions;
        dynamicMesh.uv = vertexUVs;
        dynamicMesh.normals = vertexNormals;
        dynamicMesh.triangles = triangleIndices;
        dynamicMesh.RecalculateNormals();
        dynamicMesh.RecalculateBounds();

        meshCollider.sharedMesh = null;
        meshCollider.sharedMesh = dynamicMesh;
    }

    public void SetHeightTexture(Texture texture)
    {
        heightTexture = texture;
    }

    public void SetMaxHeight(float height)
    {
        maxHeight = height;
    }

    void OnDestroy()
    {
        if (inputVertexBuffer != null)
            inputVertexBuffer.Release();

        if (outputVertexBuffer != null)
            outputVertexBuffer.Release();
    }
}