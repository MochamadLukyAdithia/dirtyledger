extends Node2D

var bukti_ditemukan : Array[String] = []
var total_bukti = 3
var daftar_misi = ["Kwitansi", "Kunci", "Flashdisk"]

@onready var mission_ui = $CanvasLayer/MissionSuccessPanel 
@onready var label_container = $UI/InventoryBar/LabelContainer 

@onready var obj1_node = $obj1
@onready var obj2_node = $obj2
@onready var obj3_node = $obj3

func _ready():
	match Global.current_chapter:
		"chapter_1":
			print("Memuat Level Pencarian Bukti untuk Chapter 1")
		"chapter_2":
			print("Memuat Level Pencarian Bukti untuk Chapter 2")
		"chapter_3":
			print("Memuat Level Pencarian Bukti untuk Chapter 3")
		_:
			print("Chapter tidak dikenal, menggunakan aset default.")

	buat_daftar_teks_misi()
	
	if mission_ui:
		mission_ui.lanjut_ke_analisis.connect(_on_ke_tahap_berikutnya)
		print("DEBUG: Sinyal 'lanjut_ke_analisis' berhasil dihubungkan.")
	else:
		push_error("ERROR: Node MissionSuccessPanel tidak ditemukan!")

func _on_ke_tahap_berikutnya():
	print("DEBUG: Fungsi _on_ke_tahap_berikutnya() AKTIF dijalankan!")
	Global.bukti_ditemukan = bukti_ditemukan
	
	if Global.current_chapter == "chapter_1":
		print("DEBUG: Mengalihkan Chapter 1 ke Scene Dialog Guide.")
		Global.current_dialog_status = "guide"
		get_tree().call_deferred("change_scene_to_file", "res://src/dialogue_level/StoryIntro.tscn")
	else:
		print("DEBUG: Mengalihkan Chapter non-1 langsung ke Analisis Utama.")
		get_tree().call_deferred("change_scene_to_file", "res://src/analisis_level/analisis_utama.tscn")

func buat_daftar_teks_misi():
	for child in label_container.get_children():
		child.queue_free()
	
	for nama in daftar_misi:
		var label_baru = Label.new()
		label_baru.text = nama
		label_baru.name = "Label_" + nama
		label_baru.add_theme_constant_override("margin_right", 30)
		label_container.add_child(label_baru)

func tambah_bukti(nama_bukti):
	if not bukti_ditemukan.has(nama_bukti):
		bukti_ditemukan.append(nama_bukti)
		print("Bukti didapat: ", nama_bukti)
		
		var label_teks = label_container.get_node_or_null("Label_" + nama_bukti)
		if label_teks:
			label_teks.modulate.a = 0.3 

		if bukti_ditemukan.size() == total_bukti:
			tampilkan_mission_success()

func tampilkan_mission_success():
	if mission_ui:
		mission_ui.muncul()
	else:
		push_error("ERROR: mission_ui null saat ingin menampilkan panel sukses.")

func _on_obj_1_pressed() -> void:
	obj1_node.hide()
	tambah_bukti("Kwitansi")

func _on_obj_2_pressed() -> void:
	obj2_node.hide()
	tambah_bukti("Kunci")

func _on_obj_3_pressed() -> void:
	obj3_node.hide()
	tambah_bukti("Flashdisk")
