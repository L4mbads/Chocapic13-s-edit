uniform sampler2D noisetex;
uniform sampler2D colortex6;

float bayer2(vec2 a){
	a = floor(a);
    return fract(dot(a,vec2(0.5,a.y*0.75)));
}

#define bayer4(a)   (bayer2( .5*(a))*.25+bayer2(a))
#define bayer8(a)   (bayer4( .5*(a))*.25+bayer2(a))
#define bayer16(a)  (bayer8( .5*(a))*.25+bayer2(a))
#define bayer32(a)  (bayer16(.5*(a))*.25+bayer2(a))
#define bayer64(a)  (bayer32(.5*(a))*.25+bayer2(a))
#define bayer128(a) fract(bayer64(.5*(a))*.25+bayer2(a))

//using white noise for color dithering : gives a somewhat more "filmic" look when noise is visible
float nrand( vec2 n ){
	return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
}

float triangWhiteNoise( vec2 n ){
	float t = fract( frameTimeCounter );
	float rnd = nrand( n + 0.07*t );

    float center = rnd*2.0-1.0;
    rnd = center*inversesqrt(abs(center));
    rnd = max(-1.0,rnd); 
    return rnd-sign(center);
}

float triangularize(float dither)
{
    float center = dither*2.0-1.0;
    dither = center*inversesqrt(abs(center));
    return clamp(dither-fsign(center),0.0,1.0);
}

vec4 blueNoise(vec2 coord){
  return texelFetch2D(colortex6, ivec2(coord)%512, 0);
}

vec3 fp10Dither(vec3 color,vec2 tc01){
	float dither = triangWhiteNoise(tc01);
	const vec3 mantissaBits = vec3(6.,6.,5.);
	vec3 exponent = floor(log2(color));
	return color + dither*exp2(-mantissaBits)*exp2(exponent);
}

vec3 fp16Dither(vec3 color,vec2 tc01){
	float dither = triangWhiteNoise(tc01);
	const vec3 mantissaBits = vec3(10.);
	vec3 exponent = floor(log2(color));
	return color + dither*exp2(-mantissaBits)*exp2(exponent);
}

vec3 int8Dither(vec3 color,vec2 tc01){
	float dither = triangWhiteNoise(tc01);
	return color + dither*exp2(-8.0);
}

vec3 int10Dither(vec3 color,vec2 tc01){
	float dither = triangWhiteNoise(tc01);
	return color + dither*exp2(-10.0);
}

vec3 int16Dither(vec3 color,vec2 tc01){
	float dither = triangWhiteNoise(tc01);
	return color + dither*exp2(-16.0);
}


vec2 R2_samples(int n){
	vec2 alpha = vec2(0.75487765, 0.56984026);
	return fract(alpha * n);
}

#ifndef VERTEX

	float R2_dither(){
		vec2 alpha = vec2(0.75487765, 0.56984026);
		return fract(alpha.x * gl_FragCoord.x + alpha.y * gl_FragCoord.y + 1.0/1.6180339887 * frameCounter);
	}
	
	float interleaved_gradientNoise(){
		return fract(52.9829189*fract(0.06711056*gl_FragCoord.x + 0.00583715*gl_FragCoord.y)+frameTimeCounter*51.9521);
	}
	
	float interleaved_gradientNoise(float temporal){
		vec2 coord = gl_FragCoord.xy;
		float noise = fract(52.9829189*fract(0.06711056*coord.x + 0.00583715*coord.y)+temporal);
		return noise;
	}
	
	float blueNoise(){
	  return fract(texelFetch2D(noisetex, ivec2(gl_FragCoord.xy)%512, 0).a + 1.0/1.6180339887 * frameCounter);
	}
	
#endif