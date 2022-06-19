extends Area


class_name Pickup

enum PICKUP_TYPES {
	MACHINE_GUN,
	MACHINE_GUN_AMMO,
	SHOT_GUN,
	SHOT_GUN_AMMO,
	ROCKET_LAUNCHER,
	ROCKET_LAUNCHER_AMMO,
	HEALTH
}

export(PICKUP_TYPES) var pickup_type
export var ammo = 10
