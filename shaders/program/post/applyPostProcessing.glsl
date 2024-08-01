#extension GL_EXT_gpu_shader4 : enable

#define FinalR 1.0 //[0.0 0.025315 0.051271 0.077884 0.105170 0.133148 0.161834 0.191246 0.221402 0.252322 0.284025 0.316530 0.349858 0.384030 0.419067 0.454991 0.491824 0.529590 0.568312 0.608014 0.648721 0.690458 0.733253 0.777130 0.822118 0.868245 0.915540 0.964032 1.013752 1.064731 1.117000 1.170592 1.225540 1.281880 1.339646 1.398875 1.459603 1.521868 1.585709 1.651167 1.718281 1.787095 1.857651 1.929992 2.004166 2.080216 2.158192 2.238142 2.320116 2.404166 2.490342 2.578701 2.669296 2.762185 2.857425 2.955076 3.055199 3.157857 3.263114 3.371035 3.481689 3.595143 3.711470 3.830741 3.953032 4.078419 4.206979 4.338795 4.473947 4.612521 4.754602 4.900281 5.049647 5.202795 5.359819 5.520819 5.685894 5.855148 6.028687 6.206619 6.389056 6.576110 6.767901 6.964546 7.166169 7.372897 7.584858 7.802185 8.025013 8.253482 8.487735 8.727919 8.974182 9.226680 9.485569 9.751013 10.02317 10.30222 10.58834 10.88170 11.18249 ]
#define FinalG 1.0 //[0.0 0.025315 0.051271 0.077884 0.105170 0.133148 0.161834 0.191246 0.221402 0.252322 0.284025 0.316530 0.349858 0.384030 0.419067 0.454991 0.491824 0.529590 0.568312 0.608014 0.648721 0.690458 0.733253 0.777130 0.822118 0.868245 0.915540 0.964032 1.013752 1.064731 1.117000 1.170592 1.225540 1.281880 1.339646 1.398875 1.459603 1.521868 1.585709 1.651167 1.718281 1.787095 1.857651 1.929992 2.004166 2.080216 2.158192 2.238142 2.320116 2.404166 2.490342 2.578701 2.669296 2.762185 2.857425 2.955076 3.055199 3.157857 3.263114 3.371035 3.481689 3.595143 3.711470 3.830741 3.953032 4.078419 4.206979 4.338795 4.473947 4.612521 4.754602 4.900281 5.049647 5.202795 5.359819 5.520819 5.685894 5.855148 6.028687 6.206619 6.389056 6.576110 6.767901 6.964546 7.166169 7.372897 7.584858 7.802185 8.025013 8.253482 8.487735 8.727919 8.974182 9.226680 9.485569 9.751013 10.02317 10.30222 10.58834 10.88170 11.18249 ]
#define FinalB 1.0 //[0.0 0.025315 0.051271 0.077884 0.105170 0.133148 0.161834 0.191246 0.221402 0.252322 0.284025 0.316530 0.349858 0.384030 0.419067 0.454991 0.491824 0.529590 0.568312 0.608014 0.648721 0.690458 0.733253 0.777130 0.822118 0.868245 0.915540 0.964032 1.013752 1.064731 1.117000 1.170592 1.225540 1.281880 1.339646 1.398875 1.459603 1.521868 1.585709 1.651167 1.718281 1.787095 1.857651 1.929992 2.004166 2.080216 2.158192 2.238142 2.320116 2.404166 2.490342 2.578701 2.669296 2.762185 2.857425 2.955076 3.055199 3.157857 3.263114 3.371035 3.481689 3.595143 3.711470 3.830741 3.953032 4.078419 4.206979 4.338795 4.473947 4.612521 4.754602 4.900281 5.049647 5.202795 5.359819 5.520819 5.685894 5.855148 6.028687 6.206619 6.389056 6.576110 6.767901 6.964546 7.166169 7.372897 7.584858 7.802185 8.025013 8.253482 8.487735 8.727919 8.974182 9.226680 9.485569 9.751013 10.02317 10.30222 10.58834 10.88170 11.18249 ]

varying vec2 texcoord;
flat varying vec4 exposure;
flat varying vec2 rodExposureDepth;

#if defined VERTEX
uniform sampler2D colortex4;

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {

	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	exposure=vec4(texelFetch2D(colortex4,ivec2(10,37),0).r*vec3(FinalR,FinalG,FinalB),texelFetch2D(colortex4,ivec2(10,37),0).r);
	rodExposureDepth = texelFetch2D(colortex4,ivec2(14,37),0).rg;
	rodExposureDepth.y = sqrt(rodExposureDepth.y/65000.0);
}

#elif defined FRAGMENT

#extension GL_EXT_gpu_shader4 : enable
#define Fake_purkinje
#define BLOOMY_FOG 1.0 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0 3.0 4.0 6.0 10.0 15.0 20.0]
#define BLOOM_STRENGTH  1.0 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0 3.0 4.0]
#define TONEMAP ToneMap_Hejl2015 // Tonemapping operator [Tonemap_Uchimura HableTonemap reinhard Tonemap_Lottes ACESFilm]
//#define USE_ACES_COLORSPACE_APPROXIMATION	// Do the tonemap in another colorspace

