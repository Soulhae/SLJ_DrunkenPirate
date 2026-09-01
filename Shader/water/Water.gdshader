shader_type spatial;


// ============================================================
// BASIC WATER
// ============================================================

uniform vec3 albedo : source_color = vec3(0.02, 0.20, 0.28);
uniform vec3 albedo2 : source_color = vec3(0.08, 0.45, 0.50);

uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.12;

uniform float water_alpha : hint_range(0.0, 1.0) = 0.72;


// ============================================================
// TEXTURES
// ============================================================

uniform sampler2D wave;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


// ============================================================
// GLOBAL WAVE SETTINGS
// ============================================================

uniform float wave_height : hint_range(0.0, 1.0) = 0.22;
uniform float wave_speed : hint_range(0.0, 2.0) = 0.35;


// ============================================================
// WAVE 1
// ============================================================

uniform vec2 wave_dir_1 = vec2(1.0, 0.15);
uniform float wave_length_1 = 7.0;
uniform float wave_height_1 = 0.16;
uniform float wave_speed_1 = 0.8;
uniform float wave_phase_1 = 0.0;


// ============================================================
// WAVE 2
// ============================================================

uniform vec2 wave_dir_2 = vec2(-0.35, 1.0);
uniform float wave_length_2 = 5.5;
uniform float wave_height_2 = 0.12;
uniform float wave_speed_2 = 0.65;
uniform float wave_phase_2 = 2.0;


// ============================================================
// WAVE 3
// ============================================================

uniform vec2 wave_dir_3 = vec2(0.65, -0.75);
uniform float wave_length_3 = 9.0;
uniform float wave_height_3 = 0.10;
uniform float wave_speed_3 = 0.45;
uniform float wave_phase_3 = 4.0;


// ============================================================
// WAVE 4
// ============================================================

uniform vec2 wave_dir_4 = vec2(-0.9, -0.25);
uniform float wave_length_4 = 4.0;
uniform float wave_height_4 = 0.07;
uniform float wave_speed_4 = 1.0;
uniform float wave_phase_4 = 1.5;


// ============================================================
// WAVE 5
// ============================================================

uniform vec2 wave_dir_5 = vec2(0.2, 0.95);
uniform float wave_length_5 = 12.0;
uniform float wave_height_5 = 0.09;
uniform float wave_speed_5 = 0.35;
uniform float wave_phase_5 = 5.0;


// ============================================================
// WAVE 6
// ============================================================

uniform vec2 wave_dir_6 = vec2(-0.7, 0.55);
uniform float wave_length_6 = 6.5;
uniform float wave_height_6 = 0.06;
uniform float wave_speed_6 = 0.75;
uniform float wave_phase_6 = 3.0;


// ============================================================
// WAVE 7
// ============================================================

uniform vec2 wave_dir_7 = vec2(0.85, 0.5);
uniform float wave_length_7 = 3.5;
uniform float wave_height_7 = 0.045;
uniform float wave_speed_7 = 1.15;
uniform float wave_phase_7 = 6.0;


// ============================================================
// WAVE 8
// ============================================================

uniform vec2 wave_dir_8 = vec2(-0.25, -0.95);
uniform float wave_length_8 = 10.0;
uniform float wave_height_8 = 0.055;
uniform float wave_speed_8 = 0.5;
uniform float wave_phase_8 = 7.0;


// ============================================================
// RIPPLE SYSTEM
// ============================================================

const int MAX_RIPPLES = 32;

uniform vec2 ripple_positions[MAX_RIPPLES];
uniform float ripple_times[MAX_RIPPLES];

uniform float ripple_wave_strength :
	hint_range(0.0, 1.0) = 0.22;

uniform float ripple_speed = 2.0;

uniform float ripple_width :
	hint_range(0.02, 0.5) = 0.22;

uniform float ripple_max_distance = 5.0;

uniform float ripple_color_strength :
	hint_range(0.0, 2.0) = 0.55;

uniform vec3 ripple_color : source_color =
	vec3(0.55, 0.95, 0.95);


// ============================================================
// RIPPLE EXTRA WAVES
// ============================================================

uniform float ripple_secondary_strength :
	hint_range(0.0, 1.0) = 0.35;

uniform float ripple_tertiary_strength :
	hint_range(0.0, 1.0) = 0.18;


