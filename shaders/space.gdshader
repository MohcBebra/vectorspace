shader_type canvas_item;

uniform vec4 bg_color : source_color;
uniform vec4 fg_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D noise: repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 texture_color = texture(noise, UV + vec2(TIME * 0.001, -TIME * 0.001));
	
	COLOR = bg_color + (texture_color * fg_color);
}
