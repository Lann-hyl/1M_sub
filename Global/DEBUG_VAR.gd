extends Node
## Use this file to set variables that will basically give you god mode [br]
##
## This is useful for testing and debugging [br]
## ! Nothing in this file should be set to true for the release [br]
## All variable names should start with DEBUG_ [br]
## ! All variables should be const [br]

## Player can move freely on the map without having to finish the current event or move in the range of its normal movement
const DEBUG_FREE_MOVEMENT: bool = false

## Player can skip the placeholder events by pressing on the skip button
const DEBUG_SKIP_EVENT: bool = false

## Allow player to add and remove items from the inventory with buttons [br]
## in the inventory UI
const DEBUG_ACTIVE_INVENTORY_DEBUG_BUTTONS : bool = false

## Temporary debug option to print the number of each generated event type [br]
## TO BE REMOVED after implmentation
const DEBUG_PRINT_EVENT_COUNT : bool = false

## Makes player start with a lot of gold
const DEBUG_START_WITH_A_LOT_OF_GOLD : bool = false

## Used in tests to use the same enemy group all the time
## It can't be a const because we change it inside the tests
var DEBUG_USE_TEST_ENEMY_GROUP: bool = false
