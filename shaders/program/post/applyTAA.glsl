//TAA OPTIONS
//#define NO_CLIP	//Removes all anti-ghosting techniques used and creates a sharp image (good for still screenshots)
#define BLEND_FACTOR 0.1 //[0.01 0.02 0.03 0.04 0.05 0.06 0.08 0.1 0.12 0.14 0.16] higher values = more flickering but sharper image, lower values = less flickering but the image will be blurrier
#define MOTION_REJECTION 0.0 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.5] //Higher values=sharper image in motion at the cost of flickering
#define ANTI_GHOSTING 0.0 //[0.0 0.25 0.5 0.75 1.0] High values reduce ghosting but may create flickering
#define FLICKER_REDUCTION 0.5  //[0.0 0.25 0.5 0.75 1.0] High values reduce flickering but may reduce sharpness
#define CLOSEST_VELOCITY //improves edge quality in motion at the cost of performance

varying vec2 texcoord;
flat varying float exposureA;
flat varying float tempOffsets;

#if defined VERTEX
	
	uniform sampler2D colortex4;
	
	
	void main() {
	
		tempOffsets = HaltonSeq2(frameCounter%10000);
		gl_Position = ftransform();
		texcoord = gl_MultiTexCoord0.xy;
		exposureA = texelFetch2D(colortex4,ivec2(10,37),0).r;
	}
	
