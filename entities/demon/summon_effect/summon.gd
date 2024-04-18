extends Node3D

@export var gpu_particles: GPUParticles3D
@export var cpu_particles: CPUParticles3D
@export var animation_player: AnimationPlayer


func _ready() -> void:
	if OS.get_name() == "Web":
		gpu_particles.hide()
		if animation_player.get_animation("summon_demon").get_track_count() == 4:
			animation_player.get_animation("summon_demon").remove_track(0)
		cpu_particles.show()
	else:
		gpu_particles.show()
		cpu_particles.hide()
		if animation_player.get_animation("summon_demon").get_track_count() == 4:
			animation_player.get_animation("summon_demon").remove_track(3)

