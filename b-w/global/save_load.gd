class_name SaveLoad

const SAVE_PATH = "user://highscore.bin"

static func save_highscore(highscore: int) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_64(highscore)
	else:
		push_warning("Couldn't save highscore file: ", error_string(FileAccess.get_open_error()))

static func load_highscore() -> int:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		return file.get_64()
	else:
		push_warning("Couldn't load highscore file: ", error_string(FileAccess.get_open_error()))
		return -1
