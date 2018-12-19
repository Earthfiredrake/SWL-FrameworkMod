// Copyright 2017-2018, Earthfiredrake
// Released under the terms of the MIT License
// https://github.com/Earthfiredrake/SWL-FrameworkMod

import flash.geom.Point;

import gfx.utils.Delegate;

import efd.FrameworkMod.lib.LocaleManager;
import efd.FrameworkMod.lib.Mod;
import efd.FrameworkMod.lib.sys.ConfigManager;
import efd.FrameworkMod.lib.sys.config.Versioning;
import efd.FrameworkMod.lib.sys.ModIcon;
import efd.FrameworkMod.lib.sys.VTIOHelper;
import efd.FrameworkMod.lib.sys.Window;
import efd.FrameworkMod.lib.util.WeakDelegate;

class efd.FrameworkMod.FrameworkMod extends Mod {
	private function GetModInfo():Object {
		return {
			// Debug flag at top so that commenting out leaves no hanging ','
			// Enables Debug.TraceMsg and Debug.DevMsg calls (sets DebugUtils.DebugMode which can be used to toggle other debug code)
			// Comment out for release builds
			Debug : true,
			Name : "FrameworkMod", // Used for DV naming and certain UI elements
			Version : "0.0.1.alpha", // Used by the versioning system to process updates and for some UI elements
			Subsystems : {
				// These may be removed if unneeded, note that Config is a common dependency for other modules
				// InitObjs are provided with a default set of parameters, see the individual modules for additional configuration options
				Config : {
					// Stores settings and handles serialization to/from the game's setting files (depending on configuration of Modules.xml and *Prefs.xml, see readme for details)
					// Handles versioning of mod and framework, permitting changes to settings based on updates
					// Provides a config window with content specified by the library symbol [ModName]ConfigWindowContent and the gui/ConfigWindowContent.as codefile
					Init : ConfigManager.Create,
					InitObj : { }
				},
				Icon : {
					// Creates a mod icon, using the library symbol [ModName]Icon as the image
					// Handles icon layout and positioning, tooltips and optional mouse handlers
					Init : ModIcon.Create,
					InitObj : {
						LeftMouseInfo : IconMouse_ToggleInterfaceWindow,
						RightMouseInfo : IconMouse_ToggleConfigWindow
					}
				},
				LinkVTIO : {
					// Registers with VTIO compatible mod containers, including passing icon layout responsibility and providing a DV to link to the container's list interface
					Init : VTIOHelper.Create,
					InitObj : {
						ConfigDV : "efdShowFrameworkModConfigWindow" // Handcoded because it's a pain to extract from the Config subsystem from here and could be replaced with an "Enabled" DV if a toggle makes more sense
					}
				},
				Interface : {
					// Provides an interface window with content specified by the library symbol [ModName][WindowName]Content and the codefile linked to that symbol (default is gui/InterfaceWindowContent.as)
					Init : Window.Create,
					InitObj : {
						WindowName : "InterfaceWindow",
						LoadEvent : WeakDelegate.Create(this, InterfaceWindowLoaded), // Load event in this file that passes required data to the window when it's opened
						ResizeLimits : { // Removing this will prevent resizing
							Min : new Point(200, 200),
							Max : new Point(1500, 1000)
						}
					}
				}
			}
		};
	}

	/// Initialization
	public function FrameworkMod(hostMovie:MovieClip) {
		super(GetModInfo(), hostMovie); // Pass ModInfo initialization structure to framework
		Debug.TraceMsg("FrameworkMod constructor");
		// SystemsLoaded object is a checklist of essential components that have to be loaded for the mod to work
		// It can also be used during the load to ensure that things are initialized in the proper order
		// By default it contains:
		//   LocalizedText (requires that the LocaleManager successfully initialize and load Strings.xml)
		//   Config (if specified in ModInfo, requires that the ConfigWrapper be successfully populated from the user's settings)
		// Additional fields can be added if there are other things, such as essential data files, which the mod needs to operate and may fail to load
		// A call to UpdateLoadProgress("FieldName") will set a field to true, and if there are no others waiting to load, will trigger the ModLoaded events
		// If any field remains false the mod will not consider itself loaded and will resist attempts to enable it
		// attempting to manually set the "[DVPrefix][ModName]Enabled" DV will list the names of any fields that were not cleared
		
		// Ex: SystemsLoaded.EssentialData = false; // (must be loaded later)

		// Ingame debug menu registers variables that are initialized here, but not those initialized at class scope

		InitializeConfig();

		// Sample loading of datafile (EssentialData.xml)
		// EssentialDataLoader = LoadXmlAsynch("EssentialData", Delegate.create(this, LoadEssentialData));		
		
		// Any other onetime initialization (DVs, signal hooking, etc.)
	}

