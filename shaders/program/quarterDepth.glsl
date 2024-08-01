#extension GL_EXT_gpu_shader4 : enable

#if defined VERTEX

uniform vec2 texelSize;
void main() {
	gl_Position = ftransform();
	vec2 scaleRatio = max(vec2(0.25), vec2(18.+258*2,258.)*texelSize);
	gl_Position.xy = (gl_Position.xy*0.5+0.5)*clamp(scaleRatio+0.01,0.0,1.0)*2.0-1.0;
}

#elif defined FRAGMENT
uniform sampler2D colortex4;
uniform sampler2D depthtex1;

uniform float near;
uniform float far;


float linZ(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
/* DRAWBUFFERS:4 */
  vec3 oldTex = texelFetch2D(colortex4, ivec2(gl_FragCoord.xy), 0).xyz;
  float newTex = texelFetch2D(depthtex1, ivec2(gl_FragCoord.xy*4), 0).x;
  if (newTex < 1.0) {
    float linearized = linZ(newTex);
    gl_FragData[0] = vec4(oldTex, linearized*linearized*65000.0);
  } else
    gl_FragData[0] = vec4(oldTex, 2.0);
}
#endif
