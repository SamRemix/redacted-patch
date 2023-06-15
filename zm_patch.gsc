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
  level.config["trap_timer"] = false;
  level.config["sph"] = true;
  level.config["sph_round_start"] = 50;
  level.config["health_bar"] = false;
  level.config["zombies_remaining"] = false;
  level.config["velocity"] = false;
  level.config["box_hits"] = false;

  // FIRST BOX
  level.config["first_box"] = false;
  level.config["revert_round"] = 20;

  // MOVEMENT
  level.config["firstroom_movement"] = false;

  // FIRST BOX
  level thread start_box_location(); // enabled by default
  level thread first_box_weapons();

	thread set_dvars();

	level thread hud_alpha_controller();

  for(;;) {
	  self waittill("spawned_player");
    
    flag_wait("initial_blackscreen_passed");
    
    // HUD
    self thread timer_hud();
    self thread round_timer_hud();
    self thread trap_timer_hud();
    self thread sph_hud();
    self thread health_bar_hud();
    self thread zombies_remaining_hud();
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
		if (!getDvarInt("timers")) {
      if (isDefined(level.timer)) {
				level.timer.alpha = 0;
			}

      if (isDefined(level.round_timer)) {
				level.round_timer.alpha = 0;
			}
		} else if (getDvarInt("timers") == 1) {
      if (isDefined(level.timer)) {
				level.timer.alpha = 1;
			}

      if (isDefined(level.round_timer)) {
				level.round_timer.alpha = 1;
			}
		}

		// VELOCITY METER
		if (!getDvarInt("velocity")) {
      if (isDefined(level.velocity_meter)) {
				level.velocity_meter.alpha = 0;
			}
		} else if (getDvarInt("velocity") == 1) {
      if (isDefined(level.velocity_meter)) {
				level.velocity_meter.alpha = 1;
			}
		}

		// BOX HITS TRACKER
		if (!getDvarInt("box_hits")) {
      if (isDefined(level.box_hits)) {
				level.box_hits.alpha = 0;
			}

      if (isDefined(level.rayguns_average)) {
				level.rayguns_average.alpha = 0;
      }
		} else if (getDvarInt("box_hits") == 1) {
      if (isDefined(level.box_hits)) {
				level.box_hits.alpha = 1;
			}

      if (isDefined(level.rayguns_average)) {
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

set_visibility(visible) {
  self fadeOverTime(.3);

  if (visible) {
    self.alpha = 1;
    return;
  }
  
  self.alpha = 0;
}

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

trap_timer_hud() {
	if(!level.config["trap_timer"] || level.script != "zm_prison") {
		return;
  }

  trap_timer = createServerFontString("big", 1.4);
  trap_timer setPoint("TOPLEFT", "TOPLEFT", -46, 6);

	trap_timer.color = (1, .3, .3);
	trap_timer.alpha = 0;

	while (1) {
		level waittill("trap_activated");

		if(!level.trap_activated) {
			wait .5;

      trap_timer set_visibility(true);
			trap_timer setTimer(50);

			wait 50;

      trap_timer set_visibility(false);
		}
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
  sph.label = &"sph: ";

  sph.alpha = 0;

  while (1) {
    hordes = get_zombies_left() / 24;

	  level waittill("end_of_round");

    sph set_visibility(true);

    second_per_horde = int((level.round_end / hordes) * 100) / 100;

	  sph display_sph(second_per_horde);

    sph set_visibility(false);
  }
}

health_bar_hud() {
  if (!level.config["health_bar"]) {
    return;
  }

  health_bar = createPrimaryProgressbar();
  health_bar setPoint(undefined, "BOTTOM_LEFT", 10, -72);

  health_bar_text = createPrimaryProgressbarText();
  health_bar_text setPoint(undefined, "BOTTOM_LEFT", 10, -86);

  health_bar.hidewheninmenu = 1;
  health_bar.bar.hidewheninmenu = 1;
  health_bar.barframe.hidewheninmenu = 1;
  health_bar_text.hidewheninmenu = 1;

  health_bar.alpha = 0;
  health_bar.bar.alpha = 0;
  health_bar.barframe.alpha = 0;
  health_bar_text.alpha = 0;

  while (1) {
    if (isDefined(self.e_afterlife_corpse) || is_true(self.waiting_to_revive)) {
      health_bar set_visibility(false);
      health_bar.bar set_visibility(false);
      health_bar.barframe set_visibility(false);
      health_bar_text set_visibility(false);
    }

    if (health_bar.alpha == 0) {
      health_bar set_visibility(true);
      health_bar.bar set_visibility(true);
      health_bar.barframe set_visibility(true);
      health_bar_text set_visibility(true);
    }

    health_bar updatebar(self.health / self.maxhealth);
    health_bar_text setValue(self.health);

    wait .05;
  }
}

zombies_remaining_hud() {
  if (!level.config["zombies_remaining"]) {
    return;
  }

  remaining = createServerFontString("big", 1.5);
  remaining setPoint(undefined, "BOTTOM", 0, -18);

  remaining.hidewheninmenu = 1;
  remaining.label = &"Remaining: ";

  remaining.color = (1, 0, 0);
  remaining.alpha = 0;


  while (1) {
    remaining set_visibility(true);
    
    if (get_zombies_left() == 0) {
      remaining set_visibility(false);
    }

	  remaining setValue(get_zombies_left());

    wait .05;
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

		level.hits++;

    while (self.zbarrier getzbarrierpiecestate(2) == "opening") {
      wait .05;
    }
	}
}

box_hits_tracker_hud() {
  if (!is_survival_map()) {
    return;
  }

  level.box_hits = createServerFontString("big", 1.5);
  level.box_hits setPoint("TOPRIGHT", "TOPRIGHT", 58, -10);

  level.box_hits.label = &"Box hits: ";

  level.box_hits.alpha = 0;

	level.hits = 0;

	foreach(chest in level.chests) {
		chest thread get_box_hit();
  }

  while (1) {
    level.box_hits setValue(level.hits);

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

  level.rayguns_average.label = &"Rayguns avg: ";

  level.rayguns_average.alpha = 0;

	level.rayguns = 0;

	foreach(chest in level.chests) {
		chest thread is_raygun();
  }

  while (1) {
    average = int((level.hits / level.rayguns) * 100) / 100;

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
			forced_box_guns = array("raygun_mark2_zm", "cymbal_monkey_zm");
			break;

		case "zm_highrise":
			forced_box_guns = array("cymbal_monkey_zm");
			break;

		case "zm_prison":
			forced_box_guns = array("raygun_mark2_zm", "blundergat_zm");
			break;

		case "zm_buried":
			forced_box_guns = array("raygun_mark2_zm", "cymbal_monkey_zm", "slowgun_zm");
			break;

		case "zm_tomb":
			forced_box_guns = array("raygun_mark2_zm", "cymbal_monkey_zm", "m32_zm");
			break;
			
		default:
			break;
	}

	level.special_weapon_magicbox_check = undefined;

	foreach(weapon in level.zombie_weapons) {
		weapon.is_in_box = 0;
	}

	box_hits = -1;

	while((box_hits < forced_box_guns.size) && (level.round_number < level.config["revert_round"] + 1)) {
		if(box_hits < level.chest_accessed) {
			if(level.chest_accessed != forced_box_guns.size) {
				gun = forced_box_guns[box_hits + 1];
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

	// if (!limited_weapon_below_quota(weapon_key, self, getentarray("specialty_weapupgrade", "script_noteworthy")))
	// 	return "";

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