// ============================================================
// DEPTH COLORS
// ============================================================

uniform vec4 color_deep : source_color =
	vec4(0.01, 0.08, 0.12, 1.0);

uniform vec4 color_shallow : source_color =
	vec4(0.05, 0.35, 0.40, 1.0);

uniform float beers_law = 2.0;
uniform float depth_offset = -0.75;


// ============================================================
// EDGE
// ============================================================

uniform float edge_scale = 0.1;
uniform float near = 1.0;
uniform float far = 100.0;

uniform vec3 edge_color : source_color =
	vec3(0.15, 0.55, 0.58);


// ============================================================
// FOAM
// ============================================================

uniform vec3 foam_color : source_color =
	vec3(0.8, 0.95, 0.95);

uniform float foam_distance = 0.3;
uniform float foam_strength = 1.0;


// ============================================================
// STYLIZED WAVE CRESTS
// ============================================================

uniform vec3 wave_highlight_color : source_color =
	vec3(0.25, 0.8, 0.8);

uniform float wave_highlight_strength :
	hint_range(0.0, 2.0) = 0.42;

uniform float wave_crest_threshold :
	hint_range(0.0, 1.0) = 0.68;


// ============================================================
// REFRACTION
// ============================================================

uniform float refraction_strength :
	hint_range(0.0, 0.2) = 0.035;


// ============================================================
// VARYING
// ============================================================

varying vec3 world_pos;
varying float water_height;
varying float ripple_visual;


// ============================================================
// FRESNEL
// ============================================================

float fresnel(
	float amount,
	vec3 normal,
	vec3 view
)
{
	return pow(
		1.0 - clamp(
			dot(
				normalize(normal),
				normalize(view)
			),
			0.0,
			1.0
		),
		amount
	);
}


// ============================================================
// EDGE DEPTH
// ============================================================

float edge(float depth)
{
	depth = 2.0 * depth - 1.0;

	return near * far /
		(
			far +
			depth * (near - far)
		);
}


// ============================================================
// DIRECTIONAL WAVE
// ============================================================

float directional_wave(
	vec2 position,
	vec2 direction,
	float wavelength,
	float amplitude,
	float speed,
	float phase
)
{
	direction = normalize(direction);

	float frequency =
		6.2831853 / wavelength;

	float wave_position =
		dot(position, direction);

	float movement =
		TIME *
		speed *
		wave_speed;

	return sin(
		wave_position *
		frequency +
		movement +
		phase
	) * amplitude;
}


// ============================================================
// RIPPLE WAVE
// ============================================================

float get_ripple_wave(
	vec2 position,
	out float visual_strength
)
{
	float ripple_height = 0.0;

	visual_strength = 0.0;


	for (int i = 0; i < MAX_RIPPLES; i++)
	{
		if (ripple_times[i] > 0.0)
		{
			float distance_to_ripple =
				distance(
					position,
					ripple_positions[i]
				);


			if (distance_to_ripple <= ripple_max_distance)
			{
				// ========================================
				// RIPPLE AGE
				// ========================================

				float radius =
					ripple_times[i] *
					ripple_speed;


				// ========================================
				// MAIN CREST
				// ========================================

				float ring_distance =
					distance_to_ripple -
					radius;


				float main_ring =
					1.0 -
					smoothstep(
						0.0,
						ripple_width,
						abs(ring_distance)
					);


				// ========================================
				// SECONDARY CREST
				// ========================================

				float second_radius =
					radius -
					0.35;


				float second_distance =
					distance_to_ripple -
					second_radius;


				float second_ring =
					1.0 -
					smoothstep(
						0.0,
						ripple_width * 1.7,
						abs(second_distance)
					);


				second_ring *=
					ripple_secondary_strength;


				// ========================================
				// TERTIARY CREST
				// ========================================

				float third_radius =
					radius -
					0.7;


				float third_distance =
					distance_to_ripple -
					third_radius;


				float third_ring =
					1.0 -
					smoothstep(
						0.0,
						ripple_width * 2.2,
						abs(third_distance)
					);


				third_ring *=
					ripple_tertiary_strength;


				// ========================================
				// DISTANCE FADE
				// ========================================

				float distance_fade =
					1.0 -
					smoothstep(
						0.0,
						ripple_max_distance,
						distance_to_ripple
					);


				// ========================================
				// LIFETIME FADE
				// ========================================

				float lifetime_fade =
					1.0 -
					smoothstep(
						2.5,
						5.0,
						ripple_times[i]
					);


				// ========================================
				// MAIN WAVE
				// ========================================

				float main_wave =
					sin(
						ring_distance * 7.0
					);


				// ========================================
				// SECONDARY WAVE
				// ========================================

				float secondary_wave =
					sin(
						ring_distance * 12.0
					)
					*
					0.35;


				// ========================================
				// COMBINED RIPPLE
				// ========================================

				float combined_ring =
					main_ring +
					second_ring +
					third_ring;


				float ripple_wave =
					(
						main_wave +
						secondary_wave
					)
					*
					combined_ring;


				// ========================================
				// ACTUAL WATER DISPLACEMENT
				// ========================================

				ripple_height +=
					ripple_wave *
					distance_fade *
					lifetime_fade *
					ripple_wave_strength;


				// ========================================
				// COLOUR MASK
				// ========================================

				visual_strength +=
					combined_ring *
					distance_fade *
					lifetime_fade;
			}
		}
	}


	return ripple_height;
}


