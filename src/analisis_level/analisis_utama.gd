extends Control

# Database Hasil Analisis Cerita
var database_cerita = {
	"Kunci": "Kunci ini ternyata digunakan untuk brangkas rahasia di ruang direktur. Di dalamnya tersembunyi buku kas kedua...",
	"Flashdisk": "Flashdisk ini berisi file excel terenkripsi. Setelah didekripsi, ditemukan daftar aliran dana fiktif.",
	"Kwitansi": "Kwitansi ini palsu. Stempel perusahaannya berbeda dengan stempel asli, dan nominalnya digelembungkan 10x lipat."
}

# Preload Scene Kecil SlotBukti
const SLOT_BUKTI = preload("res://src/analisis_level/slot_bukti.tscn")

# Preload Gambar Aset (Pastikan file gambar ini ada di folder project kamu)
var tex_kunci = preload("res://assets/evidence/kunci.png")
var tex_fd = preload("res://assets/evidence/flashdisk.png")
var tex_kwitansi = preload("res://assets/evidence/kwitansi.jpg")

@onready var h_box_container = $data_comparison/HBoxContainer
@onready var story_panel = $CanvasLayer/story_panel
@onready var story_label = $CanvasLayer/story_panel/story_label

func _ready() -> void:
	story_panel.hide()
	input_bukti_ke_meja()

func input_bukti_ke_meja():
	# Ambil data dinamis dari Global script
	var bukti_pemain = Global.bukti_ditemukan
	
	for nama in bukti_pemain:
		var slot_baru = SLOT_BUKTI.instantiate()
		h_box_container.add_child(slot_baru) 
		
		var texture_barang = dapatkan_texture(nama)
		slot_baru.set_bukti(nama, texture_barang)
		
		# Hubungkan interaksi tombol di dalam slot lewat kode
		slot_baru.analisis_selesai.connect(_on_barang_selesai_dianalisis)
		slot_baru.btn_analisis.pressed.connect(func(): _on_slot_klik(slot_baru))

func dapatkan_texture(nama: String) -> Texture2D:
	match nama:
		"Kunci": return tex_kunci
		"Flashdisk": return tex_fd
		"Kwitansi": return tex_kwitansi
	return null

func _on_slot_klik(slot):
	# Jika belum dianalisis sama sekali
	if not slot.sedang_analisis and not slot.sudah_selesai:
		slot.mulai_proses_analisis()
	# Jika statusnya sudah selesai dianalisis (Tombol teksnya "Lihat Hasil")
	elif slot.sudah_selesai:
		tampilkan_cerita(slot.nama_item)

func _on_barang_selesai_dianalisis(nama_barang):
	print("Notifikasi Sistem: Analisis selesai untuk objek -> " + nama_barang)

func tampilkan_cerita(nama_barang):
	if database_cerita.has(nama_barang):
		story_label.text = "[b]HASIL ANALISIS " + nama_barang.to_upper() + ":[/b]\n\n" + database_cerita[nama_barang]
		story_panel.show()

func _on_close_button_pressed():
	story_panel.hide()

func _on_back_button_pressed():
	# JANGAN pakai change_scene_to_file agar timer tidak hancur. Cukup sembunyikan UI ini.
	get_tree().change_scene_to_file("res://src/ui/main_lobby/main_lobby.tscn")
	# Panggil/Munculkan scene lobby kamu yang berada di luar tree ini, misal:
	 #get_node("../Lobby").show()
