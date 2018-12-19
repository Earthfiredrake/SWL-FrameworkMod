# SWL-FrameworkMod
Basic skeleton mod using my framework as a backend. Provides a basic configuration of the framework, demonstrating most of the basic features and suitable for expansion into a full mod.

## Out of the Box
+ VTIO and GUI Edit Mode compatible icon on the topbar
+ Interface and setting windows ready to have content set
+ Per character settings saved and loaded
+ Support for versioning, localization, tagged chat output

## First Steps
+ You will need Flash Pro CS5, CS5.5 or CS6 (support both xfl files and actionscript 2.0)
+ Open FrameworkMod/FrameworkMod.xfl
+ Under the File menu, select ActionScript Settings
+ Update the library paths to point to your copies of the SWL and CLIK APIs
+ Save (Flash Pro doesn't autosave on build)
+ Again in the File menu, select Publish
+ Check for compiler errors. Flash Pro tends to create a broken .swf file if there are errors
+ Copy the .swf file from the project root, and the contents of the config directory into a FrameworkMod folder inside the SWL mods directory
+ Launch the game and look for a green box on the topbar

## Second Steps
Due to potential versioning conflicts, and a number of static convenience wrappers, it is important that each mod use a unique namespace to isolate the common framework code. The easiest way to do this is with a program that will do text replacement on multiple files (I use Notepad++ for this). There will also be several files and folders that will require renaming.
+ Instances of "efd" (including the folder in root) should be replaced with a short author identifying prefix
+ Near the bottom of Mod.as (formerly in efd/FrameworkMod/lib) the DevName variable should be changed to use your own alias (Using an ingame character name allows one debug text system to work, but also publishes that name so people might start to recognize you)
+ This is a good place to make a backup commit, as the current changes can be shared across all your mods, while the next step should be repeated for each mod written
+ Instances of "FrameworkMod" should be replaced with the name for your mod
+ Files and folders that will need renaming can be found in (old directory names) efd (two levels deep) and FrameworkMod(including some xml files in LIBRARY subfolders)
