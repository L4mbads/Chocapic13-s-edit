#ifdef VERTEX

	void main() {
	
		gl_Position.w = -1.0;
	}

#else if defined FRAGMENT
	
	
	/* RENDERTARGETS:3 */
	
	void main() {
		discard;
	}

#endif