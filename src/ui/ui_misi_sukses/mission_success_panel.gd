extends Panel

signal lanjut_ke_analisis
var bisa_diklik: bool = false

func _ready() -> void:
	hide()
	modulate.a = 0
	scale = Vector2(0.9, 0.9)

func muncul() -> void:
	show()
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	bisa_diklik = true
	
	var t_blink = create_tween().set_loops()
	t_blink.tween_property($VBoxContainer/Label3, "modulate:a", 0.3, 0.8)
	t_blink.tween_property($VBoxContainer/Label3, "modulate:a", 1.0, 0.8)

# === PERBAIKAN DI SINI: Menggunakan _gui_input agar tidak konflik dengan klik di luar panel ===
func _gui_input(event: InputEvent) -> void:
	if bisa_diklik and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Accept event agar input klik dihentikan di sini dan tidak tembus ke objek lain
			accept_event() 
			lanjutkan()

func lanjutkan() -> void:
	bisa_diklik = false
	print("DEBUG: Sinyal berpindah ke Tahap Analisis Bukti dipicu.")
	
	# === PERBAIKAN DI SINI: Menggunakan format standard Godot 4 ===
	lanjut_ke_analisis.emit()
