#include "/lib/resParams.glsl"

uniform float viewWidth;
uniform float viewHeight;
uniform vec2 texelSize;

varying vec2 resScale;

#if defined VERTEX
	
	void main() {
		//Improves performances and makes sure bloom radius stays the same at high resolution (>1080p)
		vec2 clampedRes = max(vec2(viewWidth,viewHeight),vec2(1920.0,1080.));
	
		gl_Position = ftransform();
	
		//*0.51 to avoid errors when sampling outside since clearing is disabled
		gl_Position.xy = (gl_Position.xy*0.5+0.5)*0.51*BLOOM_QUALITY/clampedRes*vec2(1920.0,1080.)*2.0-1.0;
		
		resScale = vec2(1920.,1080.)/(max(vec2(viewWidth,viewHeight),vec2(1920.0,1080.))/BLOOM_QUALITY);
	}
	
#elif defined FRAGMENT
	
	//Merge and upsample the blurs into a 1/4 res bloom buffer
	
	uniform sampler2D colortex3;
	uniform sampler2D colortex6;
	
	#include "/lib/texFiltering.glsl"

	/* DRAWBUFFERS:3 */
	void main() {

	vec2 texcoord = ((gl_FragCoord.xy)*2.+0.5)*texelSize;
	
	vec3 bloom = texture2D_bicubic(colortex3,texcoord/  2.0).rgb	//1/4 res
			   + texture2D_bicubic(colortex6,texcoord/  4.0).rgb    //1/8 res
			   + texture2D_bicubic(colortex6,texcoord/  8.0 + vec2(0.25     * resScale.x + 	2.5*texelSize.x, .0)).rgb  //1/16 res
			   + texture2D_bicubic(colortex6,texcoord/ 16.0 + vec2(0.375    * resScale.x + 	4.5*texelSize.x, .0)).rgb  //1/32 res
			   + texture2D_bicubic(colortex6,texcoord/ 32.0 + vec2(0.4375   * resScale.x + 	6.5*texelSize.x, .0)).rgb  //1/64 res
			   + texture2D_bicubic(colortex6,texcoord/ 64.0 + vec2(0.46875  * resScale.x +  8.5*texelSize.x, .0)).rgb  //1/128 res
			   + texture2D_bicubic(colortex6,texcoord/128.0 + vec2(0.484375 * resScale.x + 10.5*texelSize.x, .0)).rgb; //1/256 res
	
	gl_FragData[0].rgb = bloom;
	
	gl_FragData[0].rgb = clamp(gl_FragData[0].rgb,0.0,65000.);
	}
	
#endif