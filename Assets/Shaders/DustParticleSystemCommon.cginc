#include "NoiseSimplex.cginc"

#define PI 3.14159265359
#define IDENTITY4x4 float4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
#define SMALLFLOAT 1e-6
#define SMALLFLOAT3 float3(1e-6,0,0)
// --------------------------------------------------
// Structures
// --------------------------------------------------

// Particle system buffer
struct DustParticle
{
    float3 pos;
    float3 vel;
    float4 cd;
    float4 startColor;
    float age;
    float lifespan;
    float mass;
    float momentum;
    float3 scale;
    float4x4 rot;
    int active;
};

struct DustMesh
{
    float3 pos;
    float3 normal;
    float3 cd;
};

// --------------------------------------------------
// Functions
// --------------------------------------------------

float rand(float2 co)
{
	return frac(sin(dot(co.xy,float2(12.9898,78.233))) * 43758.5453123);
}

float3 randomSpherePoint(float3 rand, float scatterVolume = 1.0) 
{
    float3 thetaPhiR = clamp(rand, float3(0,0,0), float3(1,1,1));
    float3 newPoint = float3(0,0,0);

    thetaPhiR.x *= 2. * PI;
    thetaPhiR.y = ((thetaPhiR.y * 2.) - 1.) * 0.5 * PI;
    newPoint.x = cos(thetaPhiR.x) * cos(thetaPhiR.y);
    newPoint.y = sin(thetaPhiR.y);
    newPoint.z = sin(thetaPhiR.x) * cos(thetaPhiR.y);

    // Blend between returning points on surface of sphere vs volume
    return newPoint * lerp(1., sqrt(sqrt(thetaPhiR.z)), scatterVolume);
}

float fit(float val, float inMin, float inMax, float outMin, float outMax) 
{
    return ((outMax - outMin) * (val - inMin) / (inMax - inMin)) + outMin;
}

float2 fit(float2 val, float2 inMin, float2 inMax, float2 outMin, float2 outMax) 
{
    return ((outMax - outMin) * (val - inMin) / (inMax - inMin)) + outMin;
}

float3 bayesianCoordinate(float3 a, float3 b, float3 c, float2 random) {
    float r = random.x;
    float s = random.y;
    if (r + s >= 1.0) {
        r = 1.-r;
        s = 1.-s;
    }
    return a + ((b-a)*r) + ((c-a)*s);
}



float4x4 rotateToVector(float3 direction) 
{
    float3 dir = direction;
    dir += 1e-6;
    float3 axis = normalize(dir);
	axis.z *= -1.;
	
	float xz = length(axis.xz + 1e-6) ;
	float xyz = 1.;
	float x = sqrt(1. - axis.y * axis.y);
	float cosry = axis.x / xz;
	float sinry = axis.z / xz;
	float cosrz = x / xyz;
	float sinrz = axis.y / xyz;

	float4x4 maty = float4x4(cosry,	0,  sinry,   0,
							0,		1,  0,       0,
							-sinry,	0,  cosry,   0,
                            0,      0,  0,       1);

	float4x4 matz = float4x4(cosrz, -sinrz, 0,  0,
							sinrz, 	cosrz,	0,  0,
							0,		0,		1,  0,
                            0,      0,      0,  1 );

	return mul(maty, matz);
}

float4x4 rotationAroundX(float amount) 
{
    return float4x4(1, 0,           0,              0,
                    0, cos(amount), sin(amount),    0,
                    0, -sin(amount), cos(amount),   0,
                    0,           0, 0,              1);
}
float4x4 rotationAroundY(float amount) 
{
    return float4x4(cos(amount), 0, -sin(amount),   0,
                    0,           1, 0,              0,
                    sin(amount), 0, cos(amount),    0,
                    0,           0, 0,              1);
}
float4x4 rotationAroundZ(float amount) 
{
    return float4x4(cos(amount),    sin(amount), 0, 0,
                    -sin(amount),   cos(amount), 0, 0,
                    0,              0,           1, 0,
                    0,              0,           0, 1);
}

float4x4 rotateXYZ(float4x4 rotMatrix, float3 amount) 
{
    if (amount.x != 0.0) {
		rotMatrix = mul(rotMatrix, rotationAroundX(amount.x));
	}
	if (amount.y != 0.0) {
		rotMatrix = mul(rotMatrix, rotationAroundY(amount.y));
	}
	if (amount.z != 0.0) {
		rotMatrix = mul(rotMatrix, rotationAroundZ(amount.z));
	}
    return rotMatrix;
}