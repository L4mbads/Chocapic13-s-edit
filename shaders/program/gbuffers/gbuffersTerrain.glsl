#extension GL_ARB_shader_texture_lod : enable

#define WAVY_PLANTS
#define WAVY_STRENGTH 1.0 //[0.1 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define WAVY_SPEED 1.0 //[0.001 0.01 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 1.0 1.25 1.5 2.0 3.0 4.0]
#define SEPARATE_AO
//#define POM
//#define USE_LUMINANCE_AS_HEIGHTMAP	//Can generate POM on any texturepack (may look weird in some cases)
#define Depth_Write_POM	// POM adjusts the actual position, so screen space shadows can cast shadows on POM
#define POM_DEPTH 0.25 // [0.025 0.05 0.075 0.1 0.125 0.15 0.20 0.25 0.30 0.50 0.75 1.0] //Increase to increase POM strength
#define MAX_ITERATIONS 50 // [5 10 15 20 25 30 40 50 60 70 80 90 100 125 150 200 400] //Improves quality at grazing angles (reduces performance)
#define MAX_DIST 25.0 // [5.0 10.0 15.0 20.0 25.0 30.0 40.0 50.0 60.0 70.0 80.0 90.0 100.0 125.0 150.0 200.0 400.0] //Increases distance at which POM is calculated
//#define AutoGeneratePOMTextures	//Can generate POM on any texturepack (may look weird in some cases)
#define Texture_MipMap_Bias -1.00 // Uses a another mip level for textures. When reduced will increase texture detail but may induce a lot of shimmering. [-5.00 -4.75 -4.50 -4.25 -4.00 -3.75 -3.50 -3.25 -3.00 -2.75 -2.50 -2.25 -2.00 -1.75 -1.50 -1.25 -1.00 -0.75 -0.50 -0.25 0.00 0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00 2.25 2.50 2.75 3.00 3.25 3.50 3.75 4.00 4.25 4.50 4.75 5.00]
//#define DISABLE_ALPHA_MIPMAPS //Disables mipmaps on the transparency of alpha-tested things like foliage, may cost a few fps in some cases
	
#ifndef USE_LUMINANCE_AS_HEIGHTMAP
	#ifndef MC_NORMAL_MAP
		#undef POM
	#endif
#endif

#ifdef POM
	#define MC_NORMAL_MAP
#endif

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec4 lmtexcoord;
varying vec4 color;
varying vec4 normalMat;
#ifdef POM
	varying vec4 vtexcoordam; // .st for add, .pq for mul
	varying vec4 vtexcoord;
#endif

#ifdef MC_NORMAL_MAP
	varying vec4 tangent;
	
#endif
	
