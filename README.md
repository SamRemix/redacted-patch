# **Black Ops II Redacted patch**

Patch for playing **world record** games in Black Ops II Zombies.

## **Installation**

Download [zm_patch.gsc](https://github.com/SamRemix/scripts/blob/master/zm_patch.gsc) and put it in `Redacted_LAN\data\scripts` folder.

## **Features**

For optimization and logic, some features are disabled on maps that don't need them. For example, "Full bank" and "Fridge weapon" are enabled on Victis maps only.

### General

- Fixed strafe & backwards speed
- Fixed trap & Jetgun
- [Perma perks](#perma-perks)
- Full bank
- [Fridge weapon](#fridge-weapon)
- [Start box location](#start-box-location)
- [First box weapons](#first-box-weapons) *(disabled after round 10)*

### Hud

- Timer
- Round timer
- [SPH](#sph) *(enabled from round 50)*
- Velocity meter
- Box hits tracker *(can be enabled on survival maps only)*
  - \+ Rayguns average

### Dvars

| Element             | Dvar               | Default  |
| :------------------ | :----------------- | :------- |
| Timer + Round timer | `timers` + `0 1`   | Enabled  |
| SPH                 | `sph` + `0 1`      | Enabled  |
| Velocity meter      | `velocity` + `0 1` | Disabled |
| Box hits tracker    | `box_hits` + `0 1` | Disabled |

## **Notes**

### **Categories**

This patch is supposed to be used during games of **high round**, **no power** and **speedruns**.

For playing **first room** games, you have to edit file like this:

```cpp
onplayerspawned() {
  ...

  level.config["firstroom_movement"] = true;

  ...
}
```

It will set the strafe speed to 80% and the backwards speed to 70%.

### **Perma perks**

List of perma perks:

- Revive
- Better headshots
- Tombstone
- Mini-jug
- Flopper
- Cash back
- Sniper points
- Insta kill
- Pistol points
- Double Points

### **Fridge weapon**

| Map      | Weapon      |
| :------- | :---------- |
| Tranzit  | War machine |
| Die Rise | AN-94       |
| Buried   | War machine |

You can change the fridge weapon by setting a value like this:

```cpp
onplayerspawned() {
  ...

  level.config["fridge_weapon"] = "m16";

  ...
}
```

possible value:

- `an94`
- `m32`
- `m16` - *especially for **Tranzit no power***
- `mp5` - *especially for **Buried saloon strat** (better mobility)*

It will give you an upgraded version of the weapon (except for mp5 because it's only used for mobility).

### **Start box location**

| Map             | Box location |
| :-------------- | :----------- |
| Town            | Double tap   |
| Mob of the Dead | Cafeteria    |
| Origins         | Generator 2  |

### **First box weapons**

| Map             | Weapons                                   |
| :-------------- | :---------------------------------------- |
| Survival maps   | Raygun mark II, Monkey bombs              |
| Tranzit         | Raygun mark II, Monkey bombs              |
| Die Rise        | Monkey bombs                              |
| Mob of the Dead | Raygun mark II, Blundergat                |
| Buried          | Raygun mark II, Monkey bombs, Paralyzer   |
| Origins         | Raygun mark II, Monkey bombs, War machine |

### **SPH**

- Appears at the end of rounds

You can change SPH round start by editing this line:

```cpp
onplayerspawned() {
  ...

  level.config["sph_round_start"] = 50;

  ...
}
```