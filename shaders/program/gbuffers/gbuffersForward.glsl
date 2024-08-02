#extension GL_ARB_shader_texture_lod : enable

#define Texture_MipMap_Bias -1.00 // Uses a another mip level for textures. When reduced will increase texture detail but may induce a lot of shimmering. [-5.00 -4.75 -4.50 -4.25 -4.00 -3.75 -3.50 -3.25 -3.00 -2.75 -2.50 -2.25 -2.00 -1.75 -1.50 -1.25 -1.00 -0.75 -0.50 -0.25 0.00 0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00 2.25 2.50 2.75 3.00 3.25 3.50 3.75 4.00 4.25 4.50 4.75 5.00]

const float mincoord = 1.0/4096.0;
const float maxcoord = 1.0-mincoord;

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

#include "/lib/projections.glsl"
#include "/lib/colorTransforms.glsl"
#include "/lib/material.glsl"


/* RENDERTARGETS:1,7 */
void main() {

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
	
	//gl_FragData[1] = texture2D(specular, lmtexcoord.xy, Texture_MipMap_Bias);

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
