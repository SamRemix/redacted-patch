#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_magicbox;
#include common_scripts\utility;
#include maps\mp\_utility;

init() {
  level thread onplayerconnect();
}

onplayerconnect() {
  level waittill("connecting", player);
  player thread onplayerspawned();
}

onplayerspawned() {
  level endon("game_end");
  level endon("game_ended");
  self endon("disconnect");

  level.config = array();

  // HUD
  level.config["timers"] = true;
  level.config["sph"] = true;
  level.config["sph_round_start"] = 50;
  level.config["velocity"] = false;
  level.config["box_hits"] = false;

  // FIRST BOX
  level.config["first_box"] = true;
  level.config["first_box_break_round"] = 10;

  // MOVEMENT
  level.config["firstroom_movement"] = false;

  // FIRST BOX
  level thread start_box_location();
  level thread first_box_weapons();

  thread set_dvars();

  level thread hud_alpha_controller();

  for(;;) {
    self waittill("spawned_player");
    
    flag_wait("initial_blackscreen_passed");
    
    // HUD
    self thread timer_hud();
    self thread round_timer_hud();
    self thread sph_hud();
    self thread velocity_meter_hud();
    self thread box_hits_tracker_hud();
    self thread rayguns_average_hud();

    // PERSISTENT UPGRADES
    self thread fill_bank();
    
    if (is_victis_map() || is_mob_of_the_dead()) {
      level.round_start_custom_func = ::fix_zombies_health;
    }
    
    // MOVEMENT
    self set_movement();

    wait .05;
  }
}

/*

  DVARS

*/

init_dvar(dvar) {
  if (level.config[dvar]) {
    setDvar(dvar, 1);
  } else {
    setDvar(dvar, 0);
  }
}

hud_alpha_controller() {
  while (1) {
  // TIMER - ROUND TIMER
  if (isDefined(level.timer) && isDefined(level.round_timer)) {
    if (!getDvarInt("timers")) {
      level.timer.alpha = 0;
      level.round_timer.alpha = 0;
    } else if (getDvarInt("timers") == 1) {
				level.timer.alpha = 1;
			  level.round_timer.alpha = 1;
      }
    }

		// VELOCITY METER
    if (isDefined(level.velocity_meter)) {
      if (!getDvarInt("velocity")) {
				level.velocity_meter.alpha = 0;
      } else if (getDvarInt("velocity") == 1) {
				level.velocity_meter.alpha = 1;
      }
    }

		// BOX HITS TRACKER
    if (isDefined(level.box_hits_tracker) && isDefined(level.rayguns_average)) {
      if (!getDvarInt("box_hits")) {
				level.box_hits_tracker.alpha = 0;
				level.rayguns_average.alpha = 0;
      } else if (getDvarInt("box_hits") == 1) {
				level.box_hits_tracker.alpha = 1;
				level.rayguns_average.alpha = 1;
      }
    }

		wait .05;
	}
}

set_dvars() {
	init_dvar("timers");
	init_dvar("velocity");
	init_dvar("box_hits");
}

/*

  UTILITY FUNCTIONS

*/

is_survival_map() {
  if (level.scr_zm_ui_gametype_group == "zsurvival" || level.script == "zm_nuked") {
    return true;
  }

  return false;
}

is_victis_map() {
  victis_maps = array("zm_transit", "zm_highrise", "zm_buried");

  foreach(map in victis_maps) {
    if (level.script == map) {
      return true;
    }
  }
  
	return false;
}

is_mob_of_the_dead() {
	if (level.script == "zm_prison") {
		return true;
  }

	return false;
}

get_zombies_left() {
	return get_round_enemy_array().size + level.zombie_total;
}

/*

  HUD

*/

timer_hud() {  
  level.timer = createServerFontString("big", 1.8);
  level.timer setPoint("TOPLEFT", "TOPLEFT", -46, -34);

  level.timer.alpha = 0;

  level.timer setTimerUp(0);
}

