#if !defined LIB_PROJECTIONS
    #define LIB_PROJECTIONS
    
    uniform mat4 gbufferProjection;
    uniform mat4 gbufferProjectionInverse;
    uniform mat4 gbufferPreviousProjection;
    uniform mat4 gbufferModelViewInverse;
    uniform mat4 gbufferModelView;
    uniform mat4 gbufferPreviousModelView;
    uniform mat4 shadowModelView;
    uniform mat4 shadowProjection;

    #if defined SHADOW_PASS
        uniform mat4 shadowProjectionInverse;
        uniform mat4 shadowModelViewInverse;
    #endif
    
    uniform vec3 cameraPosition;
    uniform vec3 previousCameraPosition;

    uniform float near;
    uniform float far;

    #define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
    #define  projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)

    mat3 inverse(mat3 m) {
        float a00 = m[0][0], a01 = m[0][1], a02 = m[0][2];
        float a10 = m[1][0], a11 = m[1][1], a12 = m[1][2];
        float a20 = m[2][0], a21 = m[2][1], a22 = m[2][2];
    
        float b01 =  a22 * a11 - a12 * a21;
        float b11 = -a22 * a10 + a12 * a20;
        float b21 =  a21 * a10 - a11 * a20;
    
        float det = a00 * b01 + a01 * b11 + a02 * b21;
    
        return mat3(b01, (-a22 * a01 + a02 * a21), ( a12 * a01 - a02 * a11),
                    b11, ( a22 * a00 - a02 * a20), (-a12 * a00 + a02 * a10),
                    b21, (-a21 * a00 + a01 * a20), ( a11 * a00 - a01 * a10)) / det;
    }
    
    
    vec3 toClipSpace3(vec3 viewSpacePosition) {
        return projMAD(gbufferProjection, viewSpacePosition) / -viewSpacePosition.z * 0.5 + 0.5;
    }
    
    vec4 toClipSpace4(vec3 viewSpacePosition) {
        return vec4(projMAD(gl_ProjectionMatrix, viewSpacePosition),-viewSpacePosition.z);
    }
    
    vec3 toScreenSpace(vec3 p) {
    	vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
        vec3 p3 = p * 2. - 1.;
        vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
        return fragposition.xyz / fragposition.w;
    }
    
    vec3 toScreenSpaceVector(vec3 p) {
    	vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
        vec3 p3 = p * 2. - 1.;
        vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
        return normalize(fragposition.xyz);
    }
    
    vec3 toWorldSpace(vec3 p3){
        p3 = mat3(gbufferModelViewInverse) * p3 + gbufferModelViewInverse[3].xyz;
        return p3;
    }
    
    vec3 toWorldSpaceCamera(vec3 p3){
        p3 = mat3(gbufferModelViewInverse) * p3 + gbufferModelViewInverse[3].xyz;
        return p3 + cameraPosition;
    }
    
    vec3 toShadowSpace(vec3 p3){
        p3 = mat3(gbufferModelViewInverse) * p3 + gbufferModelViewInverse[3].xyz;
        p3 = mat3(shadowModelView) * p3 + shadowModelView[3].xyz;
        return p3;
    }
    
    vec3 toShadowSpaceProjected(vec3 p3){
        p3 = mat3(gbufferModelViewInverse) * p3 + gbufferModelViewInverse[3].xyz;
        p3 = mat3(shadowModelView) * p3 + shadowModelView[3].xyz;
        p3 = diagonal3(shadowProjection) * p3 + shadowProjection[3].xyz;
    
        return p3;
    }
    
    vec3 worldToView(vec3 worldPos) {
        vec4 pos = vec4(worldPos, 0.0);
        pos = gbufferModelView * pos;
        return pos.xyz;
    }

    vec3 viewToWorld(vec3 viewPos) {

        vec4 pos;
        pos.xyz = viewPos;
        pos.w = 0.0;
        pos = gbufferModelViewInverse * pos;
    
        return pos.xyz;
    }
    
    vec3 toScreenSpacePrev(vec3 p) {
        vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
        vec3 p3 = p * 2. - 1.;
        vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
        return fragposition.xyz / fragposition.w;
    }

    vec3 toClipSpace3Prev(vec3 viewSpacePosition) {
        return projMAD(gbufferPreviousProjection, viewSpacePosition) / -viewSpacePosition.z * 0.5 + 0.5;
    }


    float invLinZ (float lindepth){
        return -((2.0*near/lindepth)-far-near)/(far-near);
    }

    float linZ(float depth) {
        return (2.0 * near) / (far + near - depth * (far - near));
    }

#endif
    