#define Purkinje_strength 1.0	// Simulates how the eye is unable to see colors at low light intensities. 0 = No purkinje effect at low exposures [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]
#define Purkinje_R 0.4 // [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]
#define Purkinje_G 0.7 // [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]
#define Purkinje_B 1.0 // [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]
#define Purkinje_Multiplier 5.0 // How much the purkinje effect increases brightness [0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2.0 2.05 2.1 2.15 2.2 2.25 2.3 2.35 2.4 2.45 2.5 2.55 2.6 2.65 2.7 2.75 2.8 2.85 2.9 2.95 3.0 3.05 3.1 3.15 3.2 3.25 3.3 3.35 3.4 3.45 3.5 3.55 3.6 3.65 3.7 3.75 3.8 3.85 3.9 3.95 4.0 4.05 4.1 4.15 4.2 4.25 4.3 4.35 4.4 4.45 4.5 4.55 4.6 4.65 4.7 4.75 4.8 4.85 4.9 4.95 5.0 5.05 5.1 5.15 5.2 5.25 5.3 5.35 5.4 5.45 5.5 5.55 5.6 5.65 5.7 5.75 5.8 5.85 5.9 5.95 6.0 6.05 6.1 6.15 6.2 6.25 6.3 6.35 6.4 6.45 6.5 6.55 6.6 6.65 6.7 6.75 6.8 6.85 6.9 6.95 7.0 7.05 7.1 7.15 7.2 7.25 7.3 7.35 7.4 7.45 7.5 7.55 7.6 7.65 7.7 7.75 7.8 7.85 7.9 7.95 8.0 8.05 8.1 8.15 8.2 8.25 8.3 8.35 8.4 8.45 8.5 8.55 8.6 8.65 8.7 8.75 8.8 8.85 8.9 8.95 9.0 9.05 9.1 9.15 9.2 9.25 9.3 9.35 9.4 9.45 9.5 9.55 9.6 9.65 9.7 9.75 9.8 9.85 9.9 9.95 ]


#include "/lib/resParams.glsl"
#ifdef DOF
#include "/lib/DOF.glsl"
#endif

uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex3;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D depthtex0;
uniform sampler2D noisetex;
uniform vec2 texelSize;

uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter;
uniform int frameCounter;
uniform int isEyeInWater;
uniform float rainStrength;
uniform float near;
uniform float aspectRatio;
uniform float far;
#include "/lib/colorTransforms.glsl"
#include "/lib/colorDither.glsl"
float cdist(vec2 coord) {
	return max(abs(coord.s-0.5),abs(coord.t-0.5))*2.0;
}
float blueNoise(){
  return fract(texelFetch2D(noisetex, ivec2(gl_FragCoord.xy)%512, 0).a + 1.0/1.6180339887 * frameCounter);
}
float ld(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));		// (-depth * (far - near)) = (2.0 * near)/ld - far - near
}

vec3 agxDefaultContrastApprox(vec3 x) {
  vec3 x2 = x * x;
  vec3 x4 = x2 * x2;
  
  return + 15.5     * x4 * x2
         - 40.14    * x4 * x
         + 31.96    * x4
         - 6.868    * x2 * x
         + 0.4298   * x2
         + 0.1191   * x
         - 0.00232;
}

vec3 agx(vec3 val) {
  const mat3 agx_mat = mat3(
    0.842479062253094, 0.0423282422610123, 0.0423756549057051,
    0.0784335999999992,  0.878468636469772,  0.0784336,
    0.0792237451477643, 0.0791661274605434, 0.879142973793104);
    
  const float min_ev = -12.47393f;
  const float max_ev = 4.026069f;

  // Input transform
  val = agx_mat * val;
  
  // Log2 space encoding
  val = clamp(log2(val), min_ev, max_ev);
  val = (val - min_ev) / (max_ev - min_ev);
  
  // Apply sigmoid function approximation
  val = agxDefaultContrastApprox(val);

  return val;
}

vec3 agxEotf(vec3 val) {
  const mat3 agx_mat_inv = mat3(
    1.19687900512017, -0.0528968517574562, -0.0529716355144438,
    -0.0980208811401368, 1.15190312990417, -0.0980434501171241,
    -0.0990297440797205, -0.0989611768448433, 1.15107367264116);
    
  // Undo input transform
  val = agx_mat_inv * val;
  
  // sRGB IEC 61966-2-1 2.2 Exponent Reference EOTF Display
  //val = pow(val, vec3(2.2));

  return val;
}

