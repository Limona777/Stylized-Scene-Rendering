using UnityEngine;

[System.Serializable]
public class FloaterPoint
{
    public Transform pos;
    public float degree_buoyancy;
}

[System.Serializable]
public class DragPoints
{
    public Transform foward;
    public DragPointForceFowardType fowardType;
    public Transform[] points;

    public Vector3 ClampFoward(Vector3 dragforce)
    {
        if (!foward)
            return Vector3.zero;

        Vector3 local = foward.InverseTransformDirection(dragforce);

        switch (fowardType)
        {
            case DragPointForceFowardType.Only:
                local.x = 0;
                local.y = 0;
                break;
        }

        return foward.TransformDirection(local);
    }
}

public enum DragPointForceFowardType
{
    Only
}

public class BuoyancyController : MonoBehaviour
{
    public float waterHeight;
    public float bodyHeight;
    public float gravityFloating;
    public float waterDrag;
    public float angularDrag = 0.5f;

    public FloaterPoint[] floaterPoints;
    public DragPoints dragPoints;

    private Rigidbody rb;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
        if (rb == null)
            Debug.LogError("Lack Rigidbody");
    }

    void FixedUpdate()
    {
        Vector3 pivot = Vector3.zero;
        float degreeAmount = 0;
        int pCount = 0;

        foreach (var fp in floaterPoints)
        {
            float bottonhigh = fp.pos.position.y - bodyHeight / 2f;
            if (bottonhigh < waterHeight)
            {
                float degree = (waterHeight - bottonhigh) / bodyHeight;
                degree = Mathf.Clamp01(degree);
                pivot += fp.pos.position * degree;
                degreeAmount += degree;
                pCount++;
            }
        }

        if (pCount > 0)
        {
            Vector3 forcePos = pivot / degreeAmount;
            Vector3 buo = -Physics.gravity * gravityFloating * (degreeAmount / floaterPoints.Length);
            rb.AddForceAtPosition(buo, forcePos, ForceMode.Acceleration);
        }

        if (dragPoints != null && dragPoints.points != null)
        {
            foreach (Transform p in dragPoints.points)
            {
                if (p == null) continue;

                float bottonhigh = p.position.y - bodyHeight / 2f;
                float degree = 0f;
                if (bottonhigh < waterHeight)
                {
                    degree = (waterHeight - bottonhigh) / bodyHeight;
                    degree = Mathf.Clamp01(degree);
                }

                Vector3 pointVelocity = rb.GetPointVelocity(p.position);
                Vector3 dragF = -pointVelocity * waterDrag * degree;
                Vector3 clampedDrag = dragPoints.ClampFoward(dragF);

                if (degree > 0)
                    rb.AddForceAtPosition(clampedDrag, p.position, ForceMode.Force);
            }
        }

        Vector3 angularVelocity = rb.angularVelocity;
        rb.AddTorque(-angularVelocity * angularDrag, ForceMode.Acceleration);

        float verticalDampingCoeff = angularDrag * 0.3f;
        Vector3 verticalForce = new Vector3(0, -rb.velocity.y * verticalDampingCoeff, 0);
        rb.AddForce(verticalForce, ForceMode.Acceleration);
    }
}