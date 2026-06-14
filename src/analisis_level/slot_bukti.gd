extends Panel

signal analisis_selesai(nama_barang)

@onready var texture_rect = $TextureRect
@onready var label_nama = $Label
@onready var btn_analisis = $button_analisis
@onready var progress_bar = $ProgressBar
@onready var timer = $Timer

var nama_item: String = ""
var sedang_analisis: bool = false
var sudah_selesai: bool = false

func set_bukti(nama: String, tex: Texture2D):
	nama_item = nama
	label_nama.text = nama
	texture_rect.texture = tex
	progress_bar.value = 0
	progress_bar.hide()
	
func mulai_proses_analisis():
	sedang_analisis = true
	btn_analisis.disabled = true
	progress_bar.show()
	timer.start(10.0) # Berjalan 10 detik
	
func _process(_delta):
	if sedang_analisis and not timer.is_stopped():
		# Update progress bar realtime (0 - 100)
		progress_bar.value = ((10.0 - timer.time_left) / 10.0) * 100
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_timer_timeout():
	sedang_analisis = false
	sudah_selesai = true
	progress_bar.hide()
	btn_analisis.disabled = false
	btn_analisis.text = "Lihat Hasil"
	analisis_selesai.emit(nama_item)
