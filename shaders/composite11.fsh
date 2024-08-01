#version 120
//6 Horizontal gaussian blurs and horizontal downsampling
#define FRAGMENT
#define BLOOM_BLUR_PASS 1
#include "/program/post/bloomBlur.glsl"