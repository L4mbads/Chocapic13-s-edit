#extension GL_EXT_gpu_shader4 : enable



in vec4 lmtexcoord;
in vec4 color;
in vec4 normalMat;

uniform sampler2D texture;

//faster and actually more precise than pow 2.2
vec3 toLinear(vec3 sRGB){
	return sRGB * (sRGB * (sRGB * 0.305306011 + 0.682171111) + 0.012522878);
}


//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
/* DRAWBUFFERS:2 */
void main() {
	vec3 albedo = toLinear(texture2D(texture, lmtexcoord.xy).rgb*color.rgb);
	
	#if defined GBUFFER_BEACONBEAM

		float torch_lightmap = lmtexcoord.z;

		vec3 diffuseLight = torch_lightmap*vec3(20.,30.,50.) ;
		vec3 color = diffuseLight*albedo;

	#elif defined GBUFFER_ARMOR_GLINT

		vec3 color = albedo;

	#endif

	gl_FragData[0].rgb = color;

	#if defined GBUFFER_BEACONBEAM
		gl_FragData[0].a = 1.0;

	#elif defined GBUFFER_ARMOR_GLINT

		gl_FragData[0].a *= 0.3;

		if (gl_FragData[0].a < 0.1) {
			discard;
		}
	#endif
}
