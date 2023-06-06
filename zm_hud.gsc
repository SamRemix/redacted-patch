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

  // MOVEMENT
  level.config["firstroom_movement"] = false;

  for(;;) {
	  self waittill("spawned_player");
      
    flag_wait("initial_blackscreen_passed");
    
    // MOVEMENT
    self set_movement();

    wait .05;
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