varying vec2 texcoord;
varying vec2 resScale;

#if defined VERTEX

	void main() {
		vec2 clampedRes = max(vec2(viewWidth,viewHeight),vec2(1920.0,1080.0))/BLOOM_QUALITY;
		gl_Position = ftransform();
		//0-0.25
		gl_Position.y = (gl_Position.y*0.5+0.5)*0.25/clampedRes.y*1080.0*2.0-1.0;
		//0-0.5
		gl_Position.x = (gl_Position.x*0.5+0.5)*0.5/clampedRes.x*1920.0*2.0-1.0;

		texcoord = gl_MultiTexCoord0.xy/clampedRes*vec2(1920.,1080.);
		resScale = vec2(1920.,1080.)/max(vec2(viewWidth,viewHeight),vec2(1920.0,1080.))*BLOOM_QUALITY;
	}

#elif defined FRAGMENT
	
	uniform sampler2D colortex6;
	
	vec3 gauss1D(vec2 coord,vec2 dir,float alpha,int maxIT){
		vec4 tot = vec4(0.);
		float minTC = 0.;
		#if BLOOM_BLUR_PASS == 1

			float maxTC = 0.25*resScale.x;

		#elif BLOOM_BLUR_PASS == 2

			float maxTC = 0.25*resScale.y;

		#endif

		for (int i = -maxIT;i<maxIT+1;i++){
			float weight = exp(-i*i*alpha*4.0);
			//here we take advantage of bilinear filtering for 2x less sample, as a side effect the gaussian won't be totally centered for small blurs
			vec2 spCoord = coord+dir*texelSize*(2.0*i+0.5);
			
			#if BLOOM_BLUR_PASS == 1

				tot += vec4(texture2D(colortex6,spCoord).rgb,1.0)*weight*float(spCoord.x > minTC && spCoord.x < maxTC);
			
			#elif BLOOM_BLUR_PASS == 2
				
				tot += vec4(texture2D(colortex6,spCoord).rgb,1.0)*weight*float(spCoord.y > minTC && spCoord.y < maxTC);
			
			#endif
		}
		return  tot.rgb/max(1.0,tot.a);
	}
	
	/* RENDERTARGETS:6 */
	
	void main() {
	
		vec2 texcoord = (gl_FragCoord.xy*vec2(2.0,4.0))*texelSize;
	
		#if BLOOM_BLUR_PASS == 1
	
			vec2 gaussDir = vec2(1.0,0.0);

			gl_FragData[0].rgb = vec3(0.0);
			vec2 tc2 = texcoord*vec2(2.0,1.)/2.;
			if (tc2.x < 1.0*resScale.x && tc2.y <1.0*resScale.y)
			gl_FragData[0].xyz = gauss1D(tc2/2,gaussDir,0.16,0);
			
			vec2 tc4 = texcoord*vec2(4.0,1.)/2.-vec2(0.5*resScale.x+4.0*texelSize.x,0.)*2.0;
			if (tc4.x > 0.0 && tc4.y > 0.0 && tc4.x < 1.0*resScale.x && tc4.y <1.0*resScale.y)
			gl_FragData[0].xyz = gauss1D(tc4/2,gaussDir,0.16,3);
			
			vec2 tc8 = texcoord*vec2(8.0,1.)/2.-vec2(0.75*resScale.x+8.*texelSize.x,0.)*4.0;
			if (tc8.x > 0.0 && tc8.y > 0.0 && tc8.x < 1.0*resScale.x && tc8.y <1.0*resScale.y)
			gl_FragData[0].xyz = gauss1D(tc8/2,gaussDir,0.035,6);
			
			vec2 tc16 = texcoord*vec2(8.0,1./2.)-vec2(0.875*resScale.x+12.*texelSize.x,0.)*8.0;
			if (tc16.x > 0.0 && tc16.y > 0.0 && tc16.x < 1.0*resScale.x && tc16.y <1.0*resScale.y)
			gl_FragData[0].xyz = gauss1D(tc16/2,gaussDir,0.0085,12);
			
			vec2 tc32 = texcoord*vec2(16.0,1./2.)-vec2(0.9375*resScale.x+16.*texelSize.x,0.)*16.0;
			if (tc32.x > 0.0 && tc32.y > 0.0 && tc32.x < 1.0*resScale.x && tc32.y <1.0*resScale.y)
			gl_FragData[0].xyz = gauss1D(tc32/2,gaussDir,0.002,28);
			
			vec2 tc64 = texcoord*vec2(32.0,1./2.)-vec2(0.96875*resScale.x+20.*texelSize.x,0.)*32.0;
			if (tc64.x > 0.0 && tc64.y > 0.0 && tc64.x < 1.0*resScale.x && tc64.y <1.0*resScale.y)
			gl_FragData[0].xyz = gauss1D(tc64/2,gaussDir,0.0005,60);
	
		#elif BLOOM_BLUR_PASS == 2
	
			vec2 gaussDir = vec2(0.0,1.0);

			gl_FragData[0].rgb = vec3(0.0);
			vec2 tc2 = texcoord*vec2(2.0,1.);
			if (tc2.x < 1.0*resScale.x && tc2.y <1.0*resScale.y)
			gl_FragData[0].xyz = gauss1D(texcoord/vec2(2.0,4.0),gaussDir,0.16,0);
			
			vec2 tc4 = texcoord*vec2(4.0,2.)-vec2(0.5*resScale.x+4.0*texelSize.x,0.)*4.0;
			if (tc4.x > 0.0 && tc4.y > 0.0 && tc4.x < 1.0*resScale.x && tc4.y <1.0*resScale.y)
			gl_FragData[0].xyz = gauss1D(texcoord/vec2(2.0,2.0),gaussDir,0.16,3);
			
			vec2 tc8 = texcoord*vec2(8.0,4.)-vec2(0.75*resScale.x+8.*texelSize.x,0.)*8.0;
			if (tc8.x > 0.0 && tc8.y > 0.0 && tc8.x < 1.0*resScale.x && tc8.y <1.0*resScale.y)
			gl_FragData[0].xyz = gauss1D(texcoord*vec2(1.0,2.0)/vec2(2.0,2.0),gaussDir,0.035,6);
			
			vec2 tc16 = texcoord*vec2(16.0,8.)-vec2(0.875*resScale.x+12.*texelSize.x,0.)*16.0;
			if (tc16.x > 0.0 && tc16.y > 0.0 && tc16.x < 1.0*resScale.x && tc16.y <1.0*resScale.y)
			gl_FragData[0].xyz = gauss1D(texcoord*vec2(1.0,4.0)/vec2(2.0,2.0),gaussDir,0.0085,12);
			
			vec2 tc32 = texcoord*vec2(32.0,16.)-vec2(0.9375*resScale.x+16.*texelSize.x,0.)*32.0;
			if (tc32.x > 0.0 && tc32.y > 0.0 && tc32.x < 1.0*resScale.x && tc32.y <1.0*resScale.y)
			gl_FragData[0].xyz = gauss1D(texcoord*vec2(1.0,8.0)/vec2(2.0,2.0),gaussDir,0.002,30);
			
			vec2 tc64 = texcoord*vec2(64.0,32.)-vec2(0.96875*resScale.x+20.*texelSize.x,0.)*64.0;
			if (tc64.x > 0.0 && tc64.y > 0.0 && tc64.x < 1.0*resScale.x && tc64.y <1.0*resScale.y)
			gl_FragData[0].xyz = gauss1D(texcoord*vec2(1.0,16.0)/vec2(2.0,2.0),gaussDir,0.0005,60);
			
		#endif

		gl_FragData[0].rgb = clamp(gl_FragData[0].rgb,0.0,65000.);
	}
	
	
#endif