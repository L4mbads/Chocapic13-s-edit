//Computes volumetric clouds at variable resolution (default 1/4 res)
#define HQ_CLOUDS	//Renders detailled clouds for viewport
#define CLOUDS_QUALITY 0.35 //[0.1 0.125 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.9 1.0]

flat varying vec3 sunColor;
flat varying vec3 moonColor;
flat varying vec3 avgAmbient;
flat varying float tempOffsets;


#if defined VERTEX
	
	uniform sampler2D colortex4;
	
	void main() {
		tempOffsets = HaltonSeq2(frameCounter%10000);
		gl_Position = ftransform();
		gl_Position.xy = (gl_Position.xy*0.5+0.5)*clamp(CLOUDS_QUALITY+0.01,0.0,1.0)*2.0-1.0;
		#ifdef TAA_UPSCALING
			gl_Position.xy = (gl_Position.xy*0.5+0.5)*RENDER_SCALE*2.0-1.0;
		#endif
		sunColor = texelFetch2D(colortex4,ivec2(12,37),0).rgb;
		moonColor = texelFetch2D(colortex4,ivec2(13,37),0).rgb;
		avgAmbient = texelFetch2D(colortex4,ivec2(11,37),0).rgb;
	
	}
	
#elif defined FRAGMENT
	
	uniform sampler2D depthtex0;
	uniform sampler2D colortex4;
	
	uniform vec3 sunVec;
	uniform float rainStrength;
	
	#include "/lib/colorDither.glsl"
	#include "/lib/skyGradient.glsl"
	#include "/lib/projections.glsl"
	#include "/lib/volumetricClouds.glsl"
	
	void main() {
	/* RENDERTARGETS:0 */
		#ifdef VOLUMETRIC_CLOUDS
	
			vec2 halfResTC = vec2(floor(gl_FragCoord.xy)/CLOUDS_QUALITY/RENDER_SCALE+0.5+offsets[framemod8]*CLOUDS_QUALITY*RENDER_SCALE*0.5);
			vec3 fragpos = toScreenSpace(vec3(halfResTC*texelSize,1.0));
			vec4 currentClouds = renderClouds(fragpos,vec3(0.), blueNoise(),sunColor/150.,moonColor/150.,avgAmbient/150.);
			
			gl_FragData[0] = currentClouds;
		
		#else
	
			gl_FragData[0] = vec4(0.0,0.0,0.0,1.0);

		#endif
	
	}
	
#endif

