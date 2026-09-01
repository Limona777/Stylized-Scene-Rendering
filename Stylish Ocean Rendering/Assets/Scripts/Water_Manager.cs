using System;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;
using RTHandle = UnityEngine.Rendering.RTHandle;
using UnityEditor;
using UnityEngine.Experimental.Rendering;

namespace Toon_Water
{
    [ExecuteAlways]
    public class Water_Manager : MonoBehaviour
    {
        [Serializable]
        public class Ripple_Settings
        {
            public float size = 10;
            public float speed = 4;
            public float fbm_amplitude = 0.5f;
            public float fbm_amplitude_attenuation = 0.5f;
            public float fbm_frequency = 2;
        }

        [Header("Basic Attributes")]
        public Gradient absorption_ramp;
        [Range(0, 1)] public float specular = 0.3f;
        [Range(0, 1)] public float metallic = 0;
        [Range(0, 1)] public float smoothness = 0.5f;
        [Range(0, 10)] public float normal_strength = 1;
        [Range(0, 10)] public float max_visibility = 10f;
        [Range(0, 10)] public float refractive_strength = 1;
        [Range(0, 0.5f)] public float reflection_distort = 0.1f;

        [Space(20)]
        [Header("Subsurface Scattering")]
        public Gradient scatter_ramp;
        [Range(0, 1)] public float sss_strength = 0.5f;
        [Range(0, 10)] public float sss_distort = 0.3f;
        [Range(0, 10)] public float sss_power = 3f;
        [Range(0, 10)] public float sss_scale = 1f;

        [Space(20)]
        [Header("Wave")]
        public Ripple_Settings Ripple_01 = new Ripple_Settings();
        public Ripple_Settings Ripple_02 = new Ripple_Settings();

        [Space(20)]
        [Header("Foam")]
        public Color foam_color = Color.white;
        public float foam_scope = 20;
        [Space(10)]
        [Range(1, 2)] public float foam_01_width = 1.1f;
        [Range(0, 10)] public float foam_01_interval = 1.0f;
        [Range(0, 100)] public float foam_01_speed = 10f;
        public float foam_01_distort_noise_scale = 1.0f;
        [Space(10)]
        [Range(1, 20)] public float foam_02_width = 20;
        [Range(0, 5)] public float foam_02_distort_strength = 1;

        private GameObject Water_Plane;
        private Material Water_Material;
        private const string Water_Material_Path = "Custom/toon_water";
        private Texture2D Water_Absorption_Scatter_Ramp;
        private const string Water_Absorption_Scatter_Ramp_Name = "Water_Absorption_Scatter_Ramp";

        private void OnEnable()
        {
            Init();
            Generate_Ramp_Texture();
        }

        private void OnDisable()
        {
            CleanUp();
        }

        private void OnDestroy()
        {
            CleanUp();
        }

        private void OnApplicationQuit()
        {
            CleanUp();
        }

        private void OnValidate()
        {
            Generate_Ramp_Texture();
        }

        void Update()
        {
            Update_Water_Plane();
            Update_Water_Material();
        }

        void Init()
        {
            if (transform.childCount < 1)
            {
                Water_Plane = GameObject.CreatePrimitive(PrimitiveType.Plane);
            }
            else
            {
                Water_Plane = transform.GetChild(0).gameObject;
            }

            Water_Plane.name = "Water_Plane";
            Water_Plane.transform.SetParent(transform);

            Water_Material = CoreUtils.CreateEngineMaterial(Water_Material_Path);
            Water_Plane.GetComponent<MeshRenderer>().material = Water_Material;
        }

        void Update_Water_Plane()
        {
            Water_Plane.transform.localScale = transform.localScale;
            Water_Plane.transform.localRotation = transform.localRotation;
            Water_Plane.transform.position = transform.position;
        }

        void Update_Water_Material()
        {
            if (Water_Plane == null) return;
            if (Water_Plane.GetComponent<MeshRenderer>().sharedMaterial == null) return;

            Material m = Water_Plane.GetComponent<MeshRenderer>().sharedMaterial;

            m.SetFloat("_normal_strength", normal_strength);
            m.SetFloat("_specular", specular);
            m.SetFloat("_metallic", metallic);
            m.SetFloat("_smoothness", smoothness);
            m.SetTexture("_Water_Absorption_Scatter_Map", Water_Absorption_Scatter_Ramp);
            m.SetFloat("_max_visibility", max_visibility);
            m.SetFloat("_refractive_strength", refractive_strength);
            m.SetFloat("_reflective_distort", reflection_distort);
            m.SetFloat("_sss_distort", sss_distort);
            m.SetFloat("_sss_power", sss_power);
            m.SetFloat("_sss_scale", sss_scale);
            m.SetFloat("_sss_strength", sss_strength);

            m.SetFloat("_foam_scope", foam_scope);
            m.SetFloat("_foam_01_width", foam_01_width);
            m.SetFloat("_foam_01_interval", foam_01_interval);
            m.SetFloat("_foam_01_speed", foam_01_speed);
            m.SetFloat("_foam_01_distort_noise_scale", foam_01_distort_noise_scale);
            m.SetColor("_foam_color", foam_color);
            m.SetFloat("_foam_02_width", foam_02_width);
            m.SetFloat("_foam_02_distort_strength", foam_02_distort_strength);

            m.SetFloat("_Ripple01_Size", Ripple_01.size);
            m.SetFloat("_Ripple01_Speed", Ripple_01.speed);
            m.SetFloat("_Ripple01_Amplitude", Ripple_01.fbm_amplitude);
            m.SetFloat("_Ripple01_Frequency", Ripple_01.fbm_frequency);

            m.SetFloat("_Ripple02_Size", Ripple_02.size);
            m.SetFloat("_Ripple02_Speed", Ripple_02.speed);
            m.SetFloat("_Ripple02_Amplitude", Ripple_02.fbm_amplitude);
            m.SetFloat("_Ripple02_Frequency", Ripple_02.fbm_frequency);
        }

        void CleanUp()
        {
            if (Water_Plane != null)
            {
                DestroyImmediate(Water_Plane);
                Water_Plane = null;
            }
            CoreUtils.Destroy(Water_Material);
        }

        void Generate_Ramp_Texture()
        {
            if (Water_Absorption_Scatter_Ramp == null)
            {
                Water_Absorption_Scatter_Ramp = new Texture2D(128, 4, GraphicsFormat.B8G8R8A8_SRGB, TextureCreationFlags.None);
            }

            var cols = new Color[512];
            for (int i = 0; i < 128; i++)
            {
                cols[i] = absorption_ramp.Evaluate(i / 128f);
                cols[i + 128] = absorption_ramp.Evaluate(i / 128f);
                cols[i + 256] = scatter_ramp.Evaluate(i / 128f);
                cols[i + 384] = scatter_ramp.Evaluate(i / 128f);
            }

            Water_Absorption_Scatter_Ramp.SetPixels(cols);
            Water_Absorption_Scatter_Ramp.Apply();
        }
    }

    [CustomEditor(typeof(Water_Manager)), CanEditMultipleObjects]
    public class Water_Manager_editor : Editor
    {
        public override void OnInspectorGUI()
        {
            base.DrawDefaultInspector();
        }
    }
}