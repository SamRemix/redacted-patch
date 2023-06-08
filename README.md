# **Black Ops II Redacted patch**

## **Installation**

Download [zm_patch.gsc](https://github.com/SamRemix/scripts/blob/master/zm_patch.gsc) and put it in `Redacted_LAN\data\scripts` folder.

## **Features**

Some features are disabled by default because they are not allowed for playing world record games.

### General

- Fixed strafe & backwards speed

### Hud

- Timer
- Round timer
- Trap timer
- SPH
- Health bar
- Zombie Counter
- Velocity meter
- Box hits tracker


## **Categories**

This patch is meant to be used during games of **high round**, **no power** & **speedruns**.

For playing **first room** games, you have to edit file like this:

```cpp
onplayerspawned() {
  ...

  // MOVEMENT
  level.config["firstroom_movement"] = true;

  ...
}
```

It will set the strafe speed to 80% and the backwards speed to 70%.