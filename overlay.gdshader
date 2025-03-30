shader_type canvas_item;

// https://godotshaders.com/snippet/blending-modes/
vec4 overlay(vec4 base, vec4 blend){
	vec4 limit = step(0.5, base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}

void fragment() {
	vec4 overlay_color = vec4(vec3(UV.y), 1);
	COLOR = overlay(COLOR, overlay_color);
}
