/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

//#define SHADOW_FRUSTRUM_CULLING   // If enabled, removes most of the blocks during shadow rendering that would not cast shadows on the player field of view. Improves performance but can be sometimes incorrect and causes flickering shadows on distant occluders
#define WAVY_PLANTS
#define WAVY_STRENGTH 1.0 //[0.1 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define WAVY_SPEED 1.0 //[0.001 0.01 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 1.0 1.25 1.5 2.0 3.0 4.0]
#define SHADOW_MAP_BIAS 0.8
//#define SHADOW_DISABLE_ALPHA_MIPMAPS // Disables mipmaps on the transparency of alpha-tested things like foliage, may cost a few fps in some cases
//#define Stochastic_Transparent_Shadows // Highly recommanded to enable SHADOW_DISABLE_ALPHA_MIPMAPS with it. Uses noise to simulate transparent objects' shadows (not colored). It is also recommended to increase Min_Shadow_Filter_Radius with this.


#define SHADOW_PASS


varying vec2 texcoord;

#ifdef VERTEX

uniform vec3 sunVec;
uniform float sunElevation;
uniform float lightSign;
uniform float cosFov;
uniform vec3 shadowViewDir;
uniform vec3 shadowCamera;
uniform vec3 shadowLightVec;
uniform float shadowMaxProj;

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;


#include "/lib/shadow.glsl"
#include "/lib/projections.glsl"

const float PI48 = 150.796447372*WAVY_SPEED;
float pi2wt = PI48*frameTimeCounter;

vec2 calcWave(in vec3 pos) {

    float magnitude = abs(sin(dot(vec4(frameTimeCounter, pos),vec4(1.0,0.005,0.005,0.005)))*0.5+0.72)*0.013;
	vec2 ret = (sin(pi2wt*vec2(0.0063,0.0015)*4. - pos.xz + pos.y*0.05)+0.1)*magnitude;

    return ret;
}

vec3 calcMovePlants(in vec3 pos) {
    vec2 move1 = calcWave(pos );
	float move1y = -length(move1);
   return vec3(move1.x,move1y,move1.y)*5.*WAVY_STRENGTH/255.0;
}

vec3 calcWaveLeaves(in vec3 pos, in float fm, in float mm, in float ma, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5) {

    float magnitude = abs(sin(dot(vec4(frameTimeCounter, pos),vec4(1.0,0.005,0.005,0.005)))*0.5+0.72)*0.013;
	vec3 ret = (sin(pi2wt*vec3(0.0063,0.0224,0.0015)*1.5 - pos))*magnitude;

    return ret;
}

vec3 calcMoveLeaves(in vec3 pos, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5, in vec3 amp1, in vec3 amp2) {
    vec3 move1 = calcWaveLeaves(pos      , 0.0054, 0.0400, 0.0400, 0.0127, 0.0089, 0.0114, 0.0063, 0.0224, 0.0015) * amp1;
    return move1*5.*WAVY_STRENGTH/255.;
}
bool intersectCone(float coneHalfAngle, vec3 coneTip , vec3 coneAxis, vec3 rayOrig, vec3 rayDir, float maxZ)
{
  vec3 co = rayOrig - coneTip;
  float prod = dot(normalize(co),coneAxis);
  if (prod <= -coneHalfAngle) return true;   //In view frustrum

  float a = dot(rayDir,coneAxis)*dot(rayDir,coneAxis) - coneHalfAngle*coneHalfAngle;
  float b = 2. * (dot(rayDir,coneAxis)*dot(co,coneAxis) - dot(rayDir,co)*coneHalfAngle*coneHalfAngle);
  float c = dot(co,coneAxis)*dot(co,coneAxis) - dot(co,co)*coneHalfAngle*coneHalfAngle;

  float det = b*b - 4.*a*c;
  if (det < 0.) return false;    // No intersection with either forward cone and backward cone

  det = sqrt(det);
  float t2 = (-b + det) / (2. * a);
  if (t2 <= 0.0 || t2 >= maxZ) return false;  //Idk why it works

  return true;
}

void main() {

	vec3 position = mat3(gl_ModelViewMatrix) * vec3(gl_Vertex) + gl_ModelViewMatrix[3].xyz;
  //Check if the vertice is going to cast shadows
  #ifdef SHADOW_FRUSTRUM_CULLING
  if (intersectCone(cosFov, shadowCamera, shadowViewDir, position, -shadowLightVec, shadowMaxProj)) {
  #endif
    #ifdef WAVY_PLANTS
  	bool istopv = gl_MultiTexCoord0.t < mc_midTexCoord.t;
    if ((mc_Entity.x == 10001&&istopv) && length(position.xy) < 24.0) {
      vec3 worldpos = mat3(shadowModelViewInverse) * position + shadowModelViewInverse[3].xyz;
      worldpos.xyz += calcMovePlants(worldpos.xyz + cameraPosition)*gl_MultiTexCoord1.y;
      position = mat3(shadowModelView) * worldpos + shadowModelView[3].xyz ;
    }

    if ((mc_Entity.x == 10003) && length(position.xy) < 24.0) {
      vec3 worldpos = mat3(shadowModelViewInverse) * position + shadowModelViewInverse[3].xyz;
      worldpos.xyz += calcMoveLeaves(worldpos.xyz + cameraPosition, 0.0040, 0.0064, 0.0043, 0.0035, 0.0037, 0.0041, vec3(1.0,0.2,1.0), vec3(0.5,0.1,0.5))*gl_MultiTexCoord1.y;
      position = mat3(shadowModelView) * worldpos + shadowModelView[3].xyz ;
    }
  #endif
	gl_Position = BiasShadowProjection(toClipSpace4(position));
	gl_Position.z /= 6.0;

	texcoord.xy = gl_MultiTexCoord0.xy;
	if(mc_Entity.x == 8 || mc_Entity.x == 9) gl_Position.w = -1.0;
  #ifdef SHADOW_FRUSTRUM_CULLING
  }
  else
  gl_Position.xyzw = vec4(0.0,0.0,1e30,0.0);  //Degenerates the triangle
  #endif
}

#else if defined FRAGMENT
    
    #extension GL_ARB_shader_texture_lod : enable
    
    uniform sampler2D tex;

    #include "/lib/colorDither.glsl"
    
    
    void main() {
        gl_FragData[0] = texture2D(tex,texcoord.xy);

    	#ifdef SHADOW_DISABLE_ALPHA_MIPMAPS
    	   gl_FragData[0].a = texture2DLod(tex,texcoord.xy,0).a;
    	#endif

        #ifdef Stochastic_Transparent_Shadows
    	   gl_FragData[0].a = float(gl_FragData[0].a >= blueNoise());
        #endif
    }
    
#endif