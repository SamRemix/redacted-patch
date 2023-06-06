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

  // MOVEMENT
  level.config["firstroom_movement"] = false;

  for(;;) {
	  self waittill("spawned_player");
      
    flag_wait("initial_blackscreen_passed");
    
    // HUD
    self thread timer_hud();
    self thread round_timer_hud();
    
    // MOVEMENT
    self set_movement();

    wait .05;
  }
}

display(display) {
  self fadeOverTime(.3);

  if (display) {
    self.alpha = 1;
  } else {
    self.alpha = 0;
  }
}

timer_hud() {
  if (!level.config["timer"]) {
    return;
  }
  
  timer = createServerFontString("big", 1.8);
  timer setPoint("TOPLEFT", "TOPLEFT", -46, -34);

  timer.alpha = 0;

  timer display(true);

  timer setTimerUp(0);
}

keep_displaying_value(value) {
  level endon("end_game");
  level endon("start_of_round");

  while (true) {
    self setTimer(value - .1);

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

  round_timer display(true);
  
  while (1) {
	  round_start = int(getTime() / 1000);
    round_timer setTimerUp(0);

	  level waittill("end_of_round");

	  level.round_end = int(getTime() / 1000) - round_start;

	  round_timer keep_displaying_value(level.round_end);
	}
}

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