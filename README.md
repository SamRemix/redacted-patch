# **Black Ops II Redacted patch**

## **Installation**

Download [zm_patch.gsc](https://github.com/SamRemix/scripts/blob/master/zm_patch.gsc) and put it in `Redacted_LAN\data\scripts` folder.

## **Features**

Some features are disabled by default because they are not allowed for playing world record games.

### General

- Fixed strafe & backwards speed
- Fixed trap & Jetgun *(is enabled on Victis maps & Mob of the Dead only)*
- Full bank *(is enabled on Victis maps only)*
- Start box location
- First box weapons

### Hud

- Timer
- Round timer
- Trap timer *(can be enabled on Mob of the Dead only)*
- SPH
- Health bar
- Zombie Counter
- Velocity meter
- Box hits tracker *(can be enabled on survival maps only)*

### Dvars

| Element             | Dvar               | Default  |
| :------------------ | :----------------- | :------- |
| Timer + Round timer | `timers` + `0 / 1` | Enabled  |
| Velocity meter      | `velocity` + `0/1` | Disabled |
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

### **First box**

| Map             | Weapons                                   |
| :-------------- | :---------------------------------------- |
| Survival maps   | Raygun mark II, Monkey bombs              |
| Die Rise        | Monkey bombs                              |
| Mob of the Dead | Raygun mark II, Blundergat                |
| Buried          | Raygun mark II, Monkey bombs, Paralyzer   |
| Origins         | Raygun mark II, Monkey bombs, War machine |

By default, first box will break after round 20, you can change it by editing this line:

```cpp
onplayerspawned() {
  ...

  level.config["revert_round"] = 20;

  ...
}
```