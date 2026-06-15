extends Control

# Preload Scene Kartu Suspect
const SLOT_SUSPECT = preload("res://src/suspect_level/slot_suspect.tscn")

# Database Data Suspect, Hubungan Clue, dan Status Kebenaran
var database_suspect = {
	"Aruna": {
		"nama": "William",
		"kantor": "Aruna Consulting Group",
		"foto": preload("res://assets/character/angela/Angela.webp"), # Sesuaikan path gambar
		"clue_match": "William memiliki akses ke sistem, namun catatan log menunjukkan dia tidak berada di ruang server saat enkripsi fiktif dilakukan. Sidik jarinya juga tidak cocok dengan yang ada di Flashdisk.",
		"is_dalang": false
	},
	"Nusa": {
		"nama": "Albert",
		"kantor": "Nusa Holdings Trust",
		"foto": preload("res://assets/character/angela/Angela.webp"),
		"clue_match": "Aliran dana fiktif memang mengalir melalui lembaga Albert, tetapi tanda tangan digital pada kwitansi palsu dipalsukan oleh pihak luar berwenang tinggi. Dia hanya dimanfaatkan.",
		"is_dalang": false
	},
	"Drakar": {
		"nama": "Drakar Surya",
		"kantor": "Jaringan Kolaborator Regulator",
		"foto": preload("res://assets/character/angela/Angela2.webp"),
		"clue_match": "[color=yellow]COCOK![/color] Buku kas kedua dari Kunci brangkas mencantumkan kode inisial 'DS'. Dekripsi Flashdisk mendeteksi bypass otoritas tingkat tinggi yang hanya dimiliki posisinya di Regulator, dan stempel kwitansi palsu dicetak menggunakan mesin khusus kantornya.",
		"is_dalang": true
	}
}

@onready var suspect_container = $suspect_container
@onready var detail_panel = $canvas_layer_ui/detail_panel
@onready var text_penjelasan = $canvas_layer_ui/detail_panel/text_penjelasan
@onready var btn_tuduh = $canvas_layer_ui/detail_panel/btn_tuduh
@onready var true_ending_panel = $canvas_layer_ui/true_ending_panel
@onready var news_label = $canvas_layer_ui/true_ending_panel/news_label

var suspect_terpilih_id: String = ""

func _ready() -> void:
	detail_panel.hide()
	true_ending_panel.hide()
	muat_suspect_ke_layar()

func muat_suspect_ke_layar():
	for id in database_suspect:
		var data = database_suspect[id]
		var kartu_baru = SLOT_SUSPECT.instantiate()
		suspect_container.add_child(kartu_baru)
		
		# Isi data teks dan gambar ke kartu
		kartu_baru.set_profil(id, data["nama"], data["kantor"], data["foto"])
		
		# Tangkap sinyal klik dari kartu
		kartu_baru.suspect_dipilih.connect(_on_suspect_kartu_diklik)

func _on_suspect_kartu_diklik(id_suspect):
	suspect_terpilih_id = id_suspect
	var data = database_suspect[id_suspect]
	
	# Tampilkan penjelasan kecocokan clue
	text_penjelasan.bbcode_enabled = true
	text_penjelasan.text = "[b]Analisis Keterkaitan Bukti dengan " + data["nama"] + ":[/b]\n\n" + data["clue_match"]
	detail_panel.show()

# Hubungkan tombol "BtnTuduh" ke fungsi ini
func _on_btn_tuduh_pressed() -> void:
	if suspect_terpilih_id == "": return
	
	var data = database_suspect[suspect_terpilih_id]
	
	if data["is_dalang"] == true:
		pemicu_true_ending()
	else:
		print("Tuduhan Salah! Game Over atau Kurangi Nyawa.")
		# get_tree().change_scene_to_file("res://GameOver.tscn")

func pemicu_true_ending():
	true_ending_panel.show()
	
	news_label.bbcode_enabled = true
	var teks = "[center][b][color=red]BREAKING NEWS[/color][/b][/center]\n\n"
	teks += "Satgas Intelijen Keuangan resmi membongkar Black Ledger Network!\n\n"
	teks += "Dalang utama, [b]Drakar Surya[/b], berhasil diringkus di kediamannya.\n"
	teks += "Otoritas hukum menyita aset sebesar [color=yellow]₳2.300.000.000[/color].\n\n"
	teks += "Atas penyalahgunaan posisi regulator, Hakim menjatuhkan vonis [b][color=red]40 Tahun Penjara[/color][/b]!"
	
	news_label.text = teks
	
	# Efek Fade-In Animasi Dramatis
	true_ending_panel.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(true_ending_panel, "modulate:a", 1.0, 1.5)
