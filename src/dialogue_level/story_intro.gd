extends Control

@onready var portrait_node: TextureRect = $CharPortrait
@onready var name_label: Label = $DialoguePanel/CharName
@onready var text_label: RichTextLabel = $DialoguePanel/DialogueText

# Sesuai dengan hierarchy di screenshot kamu, namanya adalah $Background
@onready var background_node: TextureRect = $Background

var all_chapters_data: Dictionary = {}
var story_data: Array = []
var current_dialogue_index: int = 0
var status_dialog: String = "intro"

# Sinyal untuk memberi tahu meja analisis kalau dialog intro analisis sudah selesai
signal dialog_selesai

func _ready() -> void:
	portrait_node.hide()
	load_all_chapters_from_json("res://src/data/all_chapters.json")
	
	# Ambil status dialog dari Global Autoload sebagai default awal
	if "current_dialog_status" in Global:
		status_dialog = Global.current_dialog_status
		
	atur_tampilan_background()
	set_active_chapter(Global.current_chapter)
	update_dialogue()

# Fungsi baru untuk memaksa pengaturan status dialog saat di-instantiate dari script lain
func init_dialog(custom_status: String) -> void:
	status_dialog = custom_status
	atur_tampilan_background()
	set_active_chapter(Global.current_chapter)
	update_dialogue()

func atur_tampilan_background() -> void:
	# Jika node belum siap (di-instantiate lewat kode), tunggu sampai masuk tree
	if not is_inside_tree():
		await ready
		
	# Sembunyikan background JIKA statusnya adalah analysis_intro
	if status_dialog == "analysis_intro":
		if background_node:
			background_node.visible = false
			print("DEBUG DIALOG: Menyembunyikan background secara paksa untuk overlay analisis.")
	else:
		if background_node:
			background_node.visible = true
			print("DEBUG DIALOG: Menampilkan background untuk mode cerita full.")

func load_all_chapters_from_json(file_path: String) -> void:
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var parsed_data = JSON.parse_string(json_string)
		if parsed_data is Dictionary:
			all_chapters_data = parsed_data

func set_active_chapter(chapter_key: String) -> void:
	if all_chapters_data.has(chapter_key):
		var data_chapter = all_chapters_data[chapter_key]
		
		if data_chapter is Dictionary:
			if data_chapter.has(status_dialog):
				story_data = data_chapter[status_dialog]
				print("DEBUG DIALOG: Memuat sub-key [", status_dialog, "] dengan jumlah baris: ", story_data.size())
			else:
				push_error("ERROR DIALOG: Sub-key '" + status_dialog + "' tidak ditemukan!")
				story_data = []
		elif data_chapter is Array:
			story_data = data_chapter
			print("DEBUG DIALOG: Memuat Array polos dengan jumlah baris: ", story_data.size())
			
		current_dialogue_index = 0

func update_dialogue():
	if current_dialogue_index < story_data.size():
		var data = story_data[current_dialogue_index]
		name_label.text = str(data.get("name", ""))
		text_label.text = str(data.get("text", ""))
		
		var portrait_path = data.get("portrait", "")
		if not portrait_path.is_empty() and ResourceLoader.exists(portrait_path):
			portrait_node.texture = load(portrait_path)
			portrait_node.show()
		else:
			portrait_node.hide()
	else:
		handle_dialogue_end_routing()

func _on_next_button_pressed():
	current_dialogue_index += 1
	update_dialogue()
func handle_dialogue_end_routing():
	emit_signal("dialog_selesai")
	
	if status_dialog == "analysis_intro":
		print("DEBUG DIALOG ROUTING: Selesai Analysis Intro -> Menghapus Overlay Dialog.")
		queue_free()
	elif status_dialog == "analysis_outro":
		print("DEBUG DIALOG ROUTING: Selesai Analysis Outro -> Pindah ke Scene Suspek.")
		get_tree().change_scene_to_file("res://src/suspect_level/pemilihan_suspek.tscn")
	elif status_dialog == "suspect_intro":
		print("DEBUG DIALOG ROUTING: Selesai Suspect Intro -> Bebas memilih suspek.")
		queue_free()
	else:
		if Global.current_chapter == "chapter_1" and status_dialog == "intro":
			get_tree().change_scene_to_file("res://src/search_level/level1.tscn")
		elif Global.current_chapter == "chapter_1" and status_dialog == "guide":
			get_tree().change_scene_to_file("res://src/analisis_level/analisis_utama.tscn")
		else:
			get_tree().change_scene_to_file("res://src/search_level/level1.tscn")
