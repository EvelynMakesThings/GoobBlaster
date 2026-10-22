extends Node3D

@onready var audio_player: AudioStreamPlayer = AudioStreamPlayer.new();
@onready var file_dialog: FileDialog = FileDialog.new();
@onready var spectrum_analyzer: AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(AudioServer.get_bus_index("Master"),0);
var LeftSpectralItems: Array[MeshInstance3D]
var RightSpectralItems: Array[MeshInstance3D]
var SpectralMesh = preload("res://MainBoxMesh.tres")

@export var Sensitivity: float = 10;

const SpectralItemsCount = 20;

var time: float = 0;
@onready var circlePos: Vector3 = $Circler.position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(audio_player);
	add_child(file_dialog);
	
	for i in range(SpectralItemsCount):
		var NewChild = MeshInstance3D.new()
		NewChild.name = "Spectral" + str(i+1)
		NewChild.position.z = -1.4*i;
		NewChild.mesh = SpectralMesh
		LeftSpectralItems.append(NewChild)
		$LeftSpectral.add_child(NewChild)
		NewChild.owner = get_tree().current_scene
		
	for i in range(SpectralItemsCount):
		var NewChild = MeshInstance3D.new()
		NewChild.name = "Spectral" + str(i+1)
		NewChild.position.z = -1.4*i;
		NewChild.mesh = SpectralMesh
		RightSpectralItems.append(NewChild)
		$RightSpectral.add_child(NewChild)
		NewChild.owner = get_tree().current_scene
	
	file_dialog.use_native_dialog = true;
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE;
	file_dialog.access=FileDialog.ACCESS_FILESYSTEM;
	file_dialog.add_filter("*.mp3", "MP3 Audio");
	file_dialog.file_selected.connect(_file_selected);
	
	file_dialog.popup();

func _file_selected(path: String) -> void:
	print(path);
	var stream = AudioStreamMP3.load_from_file(path)
	audio_player.stream = stream;
	audio_player.play();
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spectrum_analyzer:
		for i in range(SpectralItemsCount):
			var BoxL = LeftSpectralItems[i]
			var BoxR = RightSpectralItems[i]
			BoxL.position.y = lerp(
				BoxL.position.y,
				spectrum_analyzer.get_magnitude_for_frequency_range(
					Sensitivity*pow(20000 / 20, float(i) / SpectralItemsCount),
					Sensitivity*pow(20000 / 20, float(i+1) / SpectralItemsCount)
				).x * 20,
				1.0 - exp(-10 * delta)
			)
			BoxR.position.y = lerp(
				BoxR.position.y,
				spectrum_analyzer.get_magnitude_for_frequency_range(
					Sensitivity*pow(20000 / 20, float(i) / SpectralItemsCount),
					Sensitivity*pow(20000 / 20, float(i+1) / SpectralItemsCount)
				).y * 20,
				1.0 - exp(-10 * delta)
			)
		
		# Circler
		time = lerp(
			time,
			time+spectrum_analyzer.get_magnitude_for_frequency_range(20,20000).length()*Sensitivity*delta,
			1.0 - exp(-10 * delta)
		)
		$Circler.position.x = circlePos.x + cos(time*40)*1.5
		$Circler.position.y = circlePos.y + sin(time*40)*1.5
