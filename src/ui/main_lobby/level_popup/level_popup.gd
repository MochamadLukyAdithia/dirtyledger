extends Control

@onready var episode_label: Label = $PanelBg/VBoxContainer/EpisodeLabel
@onready var title_label: Label = $PanelBg/VBoxContainer/TitleLabel
@onready var progress_bar: ProgressBar = $PanelBg/VBoxContainer/ProgressBar
@onready var play_button: Button = $PanelBg/VBoxContainer/PlayButton

# Luky gimana caranya pop up ini bisa muncul di tiap button level dan sesuai titik button nya
# Variabel penyimpan target scene untuk tombol PLAY
var target_episode_scene: String = ""

func _ready() -> void:
	# Sembunyikan pop-up saat pertama kali game dimuat
	hide()
	# Hubungkan aksi tombol PLAY
	play_button.pressed.connect(_on_play_pressed)

# Fungsi untuk memunculkan pop-up dan mengisi datanya secara dinamis
func buka_popup(nomor_ep: String, judul_ep: String, progress_val: float, target_scene: String) -> void:
	episode_label.text = nomor_ep
	title_label.text = judul_ep
	progress_bar.value = progress_val
	target_episode_scene = target_scene
	show() # Munculkan UI

func _on_play_pressed() -> void:
	if target_episode_scene != "":
		# Menggunakan fungsi bawaan EnergyManager untuk potong energi dan load screen
		if EnergyManager.use_energy(10):
			EnergyManager.next_level_path = target_episode_scene
			get_tree().change_scene_to_file("res://src/ui/loading/loading_screen.tscn")
		else:
			print("Energi tidak cukup!")

# Fungsi menutup pop-up jika mengklik area luar (Opsional)
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not $PanelBg.get_global_rect().has_point(get_global_mouse_position()):
			hide()
