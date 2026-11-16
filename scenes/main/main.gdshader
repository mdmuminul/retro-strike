shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 5.0) = 4.5;

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE * blur_amount;

	vec4 color = texture(TEXTURE, UV) * 0.2;

	color += texture(TEXTURE, UV + vec2(px.x, 0.0)) * 0.1;
	color += texture(TEXTURE, UV - vec2(px.x, 0.0)) * 0.1;
	color += texture(TEXTURE, UV + vec2(0.0, px.y)) * 0.1;
	color += texture(TEXTURE, UV - vec2(0.0, px.y)) * 0.1;

	color += texture(TEXTURE, UV + vec2(px.x, px.y)) * 0.1;
	color += texture(TEXTURE, UV + vec2(-px.x, px.y)) * 0.1;
	color += texture(TEXTURE, UV + vec2(px.x, -px.y)) * 0.1;
	color += texture(TEXTURE, UV + vec2(-px.x, -px.y)) * 0.1;

	COLOR = color;
}
