# **Black Ops II Redacted patch**

## **Installation**

Download [zm_patch.gsc](https://github.com/SamRemix/scripts/blob/master/zm_patch.gsc) and put it in `Redacted_LAN\data\scripts` folder.

## **Features**

Some features are disabled by default because they are not allowed for playing world record games.

### General

- Fixed strafe & backwards speed
- Fixed trap & Jetgun *(is enabled on Victis maps & Mob of the Dead)*
- Full bank *(is enabled on Victis maps)*
- [Start box location](#start-box-location)
- [First box weapons](#first-box-weapons)

### Hud

- Timer
- Round timer
- Trap timer *(can be enabled on Mob of the Dead)*
- [SPH](#sph)
- Health bar
- Zombie Counter
- Velocity meter
- Box hits tracker *(can be enabled on survival maps)*
  - \+ Rayguns average

### Dvars

| Element             | Dvar               | Default  |
| :------------------ | :----------------- | :------- |
| Timer + Round timer | `timers` + `0 1`   | Enabled  |
| Velocity meter      | `velocity` + `0 1` | Disabled |
| Box hits tracker    | `box_hits` + `0 1` | Disabled |

## **Notes**

### **Categories**

This patch is meant to be used during games of **high round**, **no power** & **speedruns**.

For playing **first room** games, you have to edit file like this:

```cpp
onplayerspawned() {
  ...

  level.config["firstroom_movement"] = true;

  ...
}
```

It will set the strafe speed to 80% and the backwards speed to 70%.

### **Start box location**

| Map             | Box location        |             |
| :-------------- | :------------------ | :---------- |
| Town            | `town_chest_2`      | Double tap  |
| Mob of the Dead | `cafe_chest`        | Cafeteria   |
| Origins         | `bunker_tank_chest` | Generator 2 |

### **First box weapons**

| Map             | Weapons                                   |
| :-------------- | :---------------------------------------- |
| Survival maps   | Raygun mark II, Monkey bombs              |
| Die Rise        | Monkey bombs                              |
| Mob of the Dead | Raygun mark II, Blundergat                |
| Buried          | Raygun mark II, Monkey bombs, Paralyzer   |
| Origins         | Raygun mark II, Monkey bombs, War machine |

- Break after round 20

You can change first box limit round by editing this line:

```cpp
onplayerspawned() {
  ...

  level.config["revert_round"] = 20;

  ...
}
```

### **SPH**

- Enabled from round 50
- Appears at the end of rounds

You can change SPH round start by editing this line:

```cpp
onplayerspawned() {
  ...

  level.config["sph_round_start"] = 50;

  ...
}
```