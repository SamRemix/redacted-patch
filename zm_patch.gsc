#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

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
  level.config["timer"] = true;
  level.config["round_timer"] = true;
  level.config["trap_timer"] = false;
  level.config["sph"] = false;
  level.config["health_bar"] = false;
  level.config["zombies_remaining"] = false;
  level.config["velocity_meter"] = false;
  level.config["box_hits_tracker"] = false;

  // MOVEMENT
  level.config["firstroom_movement"] = false;

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
    level thread box_hits_tracker();

    // PERSISTENT UPGRADES
    self thread fill_bank();
    
    // MOVEMENT
    self set_movement();

    wait .05;
  }
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

get_zombies_left() {
	return get_round_enemy_array().size + level.zombie_total;
}

/*

  HUD

*/

timer_hud() {
  if (!level.config["timer"]) {
    return;
  }
  
  timer = createServerFontString("big", 1.8);
  timer setPoint("TOPLEFT", "TOPLEFT", -46, -34);

  timer.alpha = 0;

  timer set_visibility(true);

  timer setTimerUp(0);
}

keep_displaying_round_time(time) {
  level endon("start_of_round");

  while (true) {
    self setTimer(time - .1);
    
    wait .25;
  }
}

round_timer_hud() {
  if (!level.config["round_timer"]) {
    return;
  }

  level waittill("start_of_round");

  round_timer = createServerFontString("big", 1.6);
  round_timer setPoint("TOPLEFT", "TOPLEFT", -46, -14);
  
  round_timer.color = (1, .3, .3);
  round_timer.alpha = 0;

  round_timer set_visibility(true);
  
  while (1) {
	  round_start = int(getTime() / 1000);
    round_timer setTimerUp(0);

	  level waittill("end_of_round");

	  level.round_end = int(getTime() / 1000) - round_start;

	  round_timer keep_displaying_round_time(level.round_end);
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

	while(1) {
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

  while (true) {
    self setValue(sph);

    wait .25;
  }
}

sph_hud() {
  if (!level.config["sph"]) {
    return;
  }

  level waittill("start_of_round");

  sph = createServerFontString("big", 1.4);
  sph setPoint("TOPLEFT", "TOPLEFT", -46, 28);

  sph.hidewheninmenu = 1;
  sph.label = &"sph: ";

  sph.alpha = 0;

  while(1) {
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


  while(1) {
    remaining set_visibility(true);
    
    if (get_zombies_left() == 0) {
      remaining set_visibility(false);
    }

	  remaining setValue(get_zombies_left());

    wait .05;
  }
}

velocity_meter_hud() {
  if (!level.config["velocity_meter"]) {
    return;
  }

  velocity_meter = createServerFontString("big", 1.5);
  velocity_meter setPoint(undefined, "TOP", 0, -18);

	velocity_meter.hidewheninmenu = 1;

  while (1) {
	  velocity = int(length(self getvelocity()));
    
    velocity_meter setValue(velocity);

    wait .05;
  }
}

get_box_hits() {
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

box_hits_tracker() {
  if (!level.config["box_hits_tracker"] || !is_survival_map()) {
    return;
  }

  box_hits = createServerFontString("big", 1.5);
  box_hits setPoint("TOPRIGHT", "TOPRIGHT", 58, -10);

  box_hits.label = &"Box hits: ";

	level.hits = 0;

	foreach(chest in level.chests) {
		chest thread get_box_hits();
  }

  while (1) {
    box_hits setValue(level.hits);

    wait .05;
  }
}

/*

  PERSISTENT UPGRADES

*/

fill_bank() {
  if (is_victis_map()) {
    self.account_value = level.bank_account_max;
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
}