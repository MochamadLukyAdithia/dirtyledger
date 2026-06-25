extends Camera2D

# Taruh path ke Node Sprite2D peta kamu di sini
@onready var peta_sprite: Sprite2D = $"../PetaKota"

var is_dragging: bool = false

func _ready() -> void:
	# Tunggu sampai scene benar-benar siap
	await get_tree().process_frame
	
	if peta_sprite and peta_sprite.texture:
		var map_size = peta_sprite.texture.get_size()
		
		# Jika posisi Sprite centered (di tengah), maka batasnya adalah setengah ukuran gambar
		if peta_sprite.centered:
			limit_left = int(-map_size.x / 2)
			limit_right = int(map_size.x / 2)
			limit_top = int(-map_size.y / 2)
			limit_bottom = int(map_size.y / 2)
		else:
			# Jika posisi Sprite tidak centered (mulai dari koordinat 0,0)
			limit_left = 0
			limit_right = int(map_size.x)
			limit_top = 0
			limit_bottom = int(map_size.y)
	else:
		print("Error: Node PetaKota atau Texture tidak ditemukan!")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
		else:
			is_dragging = false
			
	if event is InputEventScreenTouch:
		is_dragging = event.pressed

	if (event is InputEventMouseMotion or event is InputEventScreenDrag) and is_dragging:
		position -= event.relative / zoom
