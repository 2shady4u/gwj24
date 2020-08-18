shader_type canvas_item;

void fragment() {
	float chunky_time = round(TIME * 15.0) / 15.0;
	vec2 uv_a = UV;
	vec2 uv_b = UV + vec2(chunky_time, chunky_time/2.0f);
	float a = texture(TEXTURE, uv_a).r;
	float b = texture(TEXTURE, uv_b).g;
	vec3 which = vec3(1.0, 1.0, 1.0);
	if ((a > 0.5 || b > 0.5) && !(a > 0.5 && b > 0.5)) {
		which = vec3(0.0, 0.0, 0.0);
	}
	COLOR.rgb = which;
}