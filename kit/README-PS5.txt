Class of '09: The Flip Side - unofficial PS5 homebrew runtime
Ported by CatsAndGats; Flip Side adaptation follows the same clean-room engine.

WHAT THIS IS
------------
A native PS5 homebrew runtime for Class of '09: The Flip Side. It is not a
Sony-supported product and it is not Ren'Py. The runtime interprets bytecode
exported from the copy of the game installed in this folder and draws the game
with the PS5's VideoOut framebuffer, DualSense input, and AudioOut output.

FOLDER CONTENTS
---------------
  eboot.bin                     the signed PS5 application
  sce_sys/param.json            title metadata (title ID PPSA09011)
  sce_sys/icon0.png             launcher icon
  sce_module/libc.prx           clean-room libc runtime used by the app
  assets/script.json            exported game bytecode
  assets/game/                  your copy of the PC game (887 files)
  GAME_FILES.txt                exact list of the game files in assets/game

INSTALL ON THE PS5
------------------
1. Copy the complete PPSA09011 folder, keeping its name, to:

       /data/homebrew/PPSA09011/

   You can use an FTP client on port 2121 or the file manager included with
   your homebrew loader. Keep the folder name and the directory structure.
2. Launch "Class of '09: The Flip Side" from ShadowMountPlus or another
   compatible homebrew loader. The loader mounts this folder at /app0.
3. Save files, thumbnails, and discovered endings are written to the title's
   writable /download0/saves area. They are not stored in the app folder.

Do not rename the folder or move eboot.bin out of it: the console mounts the
whole folder, and the runtime reads its data from /app0/assets.

WHICH ORIGINAL GAME FILES ARE USED
----------------------------------
The runtime uses your own legally obtained copy of Class of '09: The Flip Side.
The exact relative paths are listed in GAME_FILES.txt. Copy them from the PC
install's game/ folder into assets/game/ with the same relative paths, for
example:

    PC:      Class of 09 The Flip Side\game\images\home jecka ext day.jpg
    PS5:     /data/homebrew/PPSA09011/assets/game/images/home jecka ext day.jpg

The staged files are about 970 MB: images, audio, GUI art, fonts, the
smoke/shadow/new-message/sparkle animation frames, the laptop screen, and the
game's original VP8/Vorbis .webm videos. Caches, saves, translations, .rpyc
files, and unused fonts are not included. Videos are decoded at runtime by
libvpx and libvorbis; no frame packs are needed.

Generated data:

  assets/script.json              exported by tools/export_script.py
  assets/game/                    staged copy of the game's runtime files

CONTROLS
--------
  Cross           advance / confirm
  Circle          back one line (the BACK pill bottle)
  Square          ending tracker (from the main menu)
  D-pad           navigate
  Options/Start   in-game menu
  Any button      skip the startup logo or a movie

SAVES
-----
36 slots in nine pages of four, with thumbnails. The save/load screens use the
game's own slot artwork. Loading resumes timed pauses and movie transitions
past the wait instead of freezing on them.

LEGAL
-----
Class of '09: The Flip Side and its assets are the property of their
developers and publishers. This folder is for personal use with a copy of the
game you own. Do not upload or redistribute this folder or its assets. The
runtime contains no jailbreak, exploit, or DRM-circumvention code.

Unofficial fan project. Not affiliated with the developers, publishers, or Sony.
