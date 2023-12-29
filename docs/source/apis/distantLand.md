# distantLand

To use the library it needs to be `require`d first.

```lua
local distantLand = require("distant land parser")
```

## Functions

### `distantLand.parseLand`

Parses `distantland\world` file into `niTriShape`s and attaches them to a parent `niNode`. The parent `niNode` is returned.

This function executes almost instantly, so performance shouldn't be a concern here.

```lua
local distantLand = require("distant land parser")
local land = distantLand.parseLand()
```

**Returns**:

* `result` ([niNode](https://mwse.github.io/MWSE/types/niNode/))

***

### `distantLand.parseStatics`

Parses `distantland\statics\static_meshes` and `distantland\statics\usage.data` files. Returns a root `niNode` with a root node for each static type. In essence, this root node contains all of the static objects used in distant land. The root node also contains root node called `"InteriorWorldspaces"` for interior cells distant statics. The child nodes of the interior root have the name that corresponds to Morrowind cell the statics are used for.

On Intel® Core™ i3-1115G4, with Morrowind.esm, Tribunal.esm and Bloodmoon.esm, this function takes around 25 seconds to execute.

```lua
local distantLand = require("distant land parser")
local statics = distantLand.parseStatics(...)
```

**Parameters**:

* `saveBinary` (boolean): If true, the root nodes will be exported to the Morrowind install directory as the following files:
	* `"STATIC_AUTO_ROOT.nif"`
	* `"STATIC_NEAR_ROOT.nif"`
	* `"STATIC_FAR_ROOT.nif"`
	* `"STATIC_VERY_FAR_ROOT.nif"`
	* `"STATIC_GRASS_ROOT.nif"`
	* `"STATIC_TREE_ROOT.nif"`
	* `"STATIC_BUILDING_ROOT.nif"`
	* `"InteriorWorldspaces.nif"`

**Returns**:

* `result` ([niNode](https://mwse.github.io/MWSE/types/niNode/))

***

### `distantLand.parseStaticMeshes`

Parses `distantland\statics\static_meshes`file. Returns an array of `niNode`s for each distant static object.

On Intel® Core™ i3-1115G4, with Morrowind.esm, Tribunal.esm and Bloodmoon.esm, this function takes around 3 seconds to execute.

```lua
local distantLand = require("distant land parser")
local statics = distantLand.parseStaticMeshes(...)
```

**Parameters**:

* `saveBinary` (boolean): If true, exports all the statics meshes placed at the origin (0, 0, 0) as `"static_meshes.nif"` to the Morrowind install directory.

**Returns**:

* `result` ([niNode[]](https://mwse.github.io/MWSE/types/niNode/))
