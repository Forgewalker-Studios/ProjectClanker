class_name InteractionTargetSystem
extends RefCounted

## PURPOSE:
## Resolve interaction targets between current focus and nearby fallback candidates.
##
## USE WHEN:
## A game needs reusable target-priority and nearby-registration behavior independent of gameplay side effects.
##
## DO NOT USE WHEN:
## Target handling requires game-specific item/puzzle/backpack semantics in the same module.
##
## OWNS:
## Current focus target reference, nearby target registry (WeakRef), and resolution order (focus first, then optional closest-distance nearby, else first-valid nearby).
##
## CALLER MUST PROVIDE:
## Candidate nodes, optional validity/prompt callables, and any game-specific dispatch consequences.
##
## GAME-SPECIFIC GLUE BELONGS:
## In gameplay interaction managers that route to project-specific behavior/events/UI.

var _focus_target: Node = null
var _nearby_targets: Dictionary = {}

func set_focus_target(target: Node) -> void:
	_focus_target = target

func clear_focus_target() -> void:
	_focus_target = null

func register_nearby_target(target: Node) -> void:
	if target == null:
		return
	_nearby_targets[target.get_instance_id()] = weakref(target)

func unregister_nearby_target(target: Node) -> void:
	if target == null:
		return
	_nearby_targets.erase(target.get_instance_id())

func clear_nearby_targets() -> void:
	_nearby_targets.clear()

## resolve_target
## Purpose: Resolve the active interaction target: valid focus first, else nearby fallback. When origin_for_closest_nearby and max_nearby_distance are set, nearby branch picks the closest valid Node3D within range (matches typical player proximity rules). Otherwise the first valid nearby in registration order is returned.
## Parameters: validity_callable - Optional filter; must return true for a candidate to count. origin_for_closest_nearby - When non-null and max_nearby_distance > 0, nearby candidates are compared by distance from this node. max_nearby_distance - Maximum distance from origin for nearby candidates when using closest mode; use <= 0 to use first-valid nearby order instead.
## Returns: Resolved Node or null.
func resolve_target(validity_callable: Callable = Callable(), origin_for_closest_nearby: Node3D = null, max_nearby_distance: float = -1.0) -> Node:
	_prune_invalid_nearby_targets()
	if _is_valid_target(_focus_target, validity_callable):
		return _focus_target
	if origin_for_closest_nearby != null and max_nearby_distance > 0.0:
		return _resolve_closest_valid_nearby(origin_for_closest_nearby, max_nearby_distance, validity_callable)
	for key: Variant in _nearby_targets.keys():
		var weak_target: WeakRef = _nearby_targets[key] as WeakRef
		var candidate_variant: Variant = weak_target.get_ref() if weak_target != null else null
		if not (candidate_variant is Node):
			continue
		var candidate: Node = candidate_variant as Node
		if _is_valid_target(candidate, validity_callable):
			return candidate
	return null

## _resolve_closest_valid_nearby
## Purpose: Among registered nearby targets, return the valid Node3D with smallest distance to origin within max_distance.
## Parameters: origin - Reference node for distance measurement. max_distance - Inclusive maximum distance. validity_callable - Optional filter.
## Returns: Closest candidate Node or null.
func _resolve_closest_valid_nearby(origin: Node3D, max_distance: float, validity_callable: Callable) -> Node:
	if origin == null:
		return null
	var origin_pos: Vector3 = _node3d_world_origin(origin)
	var best: Node = null
	var best_distance: float = INF
	for key: Variant in _nearby_targets.keys():
		var weak_target: WeakRef = _nearby_targets[key] as WeakRef
		var candidate_variant: Variant = weak_target.get_ref() if weak_target != null else null
		if not (candidate_variant is Node3D):
			continue
		var candidate_3d: Node3D = candidate_variant as Node3D
		if not _is_valid_target(candidate_3d, validity_callable):
			continue
		var distance: float = origin_pos.distance_to(_node3d_world_origin(candidate_3d))
		if distance > max_distance:
			continue
		if distance < best_distance:
			best_distance = distance
			best = candidate_3d
	return best

## _node3d_world_origin
## Purpose: Stable world-space origin for a Node3D whether or not it is inside the scene tree (headless tests may resolve before enter_tree flush).
## Parameters: node - Node to measure.
## Returns: Approximate world origin of the node's transform chain.
func _node3d_world_origin(node: Node3D) -> Vector3:
	if node == null:
		return Vector3.ZERO
	if node.is_inside_tree():
		return node.global_position
	var accumulated: Transform3D = Transform3D.IDENTITY
	var walk: Node = node
	while walk != null:
		if walk is Node3D:
			var as_3d: Node3D = walk as Node3D
			accumulated = as_3d.transform * accumulated
		walk = walk.get_parent()
	return accumulated.origin

func dispatch_interact(target: Node) -> bool:
	if target == null or not target.has_method("interact"):
		return false
	target.interact()
	return true

func dispatch_interact_with_caller(target: Node, caller: Node) -> bool:
	if target == null or caller == null or not target.has_method("interact"):
		return false
	target.interact(caller)
	return true

func resolve_prompt(target: Node, prompt_callable: Callable = Callable()) -> String:
	if target == null:
		return ""
	if prompt_callable.is_valid():
		return String(prompt_callable.call(target)).strip_edges()
	if target.has_method("get_pickup_prompt_text"):
		return String(target.get_pickup_prompt_text()).strip_edges()
	if target.has_method("get_interaction_prompt"):
		return String(target.get_interaction_prompt()).strip_edges()
	if _has_property(target, "interaction_prompt"):
		return String(target.get("interaction_prompt")).strip_edges()
	return ""

func _is_valid_target(target: Node, validity_callable: Callable) -> bool:
	if target == null:
		return false
	if not is_instance_valid(target):
		return false
	if validity_callable.is_valid():
		return bool(validity_callable.call(target))
	return true

func _has_property(object: Object, property_name: String) -> bool:
	for property_variant: Variant in object.get_property_list():
		if property_variant is Dictionary:
			var property_dict: Dictionary = property_variant as Dictionary
			if String(property_dict.get("name", "")) == property_name:
				return true
	return false

func _prune_invalid_nearby_targets() -> void:
	var stale_keys: Array = []
	for key: Variant in _nearby_targets.keys():
		var weak_target: WeakRef = _nearby_targets[key] as WeakRef
		if weak_target == null or weak_target.get_ref() == null:
			stale_keys.append(key)
	for stale_key: Variant in stale_keys:
		_nearby_targets.erase(stale_key)
