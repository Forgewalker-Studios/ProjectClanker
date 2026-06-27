extends CanvasLayer

## HP shown while there is a valid node in the boss group.

@onready var _panel: PanelContainer = %BossPanel
@onready var _name_label: Label = %BossNameLabel
@onready var _health_bar: ProgressBar = %BossHealthBar

var _tracked_boss: Node = null


func _ready() -> void:
	_panel.visible = false


## Handles tracking of active boss entities to display HP bar.
func _process(_delta: float) -> void:
	if _tracked_boss == null:
		_refresh_tracked_boss()
		return

	if not is_instance_valid(_tracked_boss):
		_clear_boss_display()
		return

	if not _tracked_boss.is_in_group("boss"):
		_clear_boss_display()
		return

	_update_boss_display()


## Handles actual tracking of boss nodes.
func _refresh_tracked_boss() -> void:
	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")

	for boss: Node in bosses:
		if boss == null:
			continue

		_tracked_boss = boss
		_name_label.text = _get_boss_display_name(boss)
		_panel.visible = true
		_update_boss_display()
		return

	_clear_boss_display()


## Clears HP bar when no boss is tracked.
func _clear_boss_display() -> void:
	_tracked_boss = null
	_panel.visible = false


## Updates the display of the HP bar.
## Not tied to signals, only handles visual display.
func _update_boss_display() -> void:
	if _tracked_boss == null:
		return

	var max_hp: int = _get_boss_max_health(_tracked_boss)
	var current_hp: int = _get_boss_current_health(_tracked_boss)

	if max_hp <= 0:
		_clear_boss_display()
		return

	_health_bar.max_value = max_hp
	_health_bar.value = clampi(current_hp, 0, max_hp)

	if current_hp <= 0:
		_clear_boss_display()


## Presents the name of the boss according to the .tres.
func _get_boss_display_name(boss: Node) -> String:
	if boss.has_method("get_display_name"):
		return str(boss.call("get_display_name"))

	var display_name: Variant = boss.get("display_name")
	if display_name != null:
		return str(display_name)

	var config: Variant = boss.get("config")
	if config != null:
		var config_name: Variant = config.get("display_name")
		if config_name != null:
			return str(config_name)

		config_name = config.get("enemy_name")
		if config_name != null:
			return str(config_name)

	return boss.name


func _get_boss_current_health(boss: Node) -> int:
	if boss.has_method("get_current_health"):
		return int(boss.call("get_current_health"))

	var current_health: Variant = boss.get("current_health")
	if current_health != null:
		return int(current_health)

	current_health = boss.get("health")
	if current_health != null:
		return int(current_health)

	current_health = boss.get("hp")
	if current_health != null:
		return int(current_health)

	return _get_boss_max_health(boss)


func _get_boss_max_health(boss: Node) -> int:
	if boss.has_method("get_max_health"):
		return int(boss.call("get_max_health"))

	var max_health: Variant = boss.get("max_health")
	if max_health != null:
		return int(max_health)

	max_health = boss.get("maximum_health")
	if max_health != null:
		return int(max_health)

	max_health = boss.get("max_hp")
	if max_health != null:
		return int(max_health)

	var config: Variant = boss.get("config")
	if config != null:
		max_health = config.get("max_health")
		if max_health != null:
			return int(max_health)

		max_health = config.get("maximum_health")
		if max_health != null:
			return int(max_health)

		max_health = config.get("max_hp")
		if max_health != null:
			return int(max_health)

		max_health = config.get("health")
		if max_health != null:
			return int(max_health)

	return 0