keep_displaying_round_time(time) {
  level endon("start_of_round");

  while (1) {
    self setTimer(time - .1);
    
    wait .25;
  }
}

round_timer_hud() {
  level waittill("start_of_round");

  level.round_timer = createServerFontString("big", 1.6);
  level.round_timer setPoint("TOPLEFT", "TOPLEFT", -46, -14);
  
  level.round_timer.color = (1, .3, .3);
  level.round_timer.alpha = 0;
  
  while (1) {
	  round_start = int(getTime() / 1000);
    level.round_timer setTimerUp(0);

	  level waittill("end_of_round");

	  level.round_end = int(getTime() / 1000) - round_start;

	  level.round_timer keep_displaying_round_time(level.round_end);
	}
}

display_sph(sph) {
  level endon("start_of_round");

  while (1) {
    self setValue(sph);

    wait .25;
  }
}

sph_hud() {
  if (!level.config["sph"]) {
    return;
  }

  while (level.round_number < level.config["sph_round_start"]) {
    wait .1;
  }

  level waittill("start_of_round");

  sph = createServerFontString("big", 1.4);
  sph setPoint("TOPLEFT", "TOPLEFT", -46, 28);

  sph.hidewheninmenu = 1;
  sph.label = &"SPH: ";
  sph.alpha = 0;

  while (1) {
    hordes = get_zombies_left() / 24;

	  level waittill("end_of_round");
    
    sph.alpha = 1;

    second_per_horde = int((level.round_end / hordes) * 100) / 100;

	  sph display_sph(second_per_horde);

    sph.alpha = 0;
  }
}

velocity_meter_hud() {
  level.velocity_meter = createServerFontString("big", 1.5);
  level.velocity_meter setPoint(undefined, "TOP", 0, -18);

	level.velocity_meter.hidewheninmenu = 1;
  level.velocity_meter.alpha = 0;

  while (1) {
	  velocity = int(length(self getvelocity()));
    
    level.velocity_meter setValue(velocity);

    wait .05;
  }
}

get_box_hit() {
	while (1) {
    while (self.zbarrier getzbarrierpiecestate(2) != "opening") {
      wait .05;
    }

		level.box_hits++;

    while (self.zbarrier getzbarrierpiecestate(2) == "opening") {
      wait .05;
    }
	}
}

box_hits_tracker_hud() {
  if (!is_survival_map()) {
    return;
  }

  level.box_hits_tracker = createServerFontString("big", 1.5);
  level.box_hits_tracker setPoint("TOPRIGHT", "TOPRIGHT", 58, -10);

  level.box_hits_tracker.alpha = 0;
	level.box_hits = 0;

	foreach(chest in level.chests) {
		chest thread get_box_hit();
  }

  while (1) {
    while (!level.box_hits) {
      wait .05;
    }

    level.box_hits_tracker.label = &"Box hits: ";

    level.box_hits_tracker setValue(level.box_hits);

    wait .05;
  }
}

is_raygun() {
  while (1) {
    while (self.zbarrier.weapon_string != "ray_gun_zm" && self.zbarrier.weapon_string != "raygun_mark2_zm") {
      wait .05;
    }

    level.rayguns++;

    while (self.zbarrier.weapon_string == "ray_gun_zm" || self.zbarrier.weapon_string == "raygun_mark2_zm") {
      wait .05;
    }
  }
}

rayguns_average_hud() {
  if (!is_survival_map()) {
    return;
  }

  level.rayguns_average = createServerFontString("big", 1.2);
  level.rayguns_average setPoint("TOPRIGHT", "TOPRIGHT", 58, 8);

  level.rayguns_average.alpha = 0;
	level.rayguns = 0;

	foreach(chest in level.chests) {
		chest thread is_raygun();
  }

  while (1) {
    while (level.rayguns < 2) {
      wait .05;
    }

    level.rayguns_average.label = &"Rayguns avg: ";

    average = int((level.box_hits / level.rayguns) * 100) / 100;

    level.rayguns_average setValue(average);

    wait .05;
  }
}

