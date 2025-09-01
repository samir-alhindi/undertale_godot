extends Wave

var white_bullet_scene := preload("uid://vy7eelm7fbgd")

var counter := 0
func _on_spawn_timer_timeout() -> void:
	
	var center := get_viewport_rect().size.x/ 2
	var center_offset := 20
	counter += 1
	var even := counter % 2 == 0
	
	var blue_bullet: LinearBullet = bullet_scene.instantiate().new(PI)
	add_child(blue_bullet)
	blue_bullet.global_position = Vector2(center + (center_offset if even else -center_offset), 0)
	
	var white_bullet: LinearBullet = white_bullet_scene.instantiate().new(0)
	add_child(white_bullet)
	white_bullet.global_position = Vector2(center +( -center_offset if even else center_offset), 0)
