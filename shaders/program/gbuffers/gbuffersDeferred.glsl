#extension GL_EXT_gpu_shader4 : enable

#define PCF

in vec4 lmtexcoord;
in vec4 color;
in vec4 normalMat;


uniform sampler2D texture;
uniform sampler2DShadow shadow;
uniform sampler2D gaux1;
uniform float lightSign;
uniform vec3 sunVec;
uniform vec3 upVec;

uniform vec2 texelSize;
uniform float skyIntensityNight;
uniform float skyIntensity;
uniform float sunElevation;
uniform float rainStrength;

#include "/lib/resParams.glsl"
#include "/lib/util.glsl"
#include "/lib/projections.glsl"
#include "/lib/shadow.glsl"
#include "/lib/colorTransforms.glsl"

float interleaved_gradientNoise(float temporal){
	vec2 coord = gl_FragCoord.xy;
	float noise = fract(52.9829189*fract(0.06711056*coord.x + 0.00583715*coord.y)+temporal);
	return noise;
}

#ifdef PCF
const vec2 shadowOffsets[4] = vec2[4](vec2( 0.1250,  0.0000 ),
vec2( -0.1768, -0.1768 ),
vec2( -0.0000,  0.3750 ),
vec2(  0.3536, -0.3536 )
);
#endif


vec2 tapLocation(int sampleNumber, float spinAngle,int nb, float nbRot)
{
	float startJitter = (spinAngle/6.28);
    float alpha = sqrt(sampleNumber + startJitter/nb );
    float angle = alpha * (nbRot * 6.28) + spinAngle*2.;

    float ssR = alpha;
    float sin_v, cos_v;

	sin_v = sin(angle);
	cos_v = cos(angle);

    return vec2(cos_v, sin_v)*ssR;
}
uniform int framemod8;
uniform int framecouter;


//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
/* DRAWBUFFERS:2 */
void main() {

	gl_FragData[0] = texture2D(texture, lmtexcoord.xy)*color;
	vec2 tempOffset=offsets[framemod8];

	if (gl_FragData[0].a>0.1){
		vec3 albedo = toLinear(gl_FragData[0].rgb);

		vec3 normal = normalMat.xyz;
		vec3 fragpos = toScreenSpace(gl_FragCoord.xyz*vec3(texelSize/RENDER_SCALE,1.0)-vec3(vec2(tempOffset)*texelSize*0.5,0.0));

		float NdotL = lightSign*dot(normal,sunVec);
		float NdotU = dot(upVec,normal);
		float diffuseSun = clamp(NdotL,0.0f,1.0f);
		vec3 direct = texelFetch2D(gaux1,ivec2(6,37),0).rgb/PI;


		//compute shadows only if not backface
		if (diffuseSun > 0.001) {
			vec3 p3 = mat3(gbufferModelViewInverse) * fragpos + gbufferModelViewInverse[3].xyz;
			vec3 projectedShadowPosition = mat3(shadowModelView) * p3 + shadowModelView[3].xyz;

			//hack to prevent player shadowing
			#ifdef GBUFFER_HAND_WATER
				projectedShadowPosition += vec3(0.0, 0.0, 1.0);
			#endif

			projectedShadowPosition = diagonal3(shadowProjection) * projectedShadowPosition + shadowProjection[3].xyz;

			//apply distortion
			float distortFactor = calcDistort(projectedShadowPosition.xy);
			projectedShadowPosition.xy *= distortFactor;
			//do shadows only if on shadow map
			if (abs(projectedShadowPosition.x) < 1.0-1.5/shadowMapResolution && abs(projectedShadowPosition.y) < 1.0-1.5/shadowMapResolution){
				const float threshMul = sqrt(2048.0/shadowMapResolution*shadowDistance/128.0);
				float distortThresh = 1.0/(distortFactor*distortFactor);
				float diffthresh = facos(diffuseSun)*distortThresh/800*threshMul;

				projectedShadowPosition = projectedShadowPosition * vec3(0.5,0.5,0.5/6.0) + vec3(0.5,0.5,0.5);

				float noise = interleaved_gradientNoise(tempOffset.x*0.5+0.5);


				vec2 offsetS = vec2(cos( noise*TAU ),sin( noise*TAU ));

				float shading = shadow2D_bicubic(shadow,vec3(projectedShadowPosition + vec3(0.0,0.0,-diffthresh*1.2)));


				direct *= shading;
			}

		}


		direct *= diffuseSun;

		vec3 ambient = texture2D(gaux1,(lmtexcoord.zw*15.+0.5)*texelSize).rgb;

		vec3 diffuseLight = direct + ambient;


		gl_FragData[0].rgb = (diffuseLight*8./3./150.)*albedo/PI;
	}



}
