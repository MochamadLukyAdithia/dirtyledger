extends Control

# Database Hasil Analisis Cerita
var database_cerita = {
	"Kunci": "Kunci ini ternyata digunakan untuk brangkas rahasia di ruang direktur. Di dalamnya tersembunyi buku kas kedua...",
	"Flashdisk": "Flashdisk ini berisi file excel terenkripsi. Setelah didekripsi, ditemukan daftar aliran dana fiktif.",
	"Kwitansi": "Kwitansi ini palsu. Stempel perusahaannya berbeda dengan stempel asli, dan nominalnya digelembungkan 10x lipat."
}

const SLOT_BUKTI = preload("res://src/analisis_level/slot_bukti.tscn")
const DIALOG_SCENE = preload("res://src/dialogue_level/StoryIntro.tscn")

var tex_kunci = preload("res://assets/evidence/kunci.png")
var tex_fd = preload("res://assets/evidence/flashdisk.png")
var tex_kwitansi = preload("res://assets/evidence/kwitansi.jpg")

@onready var h_box_container = $data_comparison/HBoxContainer
@onready var story_panel = $CanvasLayer/story_panel
@onready var story_label = $CanvasLayer/story_panel/story_label

var daftar_slot_di_meja: Array = []

# Array baru untuk mencatat barang apa saja yang SUDAH selesai diproses analisisnya
var barang_sudah_analisis: Array[String] = []

func _ready() -> void:
	story_panel.hide()
	input_bukti_ke_meja()
	
	if Global.current_chapter == "chapter_1":
		print("DEBUG ANALISIS: Chapter 1 Pakai Dialog Intro. Mengunci slot tombol.")
		set_semua_tombol_slot_aktif(false)
		munculkan_dialog_overlay("analysis_intro")
	else:
		print("DEBUG ANALISIS: Chapter Non-1 Aktif. Slot langsung dibuka.")
		set_semua_tombol_slot_aktif(true)

func input_bukti_ke_meja():
	var bukti_pemain = Global.bukti_ditemukan
	
	for nama in bukti_pemain:
		var slot_baru = SLOT_BUKTI.instantiate()
		h_box_container.add_child(slot_baru) 
		
		var texture_barang = dapatkan_texture(nama)
		slot_baru.set_bukti(nama, texture_barang)
		
		slot_baru.analisis_selesai.connect(_on_barang_selesai_dianalisis)
		slot_baru.btn_analisis.pressed.connect(func(): _on_slot_klik(slot_baru))
		
		daftar_slot_di_meja.append(slot_baru)

func dapatkan_texture(nama: String) -> Texture2D:
	match nama:
		"Kunci": return tex_kunci
		"Flashdisk": return tex_fd
		"Kwitansi": return tex_kwitansi
	return null

func _on_slot_klik(slot):
	if not slot.sedang_analisis and not slot.sudah_selesai:
		slot.mulai_proses_analisis()
	elif slot.sudah_selesai:
		tampilkan_cerita(slot.nama_item)

func _on_barang_selesai_dianalisis(nama_barang):
	print("Notifikasi Sistem: Analisis selesai untuk objek -> " + nama_barang)
	
	# Masukkan nama barang ke list pelacak jika belum ada
	if not barang_sudah_analisis.has(nama_barang):
		barang_sudah_analisis.append(nama_barang)
		
	# CEK KONDISI JIKA SEMUA BARANG DI MEJA SUDAH SELESAI DIANALISIS
	if barang_sudah_analisis.size() == Global.bukti_ditemukan.size():
		print("DEBUG ANALISIS: Semua barang sukses dianalisis! Memicu Analysis Outro...")
		# Beri sedikit waktu delay agar pop-up cerita penutup barang selesai dibaca dulu (opsional)
		await get_tree().create_timer(0.5).timeout
		munculkan_dialog_overlay("analysis_outro")

func tampilkan_cerita(nama_barang):
	if database_cerita.has(nama_barang):
		story_label.text = "HASIL ANALISIS " + nama_barang.to_upper() + ":\n\n" + database_cerita[nama_barang]
		story_panel.show()

func _on_close_button_pressed():
	story_panel.hide()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/main_lobby/main_lobby.tscn")

# === MENGEMBANGKAN MODAL OVERLAY MENJADI DINAMIS ===
func munculkan_dialog_overlay(status_key: String) -> void:
	var dialog_instance = DIALOG_SCENE.instantiate()
	add_child(dialog_instance)
	
	# Mengirimkan status secara fleksibel (bisa "analysis_intro" atau "analysis_outro")
	dialog_instance.init_dialog(status_key)
	
	if status_key == "analysis_intro":
		dialog_instance.dialog_selesai.connect(_on_dialog_intro_selesai)

func _on_dialog_intro_selesai() -> void:
	print("DEBUG ANALISIS: Dialog intro selesai! Membuka interaksi tombol slot.")
	set_semua_tombol_slot_aktif(true)

func set_semua_tombol_slot_aktif(status: bool) -> void:
	for slot in daftar_slot_di_meja:
		if slot and slot.get("btn_analisis"):
			slot.btn_analisis.disabled = !status
