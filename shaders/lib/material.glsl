//encode normal in two channels (xy),torch(z) and sky lightmap (w)
vec4 encode (vec3 n, vec2 lightmaps)
{
	n.xy = n.xy / dot(abs(n), vec3(1.0));
	n.xy = n.z <= 0.0 ? (1.0 - abs(n.yx)) * sign(n.xy) : n.xy;
    vec2 encn = n.xy * 0.5 + 0.5;
	
    return vec4(encn,vec2(lightmaps.x,lightmaps.y));
}

vec3 decode (vec2 encn)
{
    vec3 n = vec3(0.0);
    encn = encn * 2.0 - 1.0;
    n.xy = abs(encn);
    n.z = 1.0 - n.x - n.y;
    n.xy = n.z <= 0.0 ? (1.0 - n.yx) * sign(encn) : encn;
    return normalize(n.xyz);
}


//espens normals encoding end

#ifdef MC_NORMAL_MAP
vec3 applyBump(mat3 tbnMatrix, vec3 bump)
{

		float bumpmult = 1.0-wetness*0.50;

		bump = bump * vec3(bumpmult, bumpmult, bumpmult) + vec3(0.0f, 0.0f, 1.0f - bumpmult);

		return normalize(bump*tbnMatrix);
}
#endif

//encoding by jodie
float encodeVec2(vec2 a){
    const vec2 constant1 = vec2( 1., 256.) / 65535.;
    vec2 temp = floor( a * 255. );
	return temp.x*constant1.x+temp.y*constant1.y;
}

float encodeVec2(float x,float y){
    return encodeVec2(vec2(x,y));
}

vec2 decodeVec2(float a){
    const vec2 constant1 = 65535. / vec2( 256., 65536.);
    const float constant2 = 256. / 255.;
    return fract( a * constant1 ) * constant2 ;
}

float smoothnessToRoughness(float smoothness) {
	float r = (1.0 - smoothness);
	return r*r;
}