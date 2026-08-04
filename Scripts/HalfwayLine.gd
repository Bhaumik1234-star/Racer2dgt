extends Area2D

func _ready() -> void:
	# Listen for when the car crosses this halfway point
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _on_area_entered(area: Node2D) -> void:
	_check_car(area)

func _on_body_entered(body: Node2D) -> void:
	_check_car(body)

func _check_car(node: Node2D) -> void:
	# Tell the car script it reached halfway
	if node.has_method("on_hit_halfway"):
		node.on_hit_halfway()