/*

  FIRST BOX

*/

start_box_location() {
	switch(level.scr_zm_map_start_location) {
		case "town":
			start_box_location = "town_chest_2";
			break;

		case "prison":
			start_box_location = "cafe_chest";
			break;

		case "tomb":
			start_box_location = "bunker_tank_chest";
			break;

		default:
			break;
	}
    
	for(i = 0; i < level.chests.size; i++) {
    if(level.chests[i].script_noteworthy == start_box_location) {
    	good_chest_index = i;
		} else if(level.chests[i].hidden == 0) {
    	bad_chest_index = i;
		}     	
	}

	if(isdefined(bad_chest_index) && (bad_chest_index < good_chest_index)) {
		level.chests[bad_chest_index] hide_chest();
		level.chests[bad_chest_index].hidden = 1;

		level.chests[good_chest_index].hidden = 0;
		level.chests[good_chest_index] show_chest();
		level.chest_index = good_chest_index;
	}	
}

first_box_weapons() {
  if (!level.config["first_box"]) {
    return;
  }

	switch(level.script) {
		case "zm_transit":
		case "zm_nuked":
			box_weapons = array("raygun_mark2_zm", "cymbal_monkey_zm");
			break;

		case "zm_highrise":
			box_weapons = array("cymbal_monkey_zm");
			break;

		case "zm_prison":
			box_weapons = array("raygun_mark2_zm", "blundergat_zm");
			break;

		case "zm_buried":
			box_weapons = array("raygun_mark2_zm", "cymbal_monkey_zm", "slowgun_zm");
			break;

		case "zm_tomb":
			box_weapons = array("raygun_mark2_zm", "cymbal_monkey_zm", "m32_zm");
			break;
			
		default:
			break;
	}

	level.special_weapon_magicbox_check = undefined;

	foreach(weapon in level.zombie_weapons) {
		weapon.is_in_box = 0;
	}

	box_hits = -1;

	while((box_hits < box_weapons.size) && (level.round_number < level.config["first_box_break_round"] + 1)) {
		if(box_hits < level.chest_accessed) {
			if(level.chest_accessed != box_weapons.size) {
				gun = box_weapons[box_hits + 1];
				level.zombie_weapons[gun].is_in_box = 1;
			}

			box_hits++;		
		}

		wait 2;
	}

	level.special_weapon_magicbox_check = ::box_weapon_check;

	keys = getarraykeys(level.zombie_include_weapons);

	foreach(weapon in keys) {
		if(level.zombie_include_weapons[weapon] == 1) {
			level.zombie_weapons[weapon].is_in_box = 1;
		}
	}
}

box_weapon_check(weapon) {
	if (self has_weapon_or_upgrade(weapon)) {
		return 0;
	}

	switch (weapon) {
		case "ray_gun_zm":
			if (self has_weapon_or_upgrade("raygun_mark2_zm")) {
				return 0;
			}

		case "raygun_mark2_zm":
			if (self has_weapon_or_upgrade("ray_gun_zm")) {
				return 0;
			}
	}
	
	return 1;
}

/*

  PERSISTENT UPGRADES

*/

fill_bank() {
  if (is_victis_map()) {
    self.account_value = level.bank_account_max;
  }
}

fix_zombies_health() {
  round_155 = 1044606723;
  
  if (level.zombie_health <= round_155) {
    return;
  }

  level.zombie_health = round_155;

  foreach (zombie in get_round_enemy_array()) {
    if (zombie.health > round_155) {
      zombie.heath = round_155;
    }
  }
}

/*

  MOVEMENT

*/

set_movement() {
  if (!level.config["firstroom_movement"]) {
    setdvar("player_backSpeedScale", .9);
    setdvar("player_strafeSpeedScale", 1);
  } else {
    setdvar("player_backSpeedScale", .7);
    setdvar("player_strafeSpeedScale", .8);
  }

  setdvar("player_sprintStrafeSpeedScale", 1);
  setdvar("g_speed", 190);
}
