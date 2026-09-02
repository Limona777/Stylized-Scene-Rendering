using UnityEngine;

[ExecuteInEditMode]
public class HeatWaveEffect : MonoBehaviour
{
    public Shader heatWaveShader;
    private Material _heatWaveMaterial;
    public Material HeatWaveMaterial
    {
        get
        {
            if (_heatWaveMaterial == null)
            {
                _heatWaveMaterial = new Material(heatWaveShader);
                _heatWaveMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return _heatWaveMaterial;
        }
    }

    [Range(0, 2)] public float distortTimeFactor = 0.5f;
    [Range(0, 0.2f)] public float luminosityAmount = 0.03f;
    public Texture2D noiseTex;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (heatWaveShader == null || noiseTex == null)
        {
            Graphics.Blit(source, destination);
            return;
        }

        HeatWaveMaterial.SetFloat("_DistortTimeFactor", distortTimeFactor);
        HeatWaveMaterial.SetFloat("_LuminosityAmount", luminosityAmount);
        HeatWaveMaterial.SetTexture("_NoiseTex", noiseTex);

        Graphics.Blit(source, destination, HeatWaveMaterial);
    }

    void OnDestroy()
    {
        if (_heatWaveMaterial != null)
            DestroyImmediate(_heatWaveMaterial);
    }
}