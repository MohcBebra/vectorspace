shader_type canvas_item;

uniform vec3 bg_color : source_color;
uniform vec3 line_color : source_color;
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float angle = 0.0;
uniform float width : hint_range(0.0, 1.0, 0.01) = 0.1;

void fragment() {
	vec2 uv = UV - 0.5;
	float l = length(uv);
	
	float circle = step(l, 0.5);
	float ring = step(-l, -(0.95 * 0.5)) * circle;
	float cross_h = step(distance(uv.x, 0.), 0.01);
	float cross_v = step(distance(uv.y, 0.), 0.01);
	float static_alpha = (ring + cross_h + cross_v) * alpha;
	
	COLOR.a = static_alpha;
	
	vec2 uv_centered = UV * 2. - 1.;
	vec2 p1 = vec2(0., 0.);
	vec2 p2 = vec2(cos(-angle), sin(-angle));
	vec2 p12 = p2 - p1;
	
	float d = dot(p12, uv_centered - p1) / length(p12);
	vec2 p4 = normalize(p12) * d;
	
	float line = 0.0;
	if (d < length(p12) && length(p4 - p2) < length(p12))
		line = length(p4 - uv_centered) < width ? 1.0 : 0.0;
	line *= circle;
	
	COLOR.a += line;
	COLOR.rgb = line_color * line + bg_color;
	//COLOR += vec4(line_color, line);
}
