class_name Util extends Node

static func tornado(text: String, radius: float = 10.0, freq: float = 3.0) -> String:
	return "[tornado radius=%f freq=%f]%s[/tornado]" % [radius, freq, text]

static func shake(text: String, rate: float = 20.0, level: float = 5.0) -> String:
	return "[shake rate=%f level=%f]%s[/shake]" % [rate, level, text]

static func wave(text: String, amp: float = 100.0, freq = 10.0) -> String:
	return "[wave amp%f freq=%f]%s[/wave]" % [amp, freq, text]
