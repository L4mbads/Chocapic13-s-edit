//#define BICUBIC_UPSCALING //Provides a better interpolation when using a render quality different of 1.0, slower
#define CONTRAST_ADAPTATIVE_SHARPENING
#define SHARPENING 0.5 //[0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0 ]
#define SATURATION 0.00 // Negative values desaturates colors, Positive values saturates color, 0 is no change [-1.0 -0.98 -0.96 -0.94 -0.92 -0.9 -0.88 -0.86 -0.84 -0.82 -0.8 -0.78 -0.76 -0.74 -0.72 -0.7 -0.68 -0.66 -0.64 -0.62 -0.6 -0.58 -0.56 -0.54 -0.52 -0.5 -0.48 -0.46 -0.44 -0.42 -0.4 -0.38 -0.36 -0.34 -0.32 -0.3 -0.28 -0.26 -0.24 -0.22 -0.2 -0.18 -0.16 -0.14 -0.12 -0.1 -0.08 -0.06 -0.04 -0.02 0.0 0.02 0.04 0.06 0.08 0.1 0.12 0.14 0.16 0.18 0.2 0.22 0.24 0.26 0.28 0.3 0.32 0.34 0.36 0.38 0.4 0.42 0.44 0.46 0.48 0.5 0.52 0.54 0.56 0.58 0.6 0.62 0.64 0.66 0.68 0.7 0.72 0.74 0.76 0.78 0.8 0.82 0.84 0.86 0.88 0.9 0.92 0.94 0.96 0.98 1.0 ]
#define CROSSTALK 0.0 // Desaturates bright colors and preserves saturation in darker areas (inverted if negative). Helps avoiding almsost fluorescent colors [-1.0 -0.98 -0.96 -0.94 -0.92 -0.9 -0.88 -0.86 -0.84 -0.82 -0.8 -0.78 -0.76 -0.74 -0.72 -0.7 -0.68 -0.66 -0.64 -0.62 -0.6 -0.58 -0.56 -0.54 -0.52 -0.5 -0.48 -0.46 -0.44 -0.42 -0.4 -0.38 -0.36 -0.34 -0.32 -0.3 -0.28 -0.26 -0.24 -0.22 -0.2 -0.18 -0.16 -0.14 -0.12 -0.1 -0.08 -0.06 -0.04 -0.02 0.0 0.02 0.04 0.06 0.08 0.1 0.12 0.14 0.16 0.18 0.2 0.22 0.24 0.26 0.28 0.3 0.32 0.34 0.36 0.38 0.4 0.42 0.44 0.46 0.48 0.5 0.52 0.54 0.56 0.58 0.6 0.62 0.64 0.66 0.68 0.7 0.72 0.74 0.76 0.78 0.8 0.82 0.84 0.86 0.88 0.9 0.92 0.94 0.96 0.98 1.0 ]

varying vec2 texcoord;

#if defined VERTEX

	void main() {
	
		gl_Position = ftransform();
		texcoord = gl_MultiTexCoord0.xy;
	
	}
	
#elif defined FRAGMENT

	uniform sampler2D colortex7;
	uniform sampler2D colortex8;
	uniform sampler2D colortex4;
	
	uniform int isEyeInWater;
	uniform int hideGUI;
	
	#include "/lib/colorTransforms.glsl"
	#include "/lib/colorDither.glsl"
	#include "/lib/texFiltering.glsl"
	#include "/buffers.glsl"

	void CAS(inout vec3 col) {
		//Weights : 1 in the center, 0.5 middle, 0.25 corners
	    vec3 albedoCurrent1 = texture2D(colortex7, texcoord + vec2( texelSize.x, texelSize.y)/MC_RENDER_QUALITY*0.5).rgb;
	    vec3 albedoCurrent2 = texture2D(colortex7, texcoord + vec2( texelSize.x,-texelSize.y)/MC_RENDER_QUALITY*0.5).rgb;
	    vec3 albedoCurrent3 = texture2D(colortex7, texcoord + vec2(-texelSize.x,-texelSize.y)/MC_RENDER_QUALITY*0.5).rgb;
	    vec3 albedoCurrent4 = texture2D(colortex7, texcoord + vec2(-texelSize.x, texelSize.y)/MC_RENDER_QUALITY*0.5).rgb;
	
	    vec3 m1 = -0.5/3.5*col + albedoCurrent1/3.5 + albedoCurrent2/3.5 + albedoCurrent3/3.5 + albedoCurrent4/3.5;
	    
	    vec3 std = abs(col - m1)
	    		 + abs(albedoCurrent1 - m1)
	    		 + abs(albedoCurrent2 - m1)
	    		 + abs(albedoCurrent3 - m1)
	    		 + abs(albedoCurrent3 - m1)
	    		 + abs(albedoCurrent4 - m1);

	    float contrast = 1.0 - luma(std)/5.0;

	    col = col * (1.0+(SHARPENING+UPSCALING_SHARPNENING) * contrast)
	        - (SHARPENING+UPSCALING_SHARPNENING)/(1.0-0.5/3.5)*contrast*(m1 - 0.5/3.5*col);
	}
	
	void main() {

		#ifdef BICUBIC_UPSCALING

			vec3 col = SampleTextureCatmullRom(colortex7,texcoord, 1.0/texelSize).rgb;

		#else

			vec3 col = texture2D(colortex7,texcoord).rgb;
	    
	  	#endif
	
	  	#ifdef CONTRAST_ADAPTATIVE_SHARPENING

	   		CAS(col);

	  	#endif
	
	  	float lum = luma(col);
	  	vec3 diff = col-lum;

	  	col = col + diff*(-lum*CROSSTALK + SATURATION);
	  	//col = -vec3(-lum*CROSSFADING + SATURATION);

		gl_FragColor.rgb = clamp(int8Dither(col,texcoord),0.0,1.0);
	}
	
#endif