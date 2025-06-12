extends Node
## Initializes randomness for the game.


# Set this to a value other than -1 to have deterministic randomness.
# Make sure to set back to -1 when done testing!
const GAME_SEED = -1
var randomNumberGenerator : RandomNumberGenerator

func _ready() -> void:
	set_game_seed(GAME_SEED)
	randomNumberGenerator = RandomNumberGenerator.new()
	randomNumberGenerator.seed = GAME_SEED


func set_game_seed(given_seed: int = -1) -> void:
	var set_seed: int = given_seed
	if set_seed == -1:
		set_seed = randi()
	seed(set_seed)
	
	print("Seed set to: " + str(set_seed))

func get_random_int(min: int, max: int) -> int:
	return randomNumberGenerator.randi_range(min, max) 
