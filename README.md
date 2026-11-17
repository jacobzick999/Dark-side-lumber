# Dark-side-lumber
Only here
<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:09a2df84f481def799e97ca11a1f79a13fdc8f350487a73bdeb2911e16141ba2 -->

## Placed structure rotation preview

Once this repository is public and `script.lua` is on its `main` branch, run this in a Roblox client environment that supports `loadstring` and `game:HttpGet`. Private repositories cannot be fetched anonymously with this URL:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/jacobzick999/Dark-side-lumber/main/script.lua"))()
```

Select **SELECT STRUCTURE** and click or tap a placed structure. The panel looks for a structure model in Lumber Tycoon 2's `PlayerModels` container and excludes boxed items. Enter an angle in degrees and use the plus or minus buttons to preview rotation around its local X, Y, or Z axis. Select **CANCEL** to stop selecting, drag the panel by its title, use **_** to minimize or **+** to restore it, and **X** to close it.

This is a client-side preview. Server-side rotation and saving of placed structures have not been implemented or verified. The game may overwrite the preview, and it may not be visible to other players.

<!-- /coderabbit-ai-generated:v1 -->
