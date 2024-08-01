#include "/lib/resParams.glsl"
uniform float viewWidth;
uniform float viewHeight;
uniform vec2 texelSize;

varying vec2 resScale;

#if defined VERTEX

	void main() {
		//Improves performances and makes sure bloom radius stays the same at high resolution (>1080p)
		vec2 clampedRes = max(vec2(viewWidth,viewHeight),vec2(1920.0,1080.));
		resScale = max(vec2(viewWidth,viewHeight),vec2(1920.0,1080.))/vec2(1920.,1080.);
		
		gl_Position = ftransform();

		//*0.51 to avoid errors when sampling outside since clearing is disabled
		#if DOWNSAMPLE_PASS == 2
			gl_Position.xy = (gl_Position.xy*0.5+0.5)*0.26*BLOOM_QUALITY/clampedRes*vec2(1920.0,1080.)*2.0-1.0;
		#else
			gl_Position.xy = (gl_Position.xy*0.5+0.5)*0.51*BLOOM_QUALITY/clampedRes*vec2(1920.0,1080.)*2.0-1.0;
		#endif
	}
	
#elif defined FRAGMENT
	
	
	#if DOWNSAMPLE_PASS == 1
	
		/* DRAWBUFFERS:3 */
		uniform sampler2D colortex5;
		#define SAMPLER colortex5
	
	#else
	
		/* DRAWBUFFERS:6 */
		uniform sampler2D colortex3;
		#define SAMPLER colortex3
	
	#endif
	
	void main() {
	
		vec2 quarterResTC = gl_FragCoord.xy*texelSize*2.;
	
		#if DOWNSAMPLE_PASS == 1

			quarterResTC *= resScale/BLOOM_QUALITY;

		#endif
	
		//0.5
		gl_FragData[0]  = texture2D(SAMPLER, quarterResTC-1.0*vec2(texelSize.x,texelSize.y))/4.*0.5;
		gl_FragData[0] += texture2D(SAMPLER, quarterResTC+1.0*vec2(texelSize.x,texelSize.y))/4.*0.5;
		gl_FragData[0] += texture2D(SAMPLER, quarterResTC+vec2(-1.0*texelSize.x,1.0*texelSize.y))/4.*0.5;
		gl_FragData[0] += texture2D(SAMPLER, quarterResTC+vec2(1.0*texelSize.x,-1.0*texelSize.y))/4.*0.5;
	 
		//0.25
		gl_FragData[0] += texture2D(SAMPLER, quarterResTC-2.0*vec2(texelSize.x,0.0))/2.*0.125;
		gl_FragData[0] += texture2D(SAMPLER, quarterResTC+2.0*vec2(0.0,texelSize.y))/2.*0.125;
		gl_FragData[0] += texture2D(SAMPLER, quarterResTC+2.0*vec2(0,-texelSize.y))/2*0.125;
		gl_FragData[0] += texture2D(SAMPLER, quarterResTC+2.0*vec2(-texelSize.x,0.0))/2*0.125;
	 
		//0.125
		gl_FragData[0] += texture2D(SAMPLER, quarterResTC-2.0*vec2(texelSize.x,texelSize.y))/4.*0.125;
		gl_FragData[0] += texture2D(SAMPLER, quarterResTC+2.0*vec2(texelSize.x,texelSize.y))/4.*0.125;
		gl_FragData[0] += texture2D(SAMPLER, quarterResTC+vec2(-2.0*texelSize.x,2.0*texelSize.y))/4.*0.125;
		gl_FragData[0] += texture2D(SAMPLER, quarterResTC+vec2(2.0*texelSize.x,-2.0*texelSize.y))/4.*0.125;
	
		//0.125
		gl_FragData[0] += texture2D(SAMPLER, quarterResTC)*0.125;
	
		gl_FragData[0].rgb = clamp(gl_FragData[0].rgb,0.0,65000.);
	
		#if DOWNSAMPLE_PASS == 1

			if (quarterResTC.x > 1.0 - 3.5*texelSize.x ||
				quarterResTC.y > 1.0 - 3.5*texelSize.y ||
				quarterResTC.x <       3.5*texelSize.x ||
				quarterResTC.y <       3.5*texelSize.y)

					gl_FragData[0].rgb = vec3(0.0);
		
		#endif
	}
	
#endif