extends CanvasLayer

## Boss health bar shown while a [BossHealthTarget] is active.

@onready var _panel: PanelContainer = %BossPanel
@onready var _name_label: Label = %BossNameLabel
@onready var _health_bar: ProgressBar = %BossHealthBar

var _tracked_boss: BossHealthTarget


func _ready() -> void:
	_panel.visible = false
	_refresh_tracked_boss()


func _process(_delta: float) -> void:
	if _tracked_boss != null and is_instance_valid(_tracked_boss):
		return
	_refresh_tracked_boss()


func _refresh_tracked_boss() -> void:
	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
	if bosses.is_empty():
		_clear_boss_display()
		return

	var next_boss: BossHealthTarget = bosses[0] as BossHealthTarget
	if next_boss == null:
		_clear_boss_display()
		return

	if _tracked_boss == next_boss:
		return

	if _tracked_boss != null and _tracked_boss.health_changed.is_connected(_on_boss_health_changed):
		_tracked_boss.health_changed.disconnect(_on_boss_health_changed)

	_tracked_boss = next_boss
	_tracked_boss.health_changed.connect(_on_boss_health_changed)
	_name_label.text = _tracked_boss.display_name
	_on_boss_health_changed(_tracked_boss.current_health, _tracked_boss.max_health)
	_panel.visible = true


func _clear_boss_display() -> void:
	if _tracked_boss != null and _tracked_boss.health_changed.is_connected(_on_boss_health_changed):
		_tracked_boss.health_changed.disconnect(_on_boss_health_changed)
	_tracked_boss = null
	_panel.visible = false


func _on_boss_health_changed(current_health: int, max_health: int) -> void:
	_health_bar.max_value = max_health
	_health_bar.value = current_health
	if current_health <= 0:
		_clear_boss_display()
