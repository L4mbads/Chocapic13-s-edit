#define DRAW_SUN //if not using custom sky
#define SKY_BRIGHTNESS_DAY 1.0 //[0.0 0.5 0.75 1. 1.2 1.4 1.6 1.8 2.0]
#define SKY_BRIGHTNESS_NIGHT 1.0 //[0.0 0.5 0.75 1. 1.2 1.4 1.6 1.8 2.0]
#define ffstep(x,y) clamp((y - x) * 1e35,0.0,1.0)
vec3 drawSun(float cosY, float sunInt,vec3 nsunlight,vec3 inColor){
	return inColor+nsunlight/0.0008821203*pow(smoothstep(cos(0.0093084168595*3.2),cos(0.0093084168595*1.8),cosY),3.)*0.62;
}
const float pi = 3.141592653589793238462643383279502884197169;
vec2 sphereToCarte(vec3 dir) {
    float lonlat = atan(-dir.x, -dir.z);
    return vec2(lonlat * (0.5/pi) +0.5,0.5*dir.y+0.5);
}
vec3 skyFromTex(vec3 pos,sampler2D sampler){
	vec2 p = sphereToCarte(pos);
	return texture2D(sampler,p*texelSize*256.+vec2(18.5,1.5)*texelSize).rgb;
}
vec4 skyCloudsFromTex(vec3 pos,sampler2D sampler){
	vec2 p = sphereToCarte(pos);
	return texture2D(sampler,p*texelSize*256.+vec2(18.5+257.,1.5)*texelSize);
}
