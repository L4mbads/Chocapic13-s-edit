/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

/* RENDERTARGETS:1 */

varying vec4 color;
varying vec4 lmtexcoord;

uniform sampler2D texture;

void main() {

	gl_FragData[0] = texture2D(texture,lmtexcoord.xy)*color;
}
