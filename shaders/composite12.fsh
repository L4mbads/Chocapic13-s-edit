#include "/header.glsl"
//6 Vertical gaussian blurs and horizontal downsampling
#define FRAGMENT
#define BLOOM_BLUR_PASS 2
#include "/program/post/bloomBlur.glsl"