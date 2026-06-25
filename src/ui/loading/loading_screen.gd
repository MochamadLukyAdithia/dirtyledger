extends Control

@onready var loading_bar: ProgressBar = $VBoxContainer/LoadingBar
@onready var status_label: Label = $VBoxContainer/StatusLabel

var target_scene_path: String = ""
var progress: Array = []

func _ready() -> void:
	# Ambil path level yang disimpan sementara di Autoload EnergyManager
	target_scene_path = EnergyManager.next_level_path
	
	if target_scene_path != "":
		# Memulai proses memuat level di latar belakang (background thread)
		ResourceLoader.load_threaded_request(target_scene_path)
	else:
		status_label.text = "Error: Path level tidak ditemukan!"

func _process(_delta: float) -> void:
	if target_scene_path == "":
		return
		
	# Cek status kemajuan loading aset
	var status = ResourceLoader.load_threaded_get_status(target_scene_path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# progress[0] berisi nilai rentang 0.0 sampai 1.0, ubah ke skala 100
			loading_bar.value = progress[0] * 100
			
		ResourceLoader.THREAD_LOAD_LOADED:
			loading_bar.value = 100
			status_label.text = "Selesai! Membuka Level..."
			
			# Ambil resource scene yang sudah selesai dimuat, lalu ganti scene
			var new_scene = ResourceLoader.load_threaded_get(target_scene_path)
			get_tree().change_scene_to_packed(new_scene)
			
		ResourceLoader.THREAD_LOAD_FAILED:
			status_label.text = "Gagal memuat level!"