	// Define setting names and default values for serialization in game settings files
	private function InitializeConfig():Void {
		Debug.TraceMsg("Initializing config");
		// A list of: Config.NewSetting("SettingName", [default value]); calls
		// Config supports a wide range of common types, including arrays and generic Objects with named fields
		// Note: If doing an update which removes an old setting, but requires the old value to be loaded as part of the update, it has to still be initialized here
		//       They can be removed from the Config object after the base call in LoadComplete to remove them from the serialized data
	}

	// Fires once the Config object has loaded the saved settings, though prior to any version updates being applied
	private function ConfigLoaded():Void {
		Debug.TraceMsg("Config has been loaded");
		// Can tweak the config without triggering config changed events, or otherwise initialize stuff
		super.ConfigLoaded(); // Hooks the config changed event handler and updates the SystemsLoaded variable, which possibly triggers the ModLoaded event chain
	}

	// Handles updates of the SystemsLoaded variable, and can be used to trigger initialization based on other components being already loaded
	private function UpdateLoadProgress(loadedSystem:String):Boolean {
		Debug.TraceMsg("Essential component loaded: " + loadedSystem);
		return super.UpdateLoadProgress(loadedSystem);
	}

	// Sample XML loader callback (usage and connected SystemsLoaded flag commented out in constructor)
	private function LoadEssentialData(success:Boolean):Void {
		if (success) {
			var xmlRoot:XMLNode = EssentialDataLoader.firstChild;
			// Parse XML into internal datastructure
			UpdateLoadProgress("EssentialData");
		} else { Debug.ErrorMsg("Unable to load essential data", {fatal : true}); } // Sends error message and locks down the mod
		delete EssentialDataLoader;
	}

	// Config changed event handler, hooked when base ConfigLoaded is called
	private function ConfigChanged(setting:String, newValue, oldValue):Void {
		switch(setting) {
			case "SettingName":
				// Make any proactive changes that have to be made because of a change in settings
				// Passive settings can generally be polled on demand and don't need to be handled here
				break;
			default:
				super.ConfigChanged(setting, newValue, oldValue); // Most internal settings are either polled or handled via DV, so this is a no-op
				break;
		}
	}

	// Once loading has successfully completed (All SystemsLoaded fields set to true)
	private function LoadComplete():Void {
		Debug.TraceMsg("Load complete");
		super.LoadComplete(); // Triggers versioning updates and permits enabling
		// Do any post Update work here (such as removing now deprecated settings)
	}

	// Runs once, the very first time the mod is initialized
	private function InstallMod():Void {
		// Is available, I haven't found a use for it
	}
		
	// Handle version specific updates upon successful load
	// Note: Only called in the event that an upgrade did occur that was within the window of allowable upgrade versions
	private function UpdateMod(newVersion:String, oldVersion:String):Void {
		/* Sample
		if (Versioning.CompareVersions("NewVersion", oldVersion) > 0) {
			// Adjust saved settings to reflect updated config layout 
		}
		*/
	}

	// Triggered when the mod is activated or deactivated by either the user, or the game (happens more than you might expect)
	private function Activate():Void { Debug.TraceMsg("Mod activated"); }
	private function Deactivate():Void { Debug.TraceMsg("Mod deactivated"); }

	// Event handler to send data to interface window for display
	private function InterfaceWindowLoaded(windowContent:Object):Void {
		windowContent.SetData(/* pass any required parameters */);
	}

	/// Variables
	private var EssentialDataLoader:XML;
}

// Useful functions from baseclass not mentioned above:
//   ChatMsg("Message") - sends Message to system chat
//   Debug.TraceMsg("Message") - sends Message to system chat and log if Debug mode is active (set at either compile or runtime)
//   Debug.DevMsg("Message") - as Trace, but will also trigger if the current character's name is the same as DevName in Mod.as regardless of Debug mode
//   For ease of access, static versions of all Debug functions can be accessed through DebugUtils.[FuncName]S 
//     ChatMsg is also static, and can be accessed in other locations as Mod.ChatMsg
//   Config.GetValue("SettingName") - Gets the current value of a previously defined setting