shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
uniform vec2 blood_position;
uniform float blood_radius;
uniform sampler2D noise : repeat_enable;
uniform float blood_coef : hint_range(0.0, 1.0) = 0.0;
uniform vec3 color : source_color;
uniform sampler2D web_texture;


void fragment() {
	vec4 curr_texture = texture(TEXTURE, UV);
	vec4 noise_texture = texture(noise, UV);
	vec2 uv = FRAGCOORD.xy;
	vec4 web_color = texture(web_texture, uv);
	float dist = distance(uv, blood_position);
	float is_blood = step( noise_texture.r, blood_coef);
	noise_texture.r = mix(noise_texture.r, curr_texture.r, is_blood);
	vec4 blood_output = vec4(noise_texture.rgb * color , curr_texture.a);
	COLOR = mix(curr_texture, blood_output, is_blood);
	if (dist < blood_radius) {
        COLOR = mix(web_color, blood_output, 1.0 - (dist / blood_radius));
    } else {
        COLOR = web_color;
	}

}

