shader_type spatial;

// ========================================
// BASIC WATER
// ========================================

uniform vec3 albedo : source_color = vec3(0.02, 0.20, 0.28);
uniform vec3 albedo2 : source_color = vec3(0.08, 0.45, 0.50);

uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.12;


// ========================================
// TEXTURES
// ========================================

uniform sampler2D wave;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


// ========================================
// WAVES
// ========================================

uniform vec2 wave_direction = vec2(2.0, 0.0);
uniform vec2 wave_direction2 = vec2(0.0, 1.0);

uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025;
uniform float noise_scale = 10.0;
uniform float height_scale = 0.15;


// ========================================
// DEPTH COLORS
// ========================================

uniform vec4 color_deep : source_color = vec4(0.01, 0.08, 0.12, 1.0);
uniform vec4 color_shallow : source_color = vec4(0.05, 0.35, 0.40, 1.0);

uniform float beers_law = 2.0;
uniform float depth_offset = -0.75;


// ========================================
// EDGE
// ========================================

uniform float edge_scale = 0.1;
uniform float near = 1.0;
uniform float far = 100.0;

uniform vec3 edge_color : source_color;


// ========================================
// FOAM
// ========================================

uniform vec3 foam_color : source_color = vec3(0.8, 0.95, 0.95);

uniform float foam_distance = 0.3;
uniform float foam_strength = 1.0;


// ========================================
// STYLIZED WAVES
// ========================================

uniform vec3 wave_highlight_color : source_color = vec3(0.25, 0.8, 0.8);

uniform float wave_highlight_strength : hint_range(0.0, 2.0) = 0.35;

uniform float wave_highlight_scale : hint_range(0.5, 20.0) = 5.0;


// ========================================
// REFRACTION
// ========================================

uniform float refraction_strength : hint_range(0.0, 0.2) = 0.04;


// ========================================
// TRANSPARENCY
// ========================================

uniform float water_alpha : hint_range(0.0, 1.0) = 0.65;


// ========================================
// RIPPLE SYSTEM
// ========================================

const int MAX_RIPPLES = 32;

uniform vec2 ripple_positions[MAX_RIPPLES];
uniform float ripple_times[MAX_RIPPLES];

uniform float ripple_strength : hint_range(0.0, 1.0) = 0.25;
uniform float ripple_speed = 2.0;
uniform float ripple_width = 0.08;
uniform float ripple_max_distance = 5.0;


// ========================================
// VARYING
// ========================================

varying float height;
varying vec3 world_pos;


// ========================================
// FRESNEL
// ========================================

float fresnel(float amount, vec3 normal, vec3 view)
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


// ========================================
// EDGE DEPTH
// ========================================

float edge(float depth)
{
	depth = 2.0 * depth - 1.0;

	return near * far /
		(
			far +
			depth * (near - far)
		);
}


// ========================================
// VERTEX
// ========================================

