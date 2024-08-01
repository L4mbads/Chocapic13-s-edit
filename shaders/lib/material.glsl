struct Material {
	
}

float smoothnessToRoughness(float smoothness) {
	float r = (1.0 - smoothness);
	return r*r;
}