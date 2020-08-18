shader_type canvas_item;

const float ABER_THRESHOLD = 0.25;
const float DISTORT_THRESHOLD = 0.5;
const float INVERT_THRESHOLD = 0.6;
const float FRAME_RATE = 20.0;

uniform float distort_amount = 1.0;

void fragment() {
	float noise_time = round(TIME * FRAME_RATE) / FRAME_RATE;
	vec2 screen_uv = SCREEN_UV;
	vec2 noise_uv = vec2(noise_time / 5.0, UV.y);
	float noise = texture(TEXTURE, noise_uv).b;
	float noise_constant_for_frame = texture(TEXTURE, vec2(noise_time / 10.0, 0.0)).b;
	screen_uv.y += noise_constant_for_frame * distort_amount * 0.25;
	if (noise * distort_amount > DISTORT_THRESHOLD) {
		screen_uv.x += noise / 10.0;
	}
	vec3 screen_c = texture(SCREEN_TEXTURE, screen_uv).rgb;
	if (noise * distort_amount > INVERT_THRESHOLD) {
		screen_c = vec3(1.0 - (screen_c.r + screen_c.g + screen_c.b) / 2.0);
	}
	else if (noise * distort_amount > ABER_THRESHOLD) {
		float aber = noise / 100.0;
		screen_c = vec3(
			texture(SCREEN_TEXTURE, screen_uv - aber).r,
			texture(SCREEN_TEXTURE, screen_uv).g,
			texture(SCREEN_TEXTURE, screen_uv + aber).b
		);
	}
	COLOR.rgb = screen_c;
}