shader_type canvas_item;

uniform float alpha : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float spawn_time;
uniform float time;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

const vec2 CENTER = vec2(0.5, 0.5);

void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	vec2 grid = floor(UV * 4.);
	
	float smooth_gradient = smoothstep(0, 0.6, distance(UV, CENTER));
	
	if (time > 1.0)
		COLOR = vec4(c.rgb + (smooth_gradient * alpha * (time / spawn_time)), c.a);
	else
		COLOR = vec4(c.rgb + sin(time) * 2., c.a);
}