#ifdef VERTEX

	const float PI48 = 150.796447372*WAVY_SPEED;
	float pi2wt = PI48*frameTimeCounter;

	attribute vec4 mc_Entity;
	attribute vec4 at_tangent;
	attribute vec4 mc_midTexCoord;

	#include "/lib/projections.glsl"
	
	
	vec2 calcWave(in vec3 pos) {
	
	    float magnitude = abs(sin(dot(vec4(frameTimeCounter, pos),vec4(1.0,0.005,0.005,0.005)))*0.5+0.72)*0.013;
		vec2 ret = (sin(pi2wt*vec2(0.0063,0.0015)*4. - pos.xz + pos.y*0.05)+0.1)*magnitude;
	
	    return ret;
	}
	
	vec3 calcMovePlants(in vec3 pos) {
	    vec2 move1 = calcWave(pos );
		float move1y = -length(move1);
	   return vec3(move1.x,move1y,move1.y)*5.*WAVY_STRENGTH;
	}
	
	vec3 calcWaveLeaves(in vec3 pos, in float fm, in float mm, in float ma, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5) {
	
	    float magnitude = abs(sin(dot(vec4(frameTimeCounter, pos),vec4(1.0,0.005,0.005,0.005)))*0.5+0.72)*0.013;
		vec3 ret = (sin(pi2wt*vec3(0.0063,0.0224,0.0015)*1.5 - pos))*magnitude;
	
	    return ret;
	}
	
	vec3 calcMoveLeaves(in vec3 pos, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5, in vec3 amp1, in vec3 amp2) {
	    vec3 move1 = calcWaveLeaves(pos      , 0.0054, 0.0400, 0.0400, 0.0127, 0.0089, 0.0114, 0.0063, 0.0224, 0.0015) * amp1;
	    return move1*5.*WAVY_STRENGTH;
	}
	
	void main() {
		lmtexcoord.xy = (gl_MultiTexCoord0).xy;

		#ifdef POM
			vec2 midcoord = (gl_TextureMatrix[0] *  mc_midTexCoord).st;
			vec2 texcoordminusmid = lmtexcoord.xy-midcoord;
			vtexcoordam.pq  = abs(texcoordminusmid)*2;
			vtexcoordam.st  = min(lmtexcoord.xy,midcoord-texcoordminusmid);
			vtexcoord.xy    = sign(texcoordminusmid)*0.5+0.5;
		#endif

		vec2 lmcoord = gl_MultiTexCoord1.xy/255.;
		lmtexcoord.zw = lmcoord;
	
		vec3 position = mat3(gl_ModelViewMatrix) * vec3(gl_Vertex) + gl_ModelViewMatrix[3].xyz;
	
		color = gl_Color;
	
		bool istopv = gl_MultiTexCoord0.t < mc_midTexCoord.t;

		#ifdef MC_NORMAL_MAP
			tangent = vec4(normalize(gl_NormalMatrix *at_tangent.rgb),at_tangent.w);
		#endif
	
		normalMat = vec4(normalize(gl_NormalMatrix *gl_Normal),mc_Entity.x == 10004 || mc_Entity.x == 10003 || mc_Entity.x == 10001 ? 0.5:1.0);
		normalMat.a = mc_Entity.x == 10006 ? 0.6 : normalMat.a;

		#ifdef WAVY_PLANTS

			if ((mc_Entity.x == 10001 && istopv) && abs(position.z) < 64.0) {
	    		vec3 worldpos = mat3(gbufferModelViewInverse) * position + gbufferModelViewInverse[3].xyz + cameraPosition;
				worldpos.xyz += calcMovePlants(worldpos.xyz)*lmtexcoord.w - cameraPosition;
	    		position = mat3(gbufferModelView) * worldpos + gbufferModelView[3].xyz;
			}
	
			if (mc_Entity.x == 10003 && abs(position.z) < 64.0) {
	    		vec3 worldpos = mat3(gbufferModelViewInverse) * position + gbufferModelViewInverse[3].xyz + cameraPosition;
				worldpos.xyz += calcMoveLeaves(worldpos.xyz, 0.0040, 0.0064, 0.0043, 0.0035, 0.0037, 0.0041, vec3(1.0,0.2,1.0), vec3(0.5,0.1,0.5))*lmtexcoord.w  - cameraPosition;
	    		position = mat3(gbufferModelView) * worldpos + gbufferModelView[3].xyz;
			}

		#endif

		if (mc_Entity.x == 10005){
			color.rgb = normalize(color.rgb)*sqrt(3.0);
			normalMat.a = 0.9;
		}
		gl_Position = toClipSpace4(position);

		#ifdef SEPARATE_AO

			lmtexcoord.z *= sqrt(color.a);
			lmtexcoord.w *= color.a;

		#else

			color.rgb*=color.a;

		#endif

	
	
		#ifdef TAA_UPSCALING
			gl_Position.xy = gl_Position.xy * RENDER_SCALE + RENDER_SCALE * gl_Position.w - gl_Position.w;
		#endif

		#ifdef TAA
		gl_Position.xy += offsets[framemod8] * gl_Position.w * texelSize;
		#endif
	}

