class_name EnemyStats extends Resource

@export var name: String = "Enemy name here"
@export var HP: int = 100
@export var sprite: Texture
@export var acts: Array[Act]
@export var bullet_waves: Array[PackedScene]
@export_multiline var encounter_text := "* name here drew new !"
@export_multiline var idle_text := "* name here is staring at you angerly"
