shader_type spatial;

uniform vec3 color : source_color;
uniform float bloom = 1.0;
varying vec4 custom;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = color;
	EMISSION = color * bloom;
	ALPHA = smoothstep(0.5, 0.0, distance(UV, vec2(0.5))) * COLOR.a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}