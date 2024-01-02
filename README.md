# VIP Plugin for Counter-Strike 1.6 (AMX Mod X)

## Description
This AMX Mod X plugin for Counter-Strike 1.6 manages VIP players and provides features such as displaying VIP status on the scoreboard and HUD, handling player connections and disconnections, and loading VIP data from a file.

## Features
- **VIP Management:** Identify VIP players based on Steam ID or name.
- **Scoreboard Integration:** Modify player attributes on the scoreboard according to their VIP status.
- **HUD Display:** Show VIP-related messages on the in-game HUD.
- **Expiration Handling:** Check and mark expired VIP entries in the data file.
- **Configuration:** Easily configure the plugin through a configuration file.

## Configuration
Edit the `vip.ini` file in the `addons/amxmodx/configs` directory to manage VIP data and configure plugin settings.

## Commands
- **/vips:** Toggle VIP display on the client's side.
- **amx_reloadvips:** Reload VIP data from the configuration file.

## Usage
1. Add VIP Steam IDs or names to the `vip.ini` file.
2. Use the `/vips` command to toggle the display of VIPs.

## Native Functions
- `isPlayerVip(id)`: Check if a player is a VIP.

### Creating a Plugin with VIP Advantages

1. **Create a New Plugin:**
   - Start by creating a new AMX Mod X plugin. You can use a similar structure as the VIP plugin but focus on the specific features or advantages you want to provide to VIP players.

2. **Include VIP Plugin:**
   - In your new plugin, include the VIP plugin header file to access the `isPlayerVip` native. Add the following line to the top of your new plugin:
     ```pawn
     #include <vip>
     ```

3. **Use `isPlayerVip` Native:**
   - Utilize the `isPlayerVip` native in your plugin to check if a player is a VIP. For example:
     ```pawn
     if (isPlayerVip(player_id)) {
         // Player is a VIP, provide advantages here
     } else {
         // Player is not a VIP
     }
     ```

4. **Implement VIP Advantages:**
   - Implement the specific advantages or features that VIP players should have. This could include additional weapons, health, armor, or any other in-game benefits.

### Example Use Case:

Let's say you want to create a plugin that gives VIP players additional health. Here's a simple example:

```pawn
#include <amxmodx>
#include <vip>

#define PLUGIN "VIPHealth"
#define VERSION "1.0"
#define AUTHOR "Your Name"

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_clcmd("say /viphealth", "GiveVIPHealth");
}

public GiveVIPHealth(id) {
    if (isPlayerVip(id)) {
        set_user_health(id, get_user_health(id) + 50); // Give VIP players 50 additional health
        client_cmd(id, "say You received additional health as a VIP!");
    } else {
        client_cmd(id, "say You are not a VIP!");
    }
}
```

In this example, the plugin adds a command (`/viphealth`) that VIP players can use to receive an additional 50 health. The `isPlayerVip` native is used to check if the player is a VIP before providing the extra health.