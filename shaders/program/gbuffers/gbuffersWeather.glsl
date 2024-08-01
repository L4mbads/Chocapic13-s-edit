#ifdef VERTEX


#include "/lib/resParams.glsl"

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

out vec4 lmtexcoord;
out vec4 color;

uniform vec2 texelSize;
uniform int framemod8;
uniform vec3 cameraPosition;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform float frameTimeCounter;

const float PI48 = 150.796447372;
float pi2wt = PI48*frameTimeCounter*10.;

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define  projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec4 toClipSpace3(vec3 viewSpacePosition) {
    return vec4(projMAD(gl_ProjectionMatrix, viewSpacePosition),-viewSpacePosition.z);
}
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {

	lmtexcoord.xy = (gl_MultiTexCoord0).xy;

	vec2 lmcoord = gl_MultiTexCoord1.xy/255.;
	lmtexcoord.zw = lmcoord*lmcoord;


	vec3 position = mat3(gl_ModelViewMatrix) * vec3(gl_Vertex) + gl_ModelViewMatrix[3].xyz;
	vec3 worldpos = mat3(gbufferModelViewInverse) * position + gbufferModelViewInverse[3].xyz + cameraPosition;
	bool istopv = worldpos.y > cameraPosition.y+5.0;
	float ft = frameTimeCounter*1.3;
	if (!istopv) position.xz += vec2(3.0,1.0)+sin(ft)*sin(ft)*sin(ft)*vec2(2.1,0.6);
	position.xz -= (vec2(3.0,1.0)+sin(ft)*sin(ft)*sin(ft)*vec2(2.1,0.6))*0.5;
	gl_Position = toClipSpace3(position);

	color = gl_Color;
	#ifdef TAA_UPSCALING
		gl_Position.xy = gl_Position.xy * RENDER_SCALE + RENDER_SCALE * gl_Position.w - gl_Position.w;
	#endif
	#ifdef TAA
	gl_Position.xy += offsets[framemod8] * gl_Position.w*texelSize;
	#endif
}

#endif

#ifdef FRAGMENT


in vec4 lmtexcoord;
in vec4 color;

uniform sampler2D texture;
uniform sampler2D gaux1;
uniform vec4 lightCol;
uniform vec3 sunVec;

uniform vec2 texelSize;
uniform float skyIntensityNight;
uniform float skyIntensity;
uniform float rainStrength;

uniform mat4 gbufferProjectionInverse;

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define  projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec3 toLinear(vec3 sRGB){
	return sRGB * (sRGB * (sRGB * 0.305306011 + 0.682171111) + 0.012522878);
}


vec3 toScreenSpaceVector(vec3 p) {
	vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
    vec3 p3 = p * 2. - 1.;
    vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return normalize(fragposition.xyz);
}
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
/* DRAWBUFFERS:2 */
	gl_FragData[0] = texture2D(texture, lmtexcoord.xy)*color;
		gl_FragData[0].a = clamp(gl_FragData[0].a -0.1,0.0,1.0)*0.5;
		vec3 albedo = toLinear(gl_FragData[0].rgb*color.rgb);
		vec3 ambient = texture2D(gaux1,(lmtexcoord.zw*15.+0.5)*texelSize).rgb;

		gl_FragData[0].rgb = dot(albedo,vec3(1.0))*ambient*10./3.0/150.;



}


#endif