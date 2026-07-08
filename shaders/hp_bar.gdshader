shader_type canvas_item;

uniform float value : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float skee : hint_range(0.0, 10.0, 0.1) = 0.0;
uniform bool vertical = false;

void vertex() {
	VERTEX.x += skee;
	VERTEX.x += skee * -UV.y;
}

void fragment() {
	COLOR.a = UV.x < value ? 1.0 : 0.0;
	if (vertical)
		COLOR.a = 1. - UV.y < value ? 1.0 : 0.0;
	float yellow = smoothstep(0.5, 0.75, value);
	float red = smoothstep(0.0, 0.75, value);
	COLOR.b = yellow;
	COLOR.g = red;
}
