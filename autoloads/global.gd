extends Node

signal wave_done(wave_scene: Node2D, soul: Soul)
signal add_bullet(bullet: Node2D, transform: Transform2D)
signal change_mercy(amount: int)
signal heal_player(amount: int)
signal bullet_destroyed(pos: Vector2)
signal monster_visible(new_val: bool)
signal play_shoot_sound
