# Donkey Kong

Analogue Pocket port of Donkey Kong, refreshed against the current [MiSTer-devel/Arcade-DonkeyKong_MiSTer](https://github.com/MiSTer-devel/Arcade-DonkeyKong_MiSTer) core and wrapper behavior where applicable.

## Status

* High score save support is wired through the APF nonvolatile slot.
* DIP-style game settings are exposed in Core Settings.
* Packaged asset presets include standard Donkey Kong sets, Donkey Kong Junior, Foundry/Pest Place, and Radar Scope mode selection.
* Radar Scope still requires you to provide a matching `radarscp.rom` image yourself.

## Attribution

```
---------------------------------------------------------------------------------
-- 
-- Arcade: Donkey Kong port to MiSTer by Sorgelig
-- 18 April 2018
-- 
---------------------------------------------------------------------------------
-- 
-- dkong Copyright (c) 2003 - 2004 Katsumi Degawa
-- T80   Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org) All rights reserved
-- T48   Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org) All rights reserved
-- 
```

## ROM Instructions

ROM files are not included. Use [mra-tools-c](https://github.com/sebdel/mra-tools-c/) to build the required ROM images, then place them in `/Assets/donkeykong/common`.

Examples:

* `dkong.rom` for standard Donkey Kong sets and most hacks
* `dkongjr.rom` for Donkey Kong Junior
* `dkongf.rom` or `dkongex.rom` variants can be mapped through the packaged Foundry/Pest Place asset presets if you generate matching ROM names
