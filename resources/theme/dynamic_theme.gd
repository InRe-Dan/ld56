class_name DynamicTheme extends Theme

const canon_background = Color("000000")
const canon_border = Color("FFFFFF")
const canon_control_edge = Color("333333")
const canon_disabled_trim = Color("222222")

const canon_primary = Color("FF0000")
const canon_secondary = Color("FFAA00")
const canon_ternary = Color("FFFF00")

var color_map : Array[ColorPair]

@export var background : Color
@export var border : Color
@export var control_edge : Color
@export var disabled_trim : Color

@export var primary : Color
@export var secondary : Color
@export var ternary : Color:
	set(x):
		ternary = x
		init() 

func init() -> void:
	var dict : Dictionary = {
		canon_background: background,
		canon_border: border,
		canon_control_edge: control_edge,
		canon_disabled_trim: disabled_trim,
		canon_primary: primary,
		canon_secondary: secondary,
		canon_ternary: ternary
	}
	for key in dict.keys():
		color_map.append(ColorPair.new(key, dict[key]))
		print(color_map.back().target)
		
	for type : StringName in get_stylebox_type_list():
		for name : StringName in get_stylebox_list(type):
			var box : StyleBox = get_stylebox(name, type)
			if box is StyleBoxFlat:
				recolor_styleboxflat(box)
				print(box.bg_color)
			elif box is StyleBoxTexture:
				print("Before: ", box.texture.gradient.colors)
				recolor_styleboxtexture(box)
				print("After: ", box.texture.gradient.colors)
			set_stylebox(name, type, box)

	

func map_color(c : Color) -> Color:
	for pair : ColorPair in color_map:
		if Vector3(pair.source.r, pair.source.g, pair.source.b).is_equal_approx(Vector3(c.r, c.g, c.b)):
			print("Recognized: ", c)
			print(pair.target)
			return Color(pair.target.r, pair.target.g, pair.target.b, c.a)
	print("Unrecognized colour: ", c)
	return c

func recolor_styleboxflat(box : StyleBoxFlat) -> void:
	box.bg_color = map_color(box.bg_color)
	
func recolor_styleboxtexture(box : StyleBoxTexture) -> void:
	if box.texture is GradientTexture2D:
		recolor_gradient2d(box.texture as GradientTexture2D)
	elif box.texture is GradientTexture1D:
		recolor_gradient1D(box.texutre as GradientTexture1D)

func recolor_gradient2d(texture : GradientTexture2D):
	var gradient : Gradient = texture.gradient
	recolor_gradient(gradient)

func recolor_gradient1D(texture : GradientTexture1D):
	var gradient : Gradient = texture.gradient
	recolor_gradient(gradient)

func recolor_gradient(gradient : Gradient) -> void:
	var colors : PackedColorArray = gradient.colors
	for i in range(colors.size()):
		colors[i] = map_color(colors[i])
	gradient.colors = colors
