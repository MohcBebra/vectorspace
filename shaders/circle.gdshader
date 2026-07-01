shader_type canvas_item;

uniform vec3 color : source_color;
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float inner_space : hint_range(0.0, 1.0, 0.1);
uniform vec3 outring_color : source_color;
uniform float outring_space : hint_range(0.0, 1.0, 0.1) = 1.0;

void fragment() {
	vec2 uv = UV - 0.5;
	float l = length(uv);
	
	float circle = step(l, 0.5);
	float inring = step(-l, -(inner_space * 0.5));
	float outring = step(outring_space * 0.5, l);
	
	//COLOR = vec4(color, alpha * abs(outring - 1.0)) * circle * inring;
	COLOR = vec4(outring_color * outring + color * abs(outring - 1.0), alpha) * circle * inring;
}
