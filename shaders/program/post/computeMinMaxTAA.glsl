// Compute 3x3 min max for TAA

#if defined VERTEX

	void main() {
		gl_Position = ftransform();
		#ifdef TAA_UPSCALING
			gl_Position.xy = (gl_Position.xy*0.5+0.5)*RENDER_SCALE*2.0-1.0;
		#endif
	}
	
#elif defined FRAGMENT
	
	uniform sampler2D colortex3;
	
	/* RENDERTARGETS:0,6 */
	void main() {
	
		ivec2 center = ivec2(gl_FragCoord.xy);
		vec3 current = texelFetch2D(colortex3, center, 0).rgb;
		vec3 cMin = current;
		vec3 cMax = current;
		current = texelFetch2D(colortex3, center + ivec2(-1, -1), 0).rgb;
		cMin = min(cMin, current);
		cMax = max(cMax, current);
		current = texelFetch2D(colortex3, center + ivec2(-1, 0), 0).rgb;
		cMin = min(cMin, current);
		cMax = max(cMax, current);
		current = texelFetch2D(colortex3, center + ivec2(-1, 1), 0).rgb;
		cMin = min(cMin, current);
		cMax = max(cMax, current);
		current = texelFetch2D(colortex3, center + ivec2(0, -1), 0).rgb;
		cMin = min(cMin, current);
		cMax = max(cMax, current);
		current = texelFetch2D(colortex3, center + ivec2(0, 1), 0).rgb;
		cMin = min(cMin, current);
		cMax = max(cMax, current);
		current = texelFetch2D(colortex3, center + ivec2(1, -1), 0).rgb;
		cMin = min(cMin, current);
		cMax = max(cMax, current);
		current = texelFetch2D(colortex3, center + ivec2(1, 0), 0).rgb;
		cMin = min(cMin, current);
		cMax = max(cMax, current);
		current = texelFetch2D(colortex3, center + ivec2(1, 1), 0).rgb;
		cMin = min(cMin, current);
		cMax = max(cMax, current);
		gl_FragData[0].rgb = cMax;
		gl_FragData[1].rgb = cMin;
	}
	
#endif