// ============================================================
// VERTEX
// ============================================================

void vertex()
{
	world_pos =
		(MODEL_MATRIX *
		vec4(VERTEX, 1.0)).xyz;


	vec2 position =
		world_pos.xz;


	// ========================================================
	// MULTIPLE INTERFERING WAVES
	// ========================================================

	float w1 = directional_wave(
		position,
		wave_dir_1,
		wave_length_1,
		wave_height_1,
		wave_speed_1,
		wave_phase_1
	);


	float w2 = directional_wave(
		position,
		wave_dir_2,
		wave_length_2,
		wave_height_2,
		wave_speed_2,
		wave_phase_2
	);


	float w3 = directional_wave(
		position,
		wave_dir_3,
		wave_length_3,
		wave_height_3,
		wave_speed_3,
		wave_phase_3
	);


	float w4 = directional_wave(
		position,
		wave_dir_4,
		wave_length_4,
		wave_height_4,
		wave_speed_4,
		wave_phase_4
	);


	float w5 = directional_wave(
		position,
		wave_dir_5,
		wave_length_5,
		wave_height_5,
		wave_speed_5,
		wave_phase_5
	);


	float w6 = directional_wave(
		position,
		wave_dir_6,
		wave_length_6,
		wave_height_6,
		wave_speed_6,
		wave_phase_6
	);


	float w7 = directional_wave(
		position,
		wave_dir_7,
		wave_length_7,
		wave_height_7,
		wave_speed_7,
		wave_phase_7
	);


	float w8 = directional_wave(
		position,
		wave_dir_8,
		wave_length_8,
		wave_height_8,
		wave_speed_8,
		wave_phase_8
	);


	float combined_waves =
		w1 + w2 + w3 + w4 +
		w5 + w6 + w7 + w8;


	// ========================================================
	// RIPPLE
	// ========================================================

	float ripple_strength_visual = 0.0;


	float ripple_height =
		get_ripple_wave(
			position,
			ripple_strength_visual
		);


	ripple_visual =
		clamp(
			ripple_strength_visual,
			0.0,
			1.0
		);


	// ========================================================
	// FINAL HEIGHT
	// ========================================================

	water_height =
		combined_waves;


	VERTEX.y +=
		combined_waves *
		wave_height;


	VERTEX.y +=
		ripple_height;
}


// ============================================================
// FRAGMENT
// ============================================================

