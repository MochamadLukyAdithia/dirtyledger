extends Control

# Preload Scene Kartu Suspect dan Scene Dialog
const SLOT_SUSPECT = preload("res://src/suspect_level/slot_suspect.tscn")
# Sesuaikan path di bawah ini dengan lokasi scene dialog kamu
const DIALOG_SCENE = preload("res://src/dialogue_level/StoryIntro.tscn") 

# Database Data Suspect
var database_suspect = {
	"Aruna": {
		"nama": "William",
		"kantor": "Aruna Consulting Group",
		"foto": preload("res://assets/character/angela/Angela.webp"),
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
	
	# Sembunyikan/Nonaktifkan dulu container suspek agar tidak bisa diklik saat intro
	suspect_container.modulate.a = 0.0 
	
	# Cek apakah ini saatnya memunculkan suspect_intro
	if Global.current_dialog_status == "suspect_intro":
		munculkan_suspect_intro()
	else:
		mulai_interogasi_utama()

func munculkan_suspect_intro():
	print("DEBUG SUSPECT: Memunculkan overlay Suspect Intro.")
	var dialog_ins = DIALOG_SCENE.instantiate()
	add_child(dialog_ins)
	# Menginisiasi status ke suspect_intro secara paksa
	dialog_ins.init_dialog("suspect_intro")

# Fungsi ini akan dipanggil otomatis oleh script dialog saat suspect_intro selesai
func mulai_interogasi_utama():
	print("DEBUG SUSPECT: Intro Selesai, Membuka Fitur Interogasi Utama.")
	
	# Memunculkan kembali daftar suspek dengan efek transisi mulus
	var tween = create_tween()
	tween.tween_property(suspect_container, "modulate:a", 1.0, 0.5)
	
	# Bersihkan container jika sebelumnya sudah ada data agar tidak duplikat
	for child in suspect_container.get_children():
		child.queue_free()
		
	muat_suspect_ke_layar()

func muat_suspect_ke_layar():
	for id in database_suspect:
		var data = database_suspect[id]
		var kartu_baru = SLOT_SUSPECT.instantiate()
		suspect_container.add_child(kartu_baru)
		
		kartu_baru.set_profil(id, data["nama"], data["kantor"], data["foto"])
		kartu_baru.suspect_dipilih.connect(_on_suspect_kartu_diklik)

func _on_suspect_kartu_diklik(id_suspect):
	suspect_terpilih_id = id_suspect
	var data = database_suspect[id_suspect]
	
	text_penjelasan.bbcode_enabled = true
	text_penjelasan.text = "[b]Analisis Keterkaitan Bukti dengan " + data["nama"] + ":[/b]\n\n" + data["clue_match"]
	detail_panel.show()

func _on_btn_tuduh_pressed() -> void:
	if suspect_terpilih_id == "": return
	
	var data = database_suspect[suspect_terpilih_id]
	if data["is_dalang"] == true:
		pemicu_true_ending()
	else:
		print("Tuduhan Salah! Game Over atau Kurangi Nyawa.")

func pemicu_true_ending():
	true_ending_panel.show()
	news_label.bbcode_enabled = true
	var teks = "[center][b][color=red]BREAKING NEWS[/color][/b][/center]\n\n"
	teks += "Satgas Intelijen Keuangan resmi membongkar Black Ledger Network!\n\n"
	teks += "Dalang utama, [b]Drakar Surya[/b], berhasil diringkus di kediamannya.\n"
	teks += "Otoritas hukum menyita aset sebesar [color=yellow]₳2.300.000.000[/color].\n\n"
	teks += "Atas penyalahgunaan posisi regulator, Hakim menjatuhkan vonis [b][color=red]40 Tahun Penjara[/color][/b]!"
	
	news_label.text = teks
	true_ending_panel.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(true_ending_panel, "modulate:a", 1.0, 1.5)
