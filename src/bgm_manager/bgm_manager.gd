extends AudioStreamPlayer

var lagu_sekarang: String = ""

func putar_suasana(path_lagu: String, durasi_fade: float = 0.5):
	if lagu_sekarang == path_lagu:
		return
	
	lagu_sekarang = path_lagu
	
	# Jika path kosong, matikan musik dengan fade out
	if path_lagu == "" or path_lagu == null:
		_fade_out_aktif(durasi_fade)
		return
		
	var lagu_baru = load(path_lagu)
	if lagu_baru:
		# Fade out lagu lama
		var tween = create_tween()
		tween.tween_property(self, "volume_db", -40.0, durasi_fade) 
		await tween.finished
		
		# Ganti dan mainkan lagu baru
		stop()
		stream = lagu_baru
		play()
		
		# Fade in lagu baru
		var tween_in = create_tween()
		tween_in.tween_property(self, "volume_db", 0.0, durasi_fade)
		
func _fade_out_aktif(durasi: float):
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -40.0, durasi)
	await tween.finished
	stop()
	lagu_sekarang = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
