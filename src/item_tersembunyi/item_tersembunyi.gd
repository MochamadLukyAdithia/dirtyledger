extends Area2D

# Signal untuk memberi tahu stage utama kalau barang ini berhasil diklik
signal barang_ditemukan(nama_barang)

@export var nama_barang: String = "Topi"

func _ready() -> void:
	# Mengaktifkan deteksi input mouse pada Area2D
	input_pickable = true

# Fungsi bawaan Godot untuk mendeteksi interaksi input pada Area2D
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	# Deteksi klik kiri mouse atau sentuhan layar
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_di_klik()

func _di_klik() -> void:
	print("Pemain menemukan: ", nama_barang)
	
	# Kirim sinyal ke sistem gameplay utama
	barang_ditemukan.emit(nama_barang)
	
	# Efek visual sederhana (misal langsung menghilang)
	queue_free()
