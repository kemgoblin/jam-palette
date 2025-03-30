extends Control

const color_width: int = 5
const overlay_height: int = 32

var overlay_material := preload("res://overlay_material.tres")

@export var colors: Array[Color]
var selected_color: int = 0

@export var viewport: SubViewport
@export var texture_rect: TextureRect
@export var color_container: Control
@export var color_picker: ColorPicker

var color_rects: Array[ColorRect]

@export var add_color_button: Button
@export var save_image_button: Button
@export var overlay_toggle: CheckButton


func _ready() -> void:
	get_window().min_size = Vector2i(800, 600)
	
	color_picker.color_changed.connect(on_color_picker_color_changed)
	add_color_button.pressed.connect(add_color)
	save_image_button.pressed.connect(save_palette)
	overlay_toggle.toggled.connect(toggle_overlay)
	
	color_picker.color = colors[selected_color]
	repopulate_color_rects()
	update_viewport()


func repopulate_color_rects() -> void:
	for color_rect in color_rects:
		color_rect.queue_free()
	color_rects.clear()
	
	for i in colors.size():
		var color_rect := ColorRect.new()
		color_rect.color = colors[i]
		color_rect.custom_minimum_size.y = 40
		color_rect.gui_input.connect(on_color_rect_input.bind(i))
		color_rects.append(color_rect)
		color_container.add_child(color_rect)


func update_viewport() -> void:
	var gradient := Gradient.new()
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	gradient.colors = []
	gradient.offsets = []
	for i in colors.size():
		gradient.add_point(float(i) / colors.size(), colors[i])
	
	var gradient_texture := GradientTexture1D.new()
	gradient_texture.gradient = gradient
	gradient_texture.width = colors.size() * color_width
	
	texture_rect.texture = gradient_texture
	
	viewport.size.x = gradient_texture.width
	viewport.size.y = overlay_height if overlay_toggle.button_pressed else 1
	
	update_info()


func toggle_overlay(toggled_on: bool) -> void:
	if toggled_on:
		texture_rect.material = overlay_material
	else:
		texture_rect.material = null
	update_viewport()


func save_palette() -> void:
	var image := viewport.get_texture().get_image()
	image.flip_y()
	var error := image.save_png("res://output.png")
	if error != OK:
		push_error("failed to save image")


func add_color() -> void:
	colors.append(color_picker.color)
	selected_color = colors.size() - 1
	repopulate_color_rects()
	update_viewport()


func remove_color(index: int) -> void:
	colors.remove_at(index)
	repopulate_color_rects()
	update_viewport()


func update_info() -> void:
	var image_size := viewport.size
	save_image_button.text = "Save image (%dx%d)" % [image_size.x, image_size.y]


func on_color_picker_color_changed(color: Color) -> void:
	colors[selected_color] = color
	color_rects[selected_color].color = color
	update_viewport()


func on_color_rect_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == 1:
				selected_color = index
				color_picker.color = colors[selected_color]
			if event.button_index == 2:
				remove_color(index)
