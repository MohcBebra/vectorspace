shader_type canvas_item;

uniform float value : hint_range(0.0, 1.0, 0.01) = 1.0;

void vertex() {
	VERTEX.x += 10.0;
	VERTEX.x += 10.0 * -UV.y;
}

void fragment() {
	COLOR.a = UV.x < value ? 1.0 : 0.0;
	float yellow = smoothstep(0.5, 0.75, value);
	float red = smoothstep(0.0, 0.75, value);
	COLOR.b = yellow;
	COLOR.g = red;
}