#elif defined FRAGMENT
	
	uniform sampler2D colortex3;
	uniform sampler2D colortex5;
	uniform sampler2D colortex0;
	uniform sampler2D depthtex0;
	
	#include "/lib/projections.glsl"
	#include "/lib/colorTransforms.glsl"
	#include "/lib/colorDither.glsl"
	
	//returns the projected coordinates of the closest point to the camera in the 3x3 neighborhood
	vec3 closestToCamera5taps(vec2 texcoord)
	{
		vec2 du = vec2(texelSize.x*2., 0.0);
		vec2 dv = vec2(0.0, texelSize.y*2.);
	
		vec3 dtl = vec3(texcoord,0.) + vec3(-texelSize, texture2D(depthtex0, texcoord - dv - du).x);
		vec3 dtr = vec3(texcoord,0.) +  vec3( texelSize.x, -texelSize.y, texture2D(depthtex0, texcoord - dv + du).x);
		vec3 dmc = vec3(texcoord,0.) + vec3( 0.0, 0.0, texture2D(depthtex0, texcoord).x);
		vec3 dbl = vec3(texcoord,0.) + vec3(-texelSize.x, texelSize.y, texture2D(depthtex0, texcoord + dv - du).x);
		vec3 dbr = vec3(texcoord,0.) + vec3( texelSize.x, texelSize.y, texture2D(depthtex0, texcoord + dv + du).x);
	
		vec3 dmin = dmc;
		dmin = dmin.z > dtr.z? dtr : dmin;
		dmin = dmin.z > dtl.z? dtl : dmin;
		dmin = dmin.z > dbl.z? dbl : dmin;
		dmin = dmin.z > dbr.z? dbr : dmin;
		#ifdef TAA_UPSCALING
		dmin.xy = dmin.xy/RENDER_SCALE;
		#endif
		return dmin;
	}
	
	//Modified texture interpolation from inigo quilez
	vec4 smoothfilter(in sampler2D tex, in vec2 uv)
	{
		vec2 textureResolution = vec2(viewWidth,viewHeight);
		uv = uv*textureResolution + 0.5;
		vec2 iuv = floor( uv );
		vec2 fuv = fract( uv );
		uv = iuv + fuv*fuv*fuv*(fuv*(fuv*6.0-15.0)+10.0);
		uv = (uv - 0.5)/textureResolution;
		return texture2D( tex, uv);
	}
	//Due to low sample count we "tonemap" the inputs to preserve colors and smoother edges
	vec3 weightedSample(sampler2D colorTex, vec2 texcoord){
		vec3 wsample = texture2D(colorTex,texcoord).rgb*exposureA;
		return wsample/(1.0+luma(wsample));
	
	}
	
	
	//from : https://gist.github.com/TheRealMJP/c83b8c0f46b63f3a88a5986f4fa982b1
	vec4 SampleTextureCatmullRom(sampler2D tex, vec2 uv, vec2 texSize )
	{
	    // We're going to sample a a 4x4 grid of texels surrounding the target UV coordinate. We'll do this by rounding
	    // down the sample location to get the exact center of our "starting" texel. The starting texel will be at
	    // location [1, 1] in the grid, where [0, 0] is the top left corner.
	    vec2 samplePos = uv * texSize;
	    vec2 texPos1 = floor(samplePos - 0.5) + 0.5;
	
	    // Compute the fractional offset from our starting texel to our original sample location, which we'll
	    // feed into the Catmull-Rom spline function to get our filter weights.
	    vec2 f = samplePos - texPos1;
	
	    // Compute the Catmull-Rom weights using the fractional offset that we calculated earlier.
	    // These equations are pre-expanded based on our knowledge of where the texels will be located,
	    // which lets us avoid having to evaluate a piece-wise function.
	    vec2 w0 = f * ( -0.5 + f * (1.0 - 0.5*f));
	    vec2 w1 = 1.0 + f * f * (-2.5 + 1.5*f);
	    vec2 w2 = f * ( 0.5 + f * (2.0 - 1.5*f) );
	    vec2 w3 = f * f * (-0.5 + 0.5 * f);
	
	    // Work out weighting factors and sampling offsets that will let us use bilinear filtering to
	    // simultaneously evaluate the middle 2 samples from the 4x4 grid.
	    vec2 w12 = w1 + w2;
	    vec2 offset12 = w2 / (w1 + w2);
	
	    // Compute the final UV coordinates we'll use for sampling the texture
	    vec2 texPos0 = texPos1 - vec2(1.0);
	    vec2 texPos3 = texPos1 + vec2(2.0);
	    vec2 texPos12 = texPos1 + offset12;
	
	    texPos0 *= texelSize;
	    texPos3 *= texelSize;
	    texPos12 *= texelSize;
	
	    vec4 result = vec4(0.0);
	    result += texture2D(tex, vec2(texPos0.x,  texPos0.y)) * w0.x * w0.y;
	    result += texture2D(tex, vec2(texPos12.x, texPos0.y)) * w12.x * w0.y;
	    result += texture2D(tex, vec2(texPos3.x,  texPos0.y)) * w3.x * w0.y;
	
	    result += texture2D(tex, vec2(texPos0.x,  texPos12.y)) * w0.x * w12.y;
	    result += texture2D(tex, vec2(texPos12.x, texPos12.y)) * w12.x * w12.y;
	    result += texture2D(tex, vec2(texPos3.x,  texPos12.y)) * w3.x * w12.y;
	
	    result += texture2D(tex, vec2(texPos0.x,  texPos3.y)) * w0.x * w3.y;
	    result += texture2D(tex, vec2(texPos12.x, texPos3.y)) * w12.x * w3.y;
	    result += texture2D(tex, vec2(texPos3.x,  texPos3.y)) * w3.x * w3.y;
	
	    return result;
	}
	
	//approximation from SMAA presentation from siggraph 2016
	vec3 FastCatmulRom(sampler2D colorTex, vec2 texcoord, vec4 rtMetrics, float sharpenAmount)
	{
	    vec2 position = rtMetrics.zw * texcoord;
	    vec2 centerPosition = floor(position - 0.5) + 0.5;
	    vec2 f = position - centerPosition;
	    vec2 f2 = f * f;
	    vec2 f3 = f * f2;
	
	    float c = sharpenAmount;
	    vec2 w0 =        -c  * f3 +  2.0 * c         * f2 - c * f;
	    vec2 w1 =  (2.0 - c) * f3 - (3.0 - c)        * f2         + 1.0;
	    vec2 w2 = -(2.0 - c) * f3 + (3.0 -  2.0 * c) * f2 + c * f;
	    vec2 w3 =         c  * f3 -                c * f2;
	
	    vec2 w12 = w1 + w2;
	    vec2 tc12 = rtMetrics.xy * (centerPosition + w2 / w12);
	    vec3 centerColor = texture2D(colorTex, vec2(tc12.x, tc12.y)).rgb;
	
	    vec2 tc0 = rtMetrics.xy * (centerPosition - 1.0);
	    vec2 tc3 = rtMetrics.xy * (centerPosition + 2.0);
	    vec4 color = vec4(texture2D(colorTex, vec2(tc12.x, tc0.y )).rgb, 1.0) * (w12.x * w0.y ) +
	                   vec4(texture2D(colorTex, vec2(tc0.x,  tc12.y)).rgb, 1.0) * (w0.x  * w12.y) +
	                   vec4(centerColor,                                      1.0) * (w12.x * w12.y) +
	                   vec4(texture2D(colorTex, vec2(tc3.x,  tc12.y)).rgb, 1.0) * (w3.x  * w12.y) +
	                   vec4(texture2D(colorTex, vec2(tc12.x, tc3.y )).rgb, 1.0) * (w12.x * w3.y );
		return color.rgb/color.a;
	
	}
	
	vec3 clip_aabb(vec3 q,vec3 aabb_min, vec3 aabb_max)
		{
			vec3 p_clip = 0.5 * (aabb_max + aabb_min);
			vec3 e_clip = 0.5 * (aabb_max - aabb_min) + 0.00000001;
	
			vec3 v_clip = q - vec3(p_clip);
			vec3 v_unit = v_clip.xyz / e_clip;
			vec3 a_unit = abs(v_unit);
			float ma_unit = max(a_unit.x, max(a_unit.y, a_unit.z));
	
			if (ma_unit > 1.0)
				return vec3(p_clip) + v_clip / ma_unit;
			else
				return q;
		}
	
	vec3 tonemap(vec3 col){
		return col/(1+luma(col));
	}
	vec3 invTonemap(vec3 col){
		return col/(1-luma(col));
	}
	
	vec3 TAA_hq(){
		#ifdef TAA_UPSCALING
		vec2 adjTC = clamp(texcoord*RENDER_SCALE, vec2(0.0),RENDER_SCALE-texelSize*2.);
		#else
		vec2 adjTC = texcoord;
		#endif
	
		//use velocity from the nearest texel from camera in a 3x3 box in order to improve edge quality in motion
		#ifdef CLOSEST_VELOCITY
		vec3 closestToCamera = closestToCamera5taps(adjTC);
		#endif
	
		#ifndef CLOSEST_VELOCITY
		vec3 closestToCamera = vec3(texcoord,texture2D(depthtex0,adjTC).x);
		#endif
	
		//reproject previous frame
		vec3 fragposition = toScreenSpace(closestToCamera);
		fragposition = mat3(gbufferModelViewInverse) * fragposition + gbufferModelViewInverse[3].xyz + (cameraPosition - previousCameraPosition);
		vec3 previousPosition = mat3(gbufferPreviousModelView) * fragposition + gbufferPreviousModelView[3].xyz;
		previousPosition = toClipSpace3Prev(previousPosition);
		vec2 velocity = previousPosition.xy - closestToCamera.xy;
		previousPosition.xy = texcoord + velocity;
	
		//reject history if off-screen and early exit
		if (previousPosition.x < 0.0 || previousPosition.y < 0.0 || previousPosition.x > 1.0 || previousPosition.y > 1.0)
			return smoothfilter(colortex3, adjTC + offsets[framemod8]*texelSize*0.5).xyz;
	
		#ifdef TAA_UPSCALING
		vec3 albedoCurrent0 = smoothfilter(colortex3, adjTC + offsets[framemod8]*texelSize*0.5).xyz;
		// Interpolating neighboorhood clampling boundaries between pixels
		vec3 cMax = texture2D(colortex0, adjTC).rgb;
		vec3 cMin = texture2D(colortex6, adjTC).rgb;
		#else
		vec3 albedoCurrent0 = texture2D(colortex3, adjTC).rgb;
		vec3 albedoCurrent1 = texture2D(colortex3, adjTC + vec2(texelSize.x,texelSize.y)).rgb;
		vec3 albedoCurrent2 = texture2D(colortex3, adjTC + vec2(texelSize.x,-texelSize.y)).rgb;
		vec3 albedoCurrent3 = texture2D(colortex3, adjTC + vec2(-texelSize.x,-texelSize.y)).rgb;
		vec3 albedoCurrent4 = texture2D(colortex3, adjTC + vec2(-texelSize.x,texelSize.y)).rgb;
		vec3 albedoCurrent5 = texture2D(colortex3, adjTC + vec2(0.0,texelSize.y)).rgb;
		vec3 albedoCurrent6 = texture2D(colortex3, adjTC + vec2(0.0,-texelSize.y)).rgb;
		vec3 albedoCurrent7 = texture2D(colortex3, adjTC + vec2(-texelSize.x,0.0)).rgb;
		vec3 albedoCurrent8 = texture2D(colortex3, adjTC + vec2(texelSize.x,0.0)).rgb;
		//Assuming the history color is a blend of the 3x3 neighborhood, we clamp the history to the min and max of each channel in the 3x3 neighborhood
		vec3 cMax = max(max(max(albedoCurrent0,albedoCurrent1),albedoCurrent2),max(albedoCurrent3,max(albedoCurrent4,max(albedoCurrent5,max(albedoCurrent6,max(albedoCurrent7,albedoCurrent8))))));
		vec3 cMin = min(min(min(albedoCurrent0,albedoCurrent1),albedoCurrent2),min(albedoCurrent3,min(albedoCurrent4,min(albedoCurrent5,min(albedoCurrent6,min(albedoCurrent7,albedoCurrent8))))));
		albedoCurrent0 = smoothfilter(colortex3, adjTC + offsets[framemod8]*texelSize*0.5).rgb;
		#endif
	
		#ifndef NO_CLIP
		vec3 albedoPrev = max(FastCatmulRom(colortex5, previousPosition.xy,vec4(texelSize, 1.0/texelSize), 0.75).xyz, 0.0);
		vec3 finalcAcc = clamp(albedoPrev,cMin,cMax);
	
		//Increases blending factor when far from AABB and in motion, reduces ghosting
		float isclamped = distance(albedoPrev,finalcAcc)/luma(albedoPrev) * 0.5;
		float movementRejection = (0.12+isclamped)*clamp(length(velocity/texelSize),0.0,1.0);
		//Blend current pixel with clamped history, apply fast tonemap beforehand to reduce flickering
		vec3 supersampled = invTonemap(mix(tonemap(finalcAcc),tonemap(albedoCurrent0),clamp(BLEND_FACTOR + movementRejection,0.,1.)));
		#endif
	
	
		#ifdef NO_CLIP
		vec3 albedoPrev = texture2D(colortex5, previousPosition.xy).xyz;
		vec3 supersampled =  mix(albedoPrev,albedoCurrent0,clamp(0.05,0.,1.));
		#endif
	
		//De-tonemap
		return supersampled;
	}
	
	void main() {
		/* RENDERTARGETS:5 */
		gl_FragData[0].a = 1.0;
	
		#ifdef TAA
	
			vec3 color = TAA_hq();
			gl_FragData[0].rgb = clamp(fp10Dither(color,texcoord),6.11*1e-5,65000.0); //triangularize(R2_dither())
		
		#else
		
			vec3 color = clamp(fp10Dither(texture2D(colortex3,texcoord).rgb,triangularize(interleaved_gradientNoise())),0.,65000.);
			gl_FragData[0].rgb = color;
		
		#endif
	
	}
	
#endif
