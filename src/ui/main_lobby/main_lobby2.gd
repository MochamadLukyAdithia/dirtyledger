extends Node2D

@onready var energy_bar: ProgressBar = $UILayer/TopBar/HBoxContainer/EnergyBar
@onready var energy_label: Label = $UILayer/TopBar/HBoxContainer/EnergyBar/EnergyLabel
@onready var timer_label: Label = $UILayer/TopBar/HBoxContainer/EnergyBar/TimerLabel

@onready var xp_bar: ProgressBar = $UILayer/TopBar/HBoxContainer/XpBar
@onready var xp_label: Label = $UILayer/TopBar/HBoxContainer/XpBar/XpLabel

@onready var coin_label: Label = $UILayer/TopBar/HBoxContainer/CoinBar/CoinLabel

@onready var level_popup: Control = $UILayer/LevelPopup

func _ready() -> void:
	# Menghubungkan semua fungsi tombol secara otomatis saat game dimulai
	$UILayer/HBoxContainer/Control/LeaderboardButton.pressed.connect(_on_play_button_pressed)
	$UILayer/HBoxContainer/Control2/LaboratoryButton.pressed.connect(_on_laboratory_button_pressed)
	$UILayer/HBoxContainer/Control5/ExitButton.pressed.connect(_on_settings_button_pressed)
	
	# MASUKKAN INI: Menghubungkan tombol level yang ada di dalam peta
	$MapContainer/Level1Button.pressed.connect(_on_level_1_button_pressed)

#Luky ngerjain autoload xp dan coins (sama perbaiki energy tipis2)
#Luky misahin TopBar dan Bottom Menu jadi komponen (biar bisa dipanggil di beberapa scene)
func _process(_delta: float) -> void:
	# 1. Update XP Bar (Contoh jika variabelnya nanti ada di Autoload)
	if "current_xp" in EnergyManager:
		xp_bar.max_value = EnergyManager.max_xp
		xp_bar.value = EnergyManager.current_xp
		xp_label.text = "LV." + str(EnergyManager.player_level) + " (" + str(EnergyManager.current_xp) + "/" + str(EnergyManager.max_xp) + ")"
		
		# 2. Update Coin (Contoh jika variabelnya nanti ada di Autoload)
	if "coins" in EnergyManager:
		coin_label.text = str(EnergyManager.coins)
		
	# 1. Perbarui panjang Progress Bar secara visual
	energy_bar.value = EnergyManager.current_energy
	# 2. Perbarui teks angka di tengah Progress Bar
	energy_label.text = str(EnergyManager.current_energy) + " / " + str(EnergyManager.MAX_ENERGY)
	
	# 3. Perbarui hitung mundur refill energi (5 menit)
	if EnergyManager.current_energy < EnergyManager.MAX_ENERGY:
		var time_left = int(EnergyManager.next_regen_time - Time.get_unix_time_from_system())
		if time_left < 0: 
			time_left = 0
		var minutes = time_left / 60
		var seconds = time_left % 60
		timer_label.text = "Refill dalam: %02d:%02d" % [minutes, seconds]
	else:
		timer_label.text = "FULL"

# --- FUNGSI INTERAKSI TOMBOL ---

# --- MASUKKAN INI: LOGIKA TOMBOL LEVEL DI MAP ---
func _on_level_1_button_pressed() -> void:
	print("Membuka Detail Episode 1...")
	
	# Isi parameter: Nomor Ep, Judul Ep, Progress (%), Path Target Scene Episode Anda
	level_popup.buka_popup(
		"Episode 1", 
		"The Missing CFO", 
		100.0, 
		"res://src/dialogue_level/StoryIntro.tscn" # Ganti dengan path scene episode Anda
	)

func _on_play_button_pressed() -> void:
	# Tombol play utama bisa diarahkan langsung ke level terakhir atau level 1
	_masuk_ke_level("res://src/dialogue_level/StoryIntro.tscn")

func _on_laboratory_button_pressed() -> void:
	print("Membuka menu Laboratory...")

func _on_settings_button_pressed() -> void:
	print("Membuka menu Settings...")

# Fungsi bantuan agar kode tidak duplikat
func _masuk_ke_level(scene_path: String) -> void:
	if EnergyManager.use_energy(10):
		EnergyManager.next_level_path = scene_path
		get_tree().change_scene_to_file("res://src/ui/loading/loading_screen.tscn")
	else:
		print("Energi tidak cukup untuk masuk level!")
