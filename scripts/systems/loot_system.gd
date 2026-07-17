class_name LootSystem
extends Node

signal collected(experience: int, gold: int)

const MAX_DROPS := 96
const MERGE_DISTANCE := 32.0
const ATTRACT_DISTANCE := 185.0
const PICKUP_DISTANCE := 22.0

var drops: Array[Dictionary] = []

func reset() -> void:
	drops.clear()

func drop_loot(at: Vector2, experience: int, gold: int) -> void:
	var merge_index := _nearest_merge_index(at)
	if merge_index >= 0:
		var merged: Dictionary = drops[merge_index]
		merged["experience"] = int(merged.get("experience", 0)) + experience
		merged["gold"] = int(merged.get("gold", 0)) + gold
		drops[merge_index] = merged
		return
	if drops.size() >= MAX_DROPS:
		var nearest_index := _nearest_index(at)
		if nearest_index >= 0:
			var merged: Dictionary = drops[nearest_index]
			merged["experience"] = int(merged.get("experience", 0)) + experience
			merged["gold"] = int(merged.get("gold", 0)) + gold
			drops[nearest_index] = merged
			return
	drops.append({"position": at, "experience": experience, "gold": gold})

func tick(delta: float, player_position: Vector2) -> void:
	for index in range(drops.size() - 1, -1, -1):
		var drop: Dictionary = drops[index]
		var drop_position: Vector2 = drop.get("position", Vector2.ZERO)
		var to_player: Vector2 = player_position - drop_position
		var distance := to_player.length()
		if distance <= PICKUP_DISTANCE:
			collected.emit(int(drop.get("experience", 0)), int(drop.get("gold", 0)))
			drops.remove_at(index)
			continue
		if distance > ATTRACT_DISTANCE:
			continue
		var attraction := lerpf(180.0, 980.0, 1.0 - distance / ATTRACT_DISTANCE)
		drop["position"] = drop_position + to_player.normalized() * attraction * delta
		drops[index] = drop

func _nearest_merge_index(at: Vector2) -> int:
	for index in range(drops.size()):
		var drop: Dictionary = drops[index]
		var position: Vector2 = drop.get("position", Vector2.ZERO)
		if position.distance_squared_to(at) <= MERGE_DISTANCE * MERGE_DISTANCE:
			return index
	return -1

func _nearest_index(at: Vector2) -> int:
	var result := -1
	var nearest_distance := INF
	for index in range(drops.size()):
		var drop: Dictionary = drops[index]
		var position: Vector2 = drop.get("position", Vector2.ZERO)
		var distance := position.distance_squared_to(at)
		if distance < nearest_distance:
			nearest_distance = distance
			result = index
	return result