vec3 agxLook(vec3 val) {
  const vec3 lw = vec3(0.2126, 0.7152, 0.0722);
  float luma = dot(val, lw);
  
  // Default
  vec3 offset = vec3(0.0);
  vec3 slope = vec3(1.0);
  vec3 power = vec3(1.0);
  float sat = 1.0;

  #define AGX_LOOK 3
 
#if AGX_LOOK == 1
  // Golden
  slope = vec3(0.6, 0.9, 0.5);
  power = vec3(0.8);
  sat = 0.8;
#elif AGX_LOOK == 2
  // Punchy
  slope = vec3(1.0);
  power = vec3(1.35, 1.35, 1.35);
  sat = 1.4;
#elif AGX_LOOK == 3
  // Punchy
  slope = vec3(0.99, 1.0, 0.97);
  power = vec3(1.17, 1.15, 1.17);
  sat = 1.3;
#endif
  
  // ASC CDL
  val = pow(val * slope + offset, power);
  return luma + sat * (val - luma);
}
uniform int hideGUI;
void main() {
  /* DRAWBUFFERS:7 */
  float vignette = (1.5-dot(texcoord-0.5,texcoord-0.5)*2.);
	vec3 col = texture2D(colortex5,texcoord).rgb;
	#ifdef DOF
		/*--------------------------------*/
		float z = ld(texture2D(depthtex0, texcoord.st*RENDER_SCALE).r)*far;
		#ifdef AUTOFOCUS
			float focus = rodExposureDepth.y*far;
		#else
			float focus = MANUAL_FOCUS;
		#endif
		float pcoc = min(abs(aperture * (focal/100.0 * (z - focus)) / (z * (focus - focal/100.0))),texelSize.x*15.0);
		#ifdef FAR_BLUR_ONLY
			pcoc *= float(z > focus);
		#endif
		float noise = blueNoise()*6.28318530718;
		mat2 noiseM = mat2( cos( noise ), -sin( noise ),
	                       sin( noise ), cos( noise )
	                         );
		vec3 bcolor = vec3(0.);
		float nb = 0.0;
		vec2 bcoord = vec2(0.0);
		/*--------------------------------*/
		#ifndef HQ_DOF
		bcolor = col;
		#ifdef HEXAGONAL_BOKEH
			for ( int i = 0; i < 60; i++) {
				bcolor += texture2D(colortex5, texcoord.xy + hex_offsets[i]*pcoc*vec2(1.0,aspectRatio)).rgb;
			}
			col = bcolor/61.0;
		#else
			for ( int i = 0; i < 60; i++) {
				bcolor += texture2D(colortex5, texcoord.xy + offsets[i]*pcoc*vec2(1.0,aspectRatio)).rgb;
			}
		/*--------------------------------*/
	col = bcolor/61.0;
		#endif
		#endif
		#ifdef HQ_DOF
			for ( int i = 0; i < 209; i++) {
				bcolor += texture2D(colortex5, texcoord.xy + noiseM*shadow_offsets[i]*pcoc*vec2(1.0,aspectRatio)).rgb;
			}
			col = bcolor/209.0;
		#endif
#endif
	vec2 clampedRes = max(vec2(viewWidth,viewHeight),vec2(1920.0,1080.));

	vec3 bloom = texture2D(colortex3,texcoord/clampedRes*vec2(1920.,1080.)*0.5*BLOOM_QUALITY).rgb*0.1;

	float lightScat = clamp(BLOOM_STRENGTH * exposure.a ,0.0,1.0)*vignette;

  	float VL_abs = texture2D(colortex7,texcoord*RENDER_SCALE).r;
	float purkinje = rodExposureDepth.x/(1.0+rodExposureDepth.x)*Purkinje_strength;
  	VL_abs = clamp((1.0-VL_abs)*BLOOMY_FOG*0.75*(1.0-purkinje*0.3)*(1.0+rainStrength),0.0,1.0)*clamp(1.0-pow(cdist(texcoord.xy),15.0),0.0,1.0);
	//col = (mix(col,bloom,VL_abs)+bloom*lightScat)*exposure.rgb;
	//col = mix(col, bloom, luma(bloom/(bloom+1)))*exposure.rgb;
	col = (col+bloom*lightScat);

	//Purkinje Effect
  	float lum = dot(col,vec3(0.15,0.3,0.55));
	float lum2 = dot(col,vec3(0.85,0.7,0.45))/2;
	float rodLum = lum2*400.;
	float rodCurve = mix(1.0, rodLum/(2.5+rodLum), purkinje);
	col = mix(clamp(lum,0.0,0.05)*Purkinje_Multiplier*vec3(Purkinje_R, Purkinje_G, Purkinje_B)+1.5e-3, col, rodCurve);
//	col =vec3(rodCurve);
//	if (col.r > 0.85*3.0) col = vec3(100,0.0,0.0);

	col  *= exposure.rgb;

	#ifndef USE_ACES_COLORSPACE_APPROXIMATION
  	col = LinearTosRGB(TONEMAP(col));
  	//col = agx(col);col = agxLook(col);col = agxEotf(col);

	#else
		col = col * ACESInputMat;
		col = TONEMAP(col);
		col = LinearTosRGB(clamp(col * ACESOutputMat, 0.0, 1.0));
	#endif
	//col = ACESFitted(texture2D(colortex4,texcoord/3.).rgb/500.);
	gl_FragData[0].rgb = clamp(int8Dither(col,texcoord),0.0,1.0);
	//if (nightMode < 0.99 && texcoord.x < 0.5)	gl_FragData[0].rgb =vec3(0.0,1.0,0.0);

}


#endif
