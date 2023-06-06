# **Black Ops II Redacted patch**

Features enabled by default are allowed to play world record games.

## **Installation**

### Redacted LAN

Download [zm_patch.gsc](https://github.com/SamRemix/scripts/blob/master/zm_patch.gsc) and put it in `Redacted_LAN\data\scripts` folder.

## **Features**

- Fixed strafe & backwards speed
- Game / round timer
- Display sph at round end
- Health bar
- Zombie Counter

### HUD

| Feature        | Default  |
| :------------- | :------- |
| Timer          | Enabled  |
| Round timer    | Enabled  |
| SPH            | Disabled |
| Health bar     | Disabled |
| Zombie Counter | Disabled |

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