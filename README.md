# **Black Ops II Redacted patch**

## **Installation**

Download [zm_patch.gsc](https://github.com/SamRemix/scripts/blob/master/zm_patch.gsc) and put it in `Redacted_LAN\data\scripts` folder.

## **Features**

Some features are disabled by default because they are not allowed for playing world record games.

### General

- Fixed strafe & backwards speed
- Fixed trap & Jetgun *(enabled on Victis maps & Mob of the Dead)*
- Full bank *(enabled on Victis maps)*
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

| Element             | Dvar                | Default  |
| :------------------ | :------------------ | :------- |
| Timer + Round timer | `timers` + `0 1`    | Enabled  |
| Zombies remaining   | `remaining` + `0 1` | Disabled |
| Velocity meter      | `velocity` + `0 1`  | Disabled |
| Box hits tracker    | `box_hits` + `0 1`  | Disabled |

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

- Break after round 10

You can change first box break round by editing this line:

```cpp
onplayerspawned() {
  ...

  level.config["first_box_break_round"] = 10;

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