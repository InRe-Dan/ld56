extends Control

const greatest_stat_value : int = 999

@onready var time_stat : Label = $VBoxContainer/Stats/VBoxContainer/TimePlayed/Value
@onready var devour_stat : Label = $VBoxContainer/Stats/VBoxContainer/InsectsDevoured/Value
@onready var webs_stat : Label = $VBoxContainer/Stats/VBoxContainer/WebsCreated/Value


## Called when this node enters the scene tree for the first time
func _ready() -> void:
	time_stat.text = str(min(greatest_stat_value, round(Global.time_played)))
	devour_stat.text = str(min(greatest_stat_value, Global.insects_devoured))
	webs_stat.text = str(min(greatest_stat_value, Global.webs_created))


## Main menu button pressed
func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
