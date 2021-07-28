# namedSpawnables (Now with all stock makes _and_ configs!)

### A BeamMP Plugin to provide generic name translation and chat-based context for all stock spawnables and configs on BeamMP Servers

![Example of namedSpawnables](https://i.imgur.com/RIm0OvV.png)

## Installation:

#### 1. Place the namedSpawnables folder in:
`.../Resources/Server/`

---

#### 2. Optionally, for information printed in the Messages UI app, add the namedSpawnables.zip in:
`.../Resources/Client/`

![Example of namedSpawnables in Messages UI app](https://i.imgur.com/heN4OlA.png)

---

#### 3. Optionally, configure if desired.

Within namedSpawnables.lua, see a Configure section near the top:

```lua
...
--Configure
local showOnVehicleSpawn = true
local showOnVehicleEdited = true
local showOnVehicleDeleted = true
...
```

To turn off any of these conditions on which information will print, set to false.

Additionally, if you want to add custom/modded spawnables, see the bottom of the paths/models/makes tables for formatting examples:

```
	--add additional paths as a key value pair
	--make_configName = "path/to/config.pc"
```

```
	--add additional models as a key value pair
	--make_configName = "Model Name"
```

```
	--add additional makes as a key value pair
	--genericName = "fullName"
```

---

#### 4. Restart your server to apply changes.
