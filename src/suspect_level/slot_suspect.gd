extends Button # Menggunakan Button agar seluruh kartu bisa diklik

signal suspect_dipilih(id_suspect)

var suspect_id: String = ""

func set_profil(id: String, nama: String, kantor: String, foto: Texture2D):
	suspect_id = id
	$VBoxContainer/label_nama.text = nama
	$VBoxContainer/label_kantor.text = kantor
	$VBoxContainer/texture_rect.texture = foto

# Hubungkan sinyal pressed bawaan Button ke dirinya sendiri
func _on_pressed() -> void:
	suspect_dipilih.emit(suspect_id)
