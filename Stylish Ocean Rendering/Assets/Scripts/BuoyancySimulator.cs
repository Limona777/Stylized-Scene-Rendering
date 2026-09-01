using UnityEngine;

public class BuoyancySimulator : MonoBehaviour
{
    public float amplitude = 0.2f;

    public float frequency = 1.5f;

    private Vector3 initialPosition;

    void Start()
    {
        initialPosition = transform.position;
    }

    void Update()
    {
        float offset = amplitude * Mathf.Sin(frequency * Time.time);
        transform.position = initialPosition + new Vector3(0, offset, 0);
    }
}