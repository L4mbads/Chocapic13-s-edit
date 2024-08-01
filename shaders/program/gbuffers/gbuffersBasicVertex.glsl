#extension GL_EXT_gpu_shader4 : enable

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec4 lmtexcoord;
varying vec4 color;
varying vec4 normalMat;

#ifdef MC_NORMAL_MAP
	out vec4 tangent;
	attribute vec4 at_tangent;
#endif

uniform vec2 texelSize;
uniform int framemod8;

#include "/lib/resParams.glsl"


//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	gl_Position = ftransform();
	lmtexcoord = vec4((gl_TextureMatrix[0] * gl_MultiTexCoord0).xy, (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy);
	color = gl_Color;

	#ifdef MC_NORMAL_MAP
		tangent = vec4(normalize(gl_NormalMatrix * at_tangent.rgb), at_tangent.w);
	#endif

	#ifndef GBUFFER_BEACONBEAM
		#ifdef SEPARATE_AO
			lmtexcoord.z *= sqrt(color.a);
			lmtexcoord.w *= color.a;
		#else
			color.rgb *= color.a;
		#endif
	#endif
	
	normalMat = vec4(normalize(gl_NormalMatrix * gl_Normal), 1.0);

	#ifdef TAA_UPSCALING
		gl_Position.xy = gl_Position.xy * RENDER_SCALE + RENDER_SCALE * gl_Position.w - gl_Position.w;
	#endif

	#ifdef TAA
		gl_Position.xy += offsets[framemod8] * gl_Position.w*texelSize;
	#endif
}