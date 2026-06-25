extends Node2D

#tugas backend : 1. bikin list item nya bisa ditampilkan di slotext, 2. bikin sistematis score 3. bikin sistematis timer
# --- VARIABEL GAMEPLAY ---
var id_kasus: String = "Kasus_1"
var daftar_target_level: Array = []
var item_aktif_di_ui: Array = ["", "", ""]

# --- VARIABEL FITUR BARU ---
var waktu_berjalan: float = 0.0
var skor_sekarang: int = 0
var multiplier_level: int = 1 # Nilai x1 sampai x6
var multiplier_timer: float = 0.0
const MULTIPLIER_DURATION: float = 4.0 # Waktu (detik) sebelum stack multiplier turun

# --- REFERENSI NODE ---
@onready var timer_label: Label = $CanvasLayerUI/TopUI/MarginContainer/HBoxContainer/TimerLabel/Label
@onready var score_label: Label = $CanvasLayerUI/TopUI/MarginContainer/HBoxContainer/ScoreLabel/Label
@onready var multiplier_bars: Array = $CanvasLayerUI/TopUI/MarginContainer/HBoxContainer/MultiplierContainer.get_children()

@onready var slot_labels: Array = [
	$CanvasLayerUI/BottomUI/HBoxContainer/SlotText1/Slot1,
	$CanvasLayerUI/BottomUI/HBoxContainer/SlotText2/Slot2,
	$CanvasLayerUI/BottomUI/HBoxContainer/SlotText3/Slot3
]

func _ready() -> void:
	_inisialisasi_barang_dari_map()
	for i in range(3):
		_isi_slot_kosong(i)
	_update_tampilan_multiplier()

func _process(delta: float) -> void:
	# 1. Logika Timer Menghitung Lama Bermain
	waktu_berjalan += delta
	var menit: int = int(waktu_berjalan) / 60
	var detik: int = int(waktu_berjalan) % 60
	timer_label.text = "%02d:%02d" % [menit, detik]
	
	# 2. Logika Pengurangan Multiplier Berdasarkan Waktu
	if multiplier_level > 1:
		multiplier_timer -= delta
		if multiplier_timer <= 0:
			multiplier_level -= 1
			multiplier_timer = MULTIPLIER_DURATION
			_update_tampilan_multiplier()

func _inisialisasi_barang_dari_map() -> void:
	for item in $ItemsContainer.get_children():
		if item.has_signal("barang_ditemukan"):
			item.barang_ditemukan.connect(_on_barang_diklik)
			daftar_target_level.append(item.nama_barang)
	daftar_target_level.shuffle()

func _isi_slot_kosong(indeks_slot: int) -> void:
	if daftar_target_level.size() > 0:
		var item_baru = daftar_target_level.pop_front()
		item_aktif_di_ui[indeks_slot] = item_baru
		slot_labels[indeks_slot].text = item_baru
		slot_labels[indeks_slot].show()
	else:
		item_aktif_di_ui[indeks_slot] = ""
		slot_labels[indeks_slot].hide()
		_cek_kondisi_menang()

func _on_barang_diklik(nama_barang: String) -> void:
	if item_aktif_di_ui.has(nama_barang):
		var indeks = item_aktif_di_ui.find(nama_barang)
		
		# Tambah Stack Multiplier (Maksimal x6)
		if multiplier_level < 6:
			multiplier_level += 1
		multiplier_timer = MULTIPLIER_DURATION
		_update_tampilan_multiplier()
		
		# Hitung Skor Real-time (Misal skor dasar 100 * total multiplier saat ini)
		var skor_didapat = 100 * multiplier_level
		skor_sekarang += skor_didapat
		score_label.text = str(skor_sekarang)
		
		# Ambil item berikutnya untuk antrean bawah
		_isi_slot_kosong(indeks)
	else:
		# Penalti jika klik barang yang tidak ada di list bawah (mencegah spam klik)
		multiplier_level = 1
		multiplier_timer = 0.0
		_update_tampilan_multiplier()

func _update_tampilan_multiplier() -> void:
	# Menyalakan/mematikan lampu bar indikator di UI berdasarkan level multiplier saat ini
	for i in range(multiplier_bars.size()):
		if i < multiplier_level:
			multiplier_bars[i].modulate = Color.ORANGE # Nyalakan lampu (Oranye)
		else:
			multiplier_bars[i].modulate = Color.DARK_GRAY # Matikan lampu (Abu-abu)

func _cek_kondisi_menang() -> void:
	if item_aktif_di_ui[0] == "" and item_aktif_di_ui[1] == "" and item_aktif_di_ui[2] == "":
		set_process(false) # Hentikan timer permainan
		print("Stage Selesai! Skor Akhir Anda: ", skor_sekarang)