void vertex()
{
	world_pos =
		(MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	height = texture(
		wave,
		world_pos.xz / noise_scale
		+ TIME * time_scale
	).r;

	VERTEX.y += height * height_scale;
}


// ========================================
// FRAGMENT
// ========================================

void fragment()
{
	// ========================================
	// MOVING NORMAL MAPS
	// ========================================

	vec2 time =
		TIME * wave_direction * time_scale;

	vec2 time2 =
		TIME * wave_direction2 * time_scale;

	vec3 normal_blend = mix(
		texture(
			texture_normal,
			world_pos.xz + time
		).rgb,

		texture(
			texture_normal2,
			world_pos.xz + time2
		).rgb,

		0.5
	);


	// ========================================
	// RIPPLE SYSTEM
	// ========================================

	float total_ripple = 0.0;

	for (int i = 0; i < MAX_RIPPLES; i++)
	{
		if (ripple_times[i] > 0.0)
		{
			float ripple_distance =
				distance(
					world_pos.xz,
					ripple_positions[i]
				);

			float ripple_radius =
				ripple_times[i] * ripple_speed;

			// Expanding ring
			float ripple_ring =
				abs(
					ripple_distance -
					ripple_radius
				);

			float ripple =
				1.0 - smoothstep(
					0.0,
					ripple_width,
					ripple_ring
				);

			// Fade as ripple gets farther away
			float ripple_fade =
				1.0 - smoothstep(
					0.0,
					ripple_max_distance,
					ripple_distance
				);

			ripple *= ripple_fade;

			// Fade out near the end of the ripple
			float lifetime_fade =
				1.0 - smoothstep(
					2.5,
					5.0,
					ripple_times[i]
				);

			ripple *= lifetime_fade;

			total_ripple += ripple;
		}
	}

	total_ripple =
		clamp(
			total_ripple,
			0.0,
			1.0
		);

	total_ripple *= ripple_strength;


	// ========================================
	// REFRACTION NORMAL
	// ========================================

	vec3 refract_normal =
		normal_blend * 2.0 - 1.0;


	// ========================================
	// REFRACTION
	// ========================================

	vec2 refract_uv =
		SCREEN_UV +
		refract_normal.xy *
		refraction_strength;

	// Keep UV inside screen
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


	// ========================================
	// DEPTH
	// ========================================

	float depth_texture =
		texture(
			DEPTH_TEXTURE,
			SCREEN_UV
		).r * 2.0 - 1.0;

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
			* -beers_law
		);

	depth_blend =
		clamp(
			1.0 - depth_blend,
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


	// ========================================
	// DEPTH COLOR
	// ========================================

	vec3 depth_color =
		mix(
			color_shallow.rgb,
			color_deep.rgb,
			depth_blend_power
		);


	// ========================================
	// REFRACTED WATER COLOR
	// ========================================

	vec3 water_color =
		mix(
			refracted_screen,
			depth_color,
			0.35
		);


	// ========================================
	// EDGE
	// ========================================

	float z_depth =
		edge(
			texture(
				DEPTH_TEXTURE,
				SCREEN_UV
			).x
		);

	float z_pos =
		edge(FRAGCOORD.z);

	float z_dif =
		z_depth - z_pos;

	vec3 depth_color_adj =
		mix(
			edge_color,
			water_color,
			step(
				edge_scale,
				z_dif
			)
		);


	// ========================================
	// FRESNEL
	// ========================================

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


	// ========================================
	// STYLIZED HIGHLIGHT
	// ========================================

	float highlight =
		pow(
			fresnel_value,
			2.0
		);

	vec3 stylized_highlight =
		vec3(0.15, 0.65, 0.65)
		* highlight;


	// ========================================
	// FOAM
	// ========================================

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
		1.0 - smoothstep(
			0.0,
			foam_distance,
			scene_linear_depth -
			water_depth
		);

	foam_mask =
		clamp(
			foam_mask * foam_strength,
			0.0,
			1.0
		);


	// ========================================
	// STYLIZED WAVE PATTERN
	// ========================================

	vec2 highlight_uv =
		world_pos.xz /
		wave_highlight_scale;

	float wave_pattern_1 =
		texture(
			wave,
			highlight_uv +
			TIME *
			wave_direction *
			time_scale
		).r;

	float wave_pattern_2 =
		texture(
			wave,
			highlight_uv +
			TIME *
			wave_direction2 *
			time_scale
		).r;

	float wave_pattern =
		mix(
			wave_pattern_1,
			wave_pattern_2,
			0.5
		);

	float wave_highlight =
		smoothstep(
			0.55,
			0.8,
			wave_pattern
		);

	vec3 stylized_waves =
		wave_highlight_color *
		wave_highlight *
		wave_highlight_strength;


	// ========================================
	// RIPPLE VISUAL
	// ========================================

	vec3 ripple_color =
		vec3(0.5, 0.9, 0.9)
		* total_ripple;


	// ========================================
	// FINAL COLOR
	// ========================================

	ALBEDO =
		clamp(
			surface_color
			+ depth_color_adj
			+ stylized_highlight
			+ stylized_waves
			+ foam_color * foam_mask
			+ ripple_color,

			vec3(0.0),
			vec3(1.0)
		);


	// ========================================
	// TRANSPARENCY
	// ========================================

	ALPHA = water_alpha;


	// ========================================
	// MATERIAL
	// ========================================

	METALLIC = metallic;
	ROUGHNESS = roughness;

	NORMAL_MAP = normal_blend;
}