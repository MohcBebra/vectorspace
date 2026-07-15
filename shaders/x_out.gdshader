shader_type canvas_item;

uniform float angle : hint_range(0.0, 1.0, 0.005) = 0.125;
uniform bool hover = false;

void vertex() {
	float angle_ = angle * 2. * PI;
	mat3 rotation_matrix = mat3(
		vec3(cos(angle_), -sin(angle_), 0),
		vec3(sin(angle_), cos(angle_), 0.),
		vec3(0,0,1)
	);
	VERTEX = (rotation_matrix * vec3(VERTEX, 1)).xy;
	VERTEX.x -= angle * 20.; // angle * 20
	VERTEX.y += angle * 48.; // angle * 48
}

void fragment() {
	float centered_uv = UV.x + UV.y;
	float x = step(distance(UV.x, 0.5), 0.1);
	x += step(distance(UV.y, 0.5), 0.1);
	
	COLOR.a = x + float(hover) * 0.5;
}
