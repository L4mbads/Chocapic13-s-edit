#version 120
#extension GL_EXT_gpu_shader4 : enable

uniform vec2 texelSize;
uniform float frameTimeCounter;
uniform float viewHeight;
uniform float viewWidth;
uniform int frameCounter;
uniform int framemod8;

#include "/lib/util.glsl"
#include "/lib/resParams.glsl"