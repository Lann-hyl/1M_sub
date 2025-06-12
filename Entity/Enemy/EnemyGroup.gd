class_name EnemyGroup extends Node

## The scene of each enemy
@export var enemy_list_packed_scene: Array[PackedScene]

## The position of those enemies on the screen [br]
## @experimental
## This could be changed to be automatically calculated maybe
@export var positions: Array[Vector2]

var enemy_list: Array[Entity]