void fragment()
{
	// ========================================================
	// MOVING NORMALS
	// ========================================================

	vec2 normal_time_1 =
		TIME *
		vec2(0.7, 0.2) *
		0.025;


	vec2 normal_time_2 =
		TIME *
		vec2(-0.2, 0.8) *
		0.018;


	vec3 normal_blend =
		mix(
			texture(
				texture_normal,
				world_pos.xz +
				normal_time_1
			).rgb,

			texture(
				texture_normal2,
				world_pos.xz +
				normal_time_2
			).rgb,

			0.5
		);


	// ========================================================
	// RIPPLE COLOUR
	// ========================================================

	float soft_ripple =
		smoothstep(
			0.0,
			0.35,
			ripple_visual
		);


	soft_ripple =
		pow(
			soft_ripple,
			0.7
		);


	vec3 ripple_visual_color =
		ripple_color *
		soft_ripple *
		ripple_color_strength;


	// ========================================================
	// REFRACTION
	// ========================================================

	vec3 refract_normal =
		normal_blend *
		2.0 -
		1.0;


	vec2 refract_uv =
		SCREEN_UV +
		refract_normal.xy *
		refraction_strength;


	refract_uv =
		clamp(
			refract_uv,
			vec2(0.001),
			vec2(0.999)
		);


	vec3 refracted_screen =
		texture(
			SCREEN_TEXTURE,
			refract_uv
		).rgb;


	// ========================================================
	// DEPTH
	// ========================================================

	float depth_texture =
		texture(
			DEPTH_TEXTURE,
			SCREEN_UV
		).r *
		2.0 -
		1.0;


	float depth =
		PROJECTION_MATRIX[3][2] /
		(
			depth_texture +
			PROJECTION_MATRIX[2][2]
		);


	float depth_blend =
		exp(
			(
				depth +
				VERTEX.z +
				depth_offset
			)
			*
			-beers_law
		);


	depth_blend =
		clamp(
			1.0 -
			depth_blend,
			0.0,
			1.0
		);


	float depth_blend_power =
		clamp(
			pow(
				depth_blend,
				2.5
			),
			0.0,
			1.0
		);


	// ========================================================
	// DEPTH COLOUR
	// ========================================================

	vec3 depth_color =
		mix(
			color_shallow.rgb,
			color_deep.rgb,
			depth_blend_power
		);


	// ========================================================
	// WATER COLOUR
	// ========================================================

	vec3 water_color =
		mix(
			refracted_screen,
			depth_color,
			0.35
		);


	// ========================================================
	// EDGE
	// ========================================================

	float z_depth =
		edge(
			texture(
				DEPTH_TEXTURE,
				SCREEN_UV
			).x
		);


	float z_pos =
		edge(
			FRAGCOORD.z
		);


	float z_dif =
		z_depth -
		z_pos;


	vec3 depth_color_adj =
		mix(
			edge_color,
			water_color,
			step(
				edge_scale,
				z_dif
			)
		);


	// ========================================================
	// FRESNEL
	// ========================================================

	float fresnel_value =
		fresnel(
			3.0,
			NORMAL,
			VIEW
		);


	vec3 surface_color =
		mix(
			albedo,
			albedo2,
			fresnel_value
		);


	// ========================================================
	// WAVE CRESTS
	// ========================================================

	float crest_value =
		smoothstep(
			wave_crest_threshold,
			1.0,
			water_height
		);


	// Add some variation so every crest isn't identical.
	float crest_texture =
		texture(
			wave,
			world_pos.xz * 0.35
		).r;


	crest_value *=
		mix(
			0.65,
			1.0,
			crest_texture
		);


	vec3 stylized_waves =
		wave_highlight_color *
		crest_value *
		wave_highlight_strength;


	// ========================================================
	// FOAM
	// ========================================================

	float scene_depth =
		texture(
			DEPTH_TEXTURE,
			SCREEN_UV
		).r;


	float scene_linear_depth =
		PROJECTION_MATRIX[3][2] /
		(
			scene_depth * 2.0
			- 1.0
			+ PROJECTION_MATRIX[2][2]
		);


	float water_depth =
		-VERTEX.z;


	float foam_mask =
		1.0 -
		smoothstep(
			0.0,
			foam_distance,
			scene_linear_depth -
			water_depth
		);


	foam_mask =
		clamp(
			foam_mask *
			foam_strength,
			0.0,
			1.0
		);


	// ========================================================
	// FINAL COLOUR
	// ========================================================

	ALBEDO =
		clamp(

			surface_color

			+ depth_color_adj

			+ stylized_waves

			+ foam_color *
			foam_mask

			+ ripple_visual_color,

			vec3(0.0),
			vec3(1.0)
		);


	// ========================================================
	// TRANSPARENCY
	// ========================================================

	ALPHA =
		water_alpha;


	// ========================================================
	// MATERIAL
	// ========================================================

	METALLIC =
		metallic;

	ROUGHNESS =
		roughness;

	NORMAL_MAP =
		normal_blend;
}