#elif defined FRAGMENT
	
	#ifndef AutoGeneratePOMTextures
		#ifndef MC_NORMAL_MAP
		#undef POM
		#endif
	#endif
	
	#ifdef POM
		#define MC_NORMAL_MAP
	#endif
	
	const float mincoord = 1.0/4096.0;
	const float maxcoord = 1.0-mincoord;
	
	const float MAX_OCCLUSION_DISTANCE = MAX_DIST;
	const float MIX_OCCLUSION_DISTANCE = MAX_DIST*0.9;
	const int   MAX_OCCLUSION_POINTS   = MAX_ITERATIONS;
	

	#ifdef MC_NORMAL_MAP
		uniform float wetness;
		uniform sampler2D normals;
	#endif

	uniform sampler2D specular;

	#ifdef POM
		vec2 dcdx = dFdx(vtexcoord.st*vtexcoordam.pq)*exp2(Texture_MipMap_Bias);
		vec2 dcdy = dFdy(vtexcoord.st*vtexcoordam.pq)*exp2(Texture_MipMap_Bias);

	vec4 readNormal(in vec2 coord)
	{
		return texture2DGradARB(normals,fract(coord)*vtexcoordam.pq+vtexcoordam.st,dcdx,dcdy);
	}
	vec4 readTexture(in vec2 coord)
	{
		return texture2DGradARB(texture,fract(coord)*vtexcoordam.pq+vtexcoordam.st,dcdx,dcdy);
	}

	#endif
	uniform sampler2D texture;

	#include "/lib/colorTransforms.glsl"
	#include "/lib/colorDither.glsl"
	#include "/lib/projections.glsl"
	#include "/lib/material.glsl"

	/* RENDERTARGETS:1,7 */
	void main() {
		float noise = interleaved_gradientNoise();
		vec3 normal = normalMat.xyz;
		#ifdef MC_NORMAL_MAP
			vec3 tangent2 = normalize(cross(tangent.rgb,normal)*tangent.w);
			mat3 tbnMatrix = mat3(tangent.x, tangent2.x, normal.x,
									  tangent.y, tangent2.y, normal.y,
							     	  tangent.z, tangent2.z, normal.z);
		#endif
	
	#ifdef POM
		vec2 tempOffset=offsets[framemod8];
		vec2 adjustedTexCoord = fract(vtexcoord.st)*vtexcoordam.pq+vtexcoordam.st;
		vec3 fragpos = toScreenSpace(gl_FragCoord.xyz*vec3(texelSize/RENDER_SCALE,1.0)-vec3(vec2(tempOffset)*texelSize*0.5,0.0));
		vec3 viewVector = normalize(tbnMatrix*fragpos);
		float dist = length(fragpos);
		#ifdef Depth_Write_POM
			gl_FragDepth = gl_FragCoord.z;
		#endif
	if (dist < MAX_OCCLUSION_DISTANCE) {
		#ifndef AutoGeneratePOMTextures
		  if ( viewVector.z < 0.0 && readNormal(vtexcoord.st).a < 0.9999 && readNormal(vtexcoord.st).a > 0.00001) {
		    vec3 interval = viewVector.xyz /-viewVector.z/MAX_OCCLUSION_POINTS*POM_DEPTH;
		    vec3 coord = vec3(vtexcoord.st, 1.0);
		    coord += noise*interval;
				float sumVec = noise;
		    for (int loopCount = 0;
		        (loopCount < MAX_OCCLUSION_POINTS) && (1.0 - POM_DEPTH + POM_DEPTH*readNormal(coord.st).a < coord.p) &&coord.p >= 0.0;
		        ++loopCount) {
		             coord = coord+interval;
								 sumVec += 1.0;
		    }
		    if (coord.t < mincoord) {
		      if (readTexture(vec2(coord.s,mincoord)).a == 0.0) {
		        coord.t = mincoord;
		        discard;
		      }
		    }
		    adjustedTexCoord = mix(fract(coord.st)*vtexcoordam.pq+vtexcoordam.st , adjustedTexCoord , max(dist-MIX_OCCLUSION_DISTANCE,0.0)/(MAX_OCCLUSION_DISTANCE-MIX_OCCLUSION_DISTANCE));
	
		    vec3 truePos = fragpos + sumVec*inverse(tbnMatrix)*interval;
		    #ifdef Depth_Write_POM
		    gl_FragDepth = toClipSpace3(truePos).z;
		    #endif
		  }
		#else
		if ( viewVector.z < 0.0) {
			vec3 interval = viewVector.xyz/-viewVector.z/MAX_OCCLUSION_POINTS*POM_DEPTH;
			vec3 coord = vec3(vtexcoord.st, 1.0);
			coord += noise*interval;
			float sumVec = noise;
			float lum0 = luma(texture2DLod(texture,lmtexcoord.xy,100).rgb);
		  for (int loopCount = 0;
		      (loopCount < MAX_OCCLUSION_POINTS) && (1.0 - POM_DEPTH + POM_DEPTH*luma(readTexture(coord.st).rgb)/lum0*0.5 < coord.p) && coord.p >= 0.0;
					++loopCount) {
							 coord = coord+interval;
							 sumVec += 1.0;
			}
			if (coord.t < mincoord) {
				if (readTexture(vec2(coord.s,mincoord)).a == 0.0) {
					coord.t = mincoord;
					discard;
				}
			}
			adjustedTexCoord = mix(fract(coord.st)*vtexcoordam.pq+vtexcoordam.st , adjustedTexCoord , max(dist-MIX_OCCLUSION_DISTANCE,0.0)/(MAX_OCCLUSION_DISTANCE-MIX_OCCLUSION_DISTANCE));
	
			vec3 truePos = fragpos + sumVec*inverse(tbnMatrix)*(interval);
			#ifdef Depth_Write_POM
			gl_FragDepth = toClipSpace3(truePos).z;
			#endif
		}
		#endif
	
	  }
	
		vec4 data0 = texture2DGradARB(texture, adjustedTexCoord.xy,dcdx,dcdy);
	  #ifdef DISABLE_ALPHA_MIPMAPS
	    data0.a = texture2DGradARB(texture, adjustedTexCoord.xy,vec2(0.),vec2(0.0)).a;
	  #endif
		if (data0.a > 0.1) data0.a = normalMat.a;
	  else data0.a = 0.0;
	
		vec3 normalTex = texture2DGradARB(normals,adjustedTexCoord.xy,dcdx,dcdy).xyz;
		vec2 lm = lmtexcoord.zw*normalTex.b;
		normalTex.xy = normalTex.xy*2.0-1.0;
		normalTex.z = sqrt(1.0 - dot(normalTex.xy, normalTex.xy));
		normal = applyBump(tbnMatrix,normalTex);
	
	
		data0.rgb*=color.rgb;
		//original
		//vec4 data1 = clamp(noise*exp2(-8.)+encode(normal, lm),0.,1.0);
		//espens encoding
		vec4 data1 = clamp(encode(viewToWorld(normal), lm),0.0,1.0);
	
		gl_FragData[0] = vec4(encodeVec2(data0.x,data1.x),encodeVec2(data0.y,data1.y),encodeVec2(data0.z,data1.z),encodeVec2(data1.w,data0.w));
		gl_FragData[1] = texture2DGradARB(specular, adjustedTexCoord.xy,dcdx,dcdy);
		gl_FragData[1].a = 0.0;
	
	#else
	
		vec4 data0 = texture2D(texture, lmtexcoord.xy, Texture_MipMap_Bias);
		gl_FragData[1] = texture2D(specular, lmtexcoord.xy, Texture_MipMap_Bias);
		data0.rgb*=color.rgb;
	  	float avgBlockLum = luma(texture2DLod(texture, lmtexcoord.xy,128).rgb*color.rgb);
	  	data0.rgb = clamp(data0.rgb*pow(avgBlockLum,-0.33)*0.85,0.0,1.0);
	  //data0.rgb = vec3(avgBlockLum);
	  //data0.rgb = clamp(data0.rgb*pow((0.55+avgBlockLum),-(1.0/2.233)),0.0,1.0);
	  //if (toLinear(data0.rgb).g > 0.25) data0.rgb=vec3(1.,0.,0.);
	  	#ifdef DISABLE_ALPHA_MIPMAPS
	  		data0.a = texture2DLod(texture,lmtexcoord.xy,0).a;
	  	#endif
	
	
		if (data0.a > 0.1) data0.a = normalMat.a;
	  	else data0.a = 0.0;
		vec2 lm = lmtexcoord.zw;
		#ifdef MC_NORMAL_MAP
			vec3 normalTex = texture2D(normals, lmtexcoord.xy, Texture_MipMap_Bias).rgb;
			lm *= normalTex.b;
			normalTex.xy = normalTex.xy*2.0-1.0;
			normalTex.z = sqrt(1.0 - dot(normalTex.xy, normalTex.xy));
			normal = applyBump(tbnMatrix,normalTex);
		#endif
		//original
		//vec4 data1 = clamp(noise/256.+encode(normal, lm),0.,1.0);
		//espens encoding
		vec4 data1 = clamp(encode(viewToWorld(normal), lm),0.0,1.0);
		
		gl_FragData[0] = vec4(encodeVec2(data0.x,data1.x),encodeVec2(data0.y,data1.y),encodeVec2(data0.z,data1.z),encodeVec2(data1.w,data0.w));
		gl_FragData[1].a = 0.0;
	#endif
	
	}

#endif
