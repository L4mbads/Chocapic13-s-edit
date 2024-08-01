#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_shader_texture_lod : enable

#define Texture_MipMap_Bias -1.00 // Uses a another mip level for textures. When reduced will increase texture detail but may induce a lot of shimmering. [-5.00 -4.75 -4.50 -4.25 -4.00 -3.75 -3.50 -3.25 -3.00 -2.75 -2.50 -2.25 -2.00 -1.75 -1.50 -1.25 -1.00 -0.75 -0.50 -0.25 0.00 0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00 2.25 2.50 2.75 3.00 3.25 3.50 3.75 4.00 4.25 4.50 4.75 5.00]

const float mincoord = 1.0/4096.0;
const float maxcoord = 1.0-mincoord;

uniform vec2 texelSize;

#include "/lib/resParams.glsl"
varying vec4 lmtexcoord;
varying vec4 color;
varying vec4 normalMat;
#ifdef MC_NORMAL_MAP
varying vec4 tangent;
uniform float wetness;
uniform sampler2D normals;
#endif
uniform sampler2D specular;

uniform sampler2D texture;
uniform float frameTimeCounter;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;
//2 uniform below for espens encoding
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
float interleaved_gradientNoise(){
	return fract(52.9829189*fract(0.06711056*gl_FragCoord.x + 0.00583715*gl_FragCoord.y)+frameTimeCounter*51.9521);
}
mat3 inverse(mat3 m) {
  float a00 = m[0][0], a01 = m[0][1], a02 = m[0][2];
  float a10 = m[1][0], a11 = m[1][1], a12 = m[1][2];
  float a20 = m[2][0], a21 = m[2][1], a22 = m[2][2];

  float b01 = a22 * a11 - a12 * a21;
  float b11 = -a22 * a10 + a12 * a20;
  float b21 = a21 * a10 - a11 * a20;

  float det = a00 * b01 + a01 * b11 + a02 * b21;

  return mat3(b01, (-a22 * a01 + a02 * a21), (a12 * a01 - a02 * a11),
              b11, (a22 * a00 - a02 * a20), (-a12 * a00 + a02 * a10),
              b21, (-a21 * a00 + a01 * a20), (a11 * a00 - a01 * a10)) / det;
}
//espens normals encoding start
vec3 viewToWorld(vec3 viewPos) {

    vec4 pos;
    pos.xyz = viewPos;
    pos.w = 0.0;
    pos = gbufferModelViewInverse * pos;

    return pos.xyz;
}

vec3 worldToView(vec3 worldPos) {

    vec4 pos = vec4(worldPos, 0.0);
    pos = gbufferModelView * pos;

    return pos.xyz;
}


//encode normal in two channels (xy),torch(z) and sky lightmap (w)
vec4 encode (vec3 n, vec2 lightmaps)
{
	n.xy = n.xy / dot(abs(n), vec3(1.0));
	n.xy = n.z <= 0.0 ? (1.0 - abs(n.yx)) * sign(n.xy) : n.xy;
    vec2 encn = n.xy * 0.5 + 0.5;
	
    return vec4(encn,vec2(lightmaps.x,lightmaps.y));
}
//espens normals encoding end

#ifdef MC_NORMAL_MAP
vec3 applyBump(mat3 tbnMatrix, vec3 bump)
{

		float bumpmult = 1.0-wetness*0.50;

		bump = bump * vec3(bumpmult, bumpmult, bumpmult) + vec3(0.0f, 0.0f, 1.0f - bumpmult);

		return normalize(bump*tbnMatrix);
}
#endif

//encoding by jodie
float encodeVec2(vec2 a){
    const vec2 constant1 = vec2( 1., 256.) / 65535.;
    vec2 temp = floor( a * 255. );
	return temp.x*constant1.x+temp.y*constant1.y;
}
float encodeVec2(float x,float y){
    return encodeVec2(vec2(x,y));
}

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define  projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec3 toScreenSpace(vec3 p) {
	vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
    vec3 p3 = p * 2. - 1.;
    vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragposition.xyz / fragposition.w;
}
vec3 toClipSpace3(vec3 viewSpacePosition) {
    return projMAD(gbufferProjection, viewSpacePosition) / -viewSpacePosition.z * 0.5 + 0.5;
}

float luma(vec3 color) {
	return dot(color,vec3(0.21, 0.72, 0.07));
}


vec3 toLinear(vec3 sRGB){
	return sRGB * (sRGB * (sRGB * 0.305306011 + 0.682171111) + 0.012522878);
}

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
/* DRAWBUFFERS:17 */
void main() {
	float noise = interleaved_gradientNoise();
	vec3 normal = normalMat.xyz;
	#ifdef MC_NORMAL_MAP
		vec3 tangent2 = normalize(cross(tangent.rgb,normal)*tangent.w);
		mat3 tbnMatrix = mat3(tangent.x, tangent2.x, normal.x,
								  tangent.y, tangent2.y, normal.y,
						     	  tangent.z, tangent2.z, normal.z);
	#endif


	vec4 data0 = texture2D(texture, lmtexcoord.xy, Texture_MipMap_Bias);

  	#ifdef DISABLE_ALPHA_MIPMAPS
  		data0.a = texture2DLod(texture,lmtexcoord.xy,0).a;
  	#endif
	
	gl_FragData[1] = texture2D(specular, lmtexcoord.xy, Texture_MipMap_Bias);
	data0.rgb*=color.rgb;
  	float avgBlockLum = luma(texture2DLod(texture, lmtexcoord.xy,128).rgb*color.rgb);

	data0.rgb = clamp(data0.rgb*pow(avgBlockLum,-0.33)*0.859,0.0,1.0);

	
	if (data0.a > 0.1) {
		data0.a = normalMat.a*0.5+0.5;
	} else {
		data0.a = 0.0;
	}

	vec2 lm = lmtexcoord.zw;

	#ifndef GBUFFER_BASIC && defined MC_NORMAL_MAP
		vec3 normalTex = texture2D(normals, lmtexcoord.xy, Texture_MipMap_Bias).rgb;
		lm *= normalTex.b;
		normalTex.xy = normalTex.xy*2.0-1.0;
			
		#ifdef GBUFFER_ENTITIES
			normalTex.z = sqrt(1.0 - dot(clamp(normalTex.xy,0.0,1000.0), clamp(normalTex.xy,0.0,1000.0)));
			normalTex.z *= normalTex.z;
		#else
			normalTex.z = sqrt(1.0 - dot(normalTex.xy, normalTex.xy));
		#endif
	
		normal = applyBump(tbnMatrix,normalTex);
	#endif

	//espens encoding
	vec4 data1 = clamp(encode(viewToWorld(normal), lm),0.0,1.0);

	gl_FragData[0] = vec4(encodeVec2(data0.x,data1.x),encodeVec2(data0.y,data1.y),encodeVec2(data0.z,data1.z),encodeVec2(data1.w,data0.w));
	gl_FragData[1] = texture2D(specular, lmtexcoord.xy, Texture_MipMap_Bias);
	gl_FragData[1].a = 0.0;

	
}
