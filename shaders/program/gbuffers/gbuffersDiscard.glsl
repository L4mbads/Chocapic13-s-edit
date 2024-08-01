#ifdef VERTEX

	#extension GL_EXT_gpu_shader4 : enable
	
	void main() {
	
		gl_Position.w = -1.0;
	}

#else if defined FRAGMENT
	
	
	/* DRAWBUFFERS:3 */
	
	void main() {
		discard;
	}

#endif