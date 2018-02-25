local kernel = {}
 
kernel.language = "glsl" 
kernel.category = "filter"
kernel.name = "ball"
 
--kernel.isTimeDependent = true

kernel.vertexData =
{
    {
        name = "sinX",
        default = 0., 
        min = -1.,
        max = 1.,
        index = 0
    },
    {
        name = "cosX",
        default = -1., 
        min = -1.,
        max = 1.,
        index = 1
    },
    {
        name = "sinY",
        default = 0., 
        min = -1.,
        max = 1.,
        index = 2
    },
    {
        name = "cosY",
        default = -1., 
        min = -1.,
        max = 1.,
        index = 3
    }
}

 
kernel.fragment =
[[


P_DEFAULT float sphere(P_DEFAULT vec3 ro, P_DEFAULT vec3 rd)
{
	P_DEFAULT float c = dot(ro, ro) - 1.;
	P_DEFAULT float b = dot(rd, ro);
	P_DEFAULT float d = b*b - c;
	P_DEFAULT float t = -b - sqrt(abs(d));
	P_DEFAULT float st = step(0.0, min(t,d));
	return mix(-1.0, t, st);
}

P_COLOR vec3 toast (P_POSITION vec3 p)
{
    P_DEFAULT float r = sqrt(1. - abs(p.z));
    P_DEFAULT float phi = atan(abs(p.y), abs(p.x)) * 0.63661977236758134308;
    P_UV vec2 uv = vec2(r) * vec2(1.-phi, phi);
    uv = sign(p.xy) * mix(vec2(1.)-uv.yx, uv, step(0.,p.z));
    uv = .5 * uv + vec2 (.5); // [-1;1] -> [0;1]
	return texture2D(CoronaSampler0, uv).xyz;  
}


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord ) {
	P_UV vec2 uv = 1. - 2. * texCoord;
	P_DEFAULT vec3 ro = vec3(0.0, 0.0, -3.65);
	P_DEFAULT vec3 rd = normalize(vec3(uv, 3.5));
    P_DEFAULT mat2 mx = mat2(CoronaVertexUserData.y,-CoronaVertexUserData.x,CoronaVertexUserData.x,CoronaVertexUserData.y);
    P_DEFAULT mat2 my = mat2(CoronaVertexUserData.w,-CoronaVertexUserData.z,CoronaVertexUserData.z,CoronaVertexUserData.w); 
    ro.xz *= mx;rd.xz *= mx;
    ro.yz *= my;rd.yz *= my;
    P_DEFAULT float t = sphere(ro, rd);
    P_POSITION vec3 pos = normalize(ro + t * rd);
    P_COLOR vec4 bg = vec4(0.0, 0.0, 0.0, 0.0);
    P_COLOR vec4 col = vec4(toast(pos), 1.);
    P_DEFAULT float r = sqrt(dot(uv, uv));
    P_DEFAULT float f = smoothstep(0.85, 1., r);
    col.xyz = mix(col.xyz, col.xyz * 0.8, f);
    f = smoothstep(1. - 0.05, 1., r);
    col = mix(col, bg, f);
    return CoronaColorScale( mix(bg, col, step(0.0, t)) );
}
]]

return kernel