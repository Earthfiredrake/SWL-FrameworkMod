// Copyright 2017-2018, Earthfiredrake
// Released under the terms of the MIT License
// https://github.com/Earthfiredrake/SWL-FrameworkMod

import com.Components.WindowComponentContent;

import efd.FrameworkMod.lib.sys.config.ConfigWrapper;

// Databinding between Config settings and UI window
// Linked to library symbol: FrameworkModConfigWindowContent
// Baseline sample, for a more complete example see LoreHound

class efd.FrameworkMod.gui.ConfigWindowContent extends WindowComponentContent {

	/// Initialization (triggered in this order)
	private function ConfigWindowContent() { super(); } // Indirect construction only

	// Called by the window initialization routines
	private function configUI():Void {
		// Do any runtime configuration of static elements here
		// Ex: Localized text replacement, focus trap disabling etc.
		super.configUI();
	}
	
	// Called by Config module to link the newly opened window with the current mod state
	// Equivalent to SetData in interface windows (might get renamed to better match base class interface)
	public function AttachConfig(config:ConfigWrapper):Void {
		Config = config; // Cache for later access
		ConfigUpdated(); // Update the UI to reflect initial status
		Config.SignalValueChanged.Connect(ConfigUpdated, this); // Register for notifications when config changes are made

		// Hook up trigger events for UI elements
		// Further initialization for any subforms
	}

	/// State updates
	// Triggered by the Config module whenever any setting's state is changed and used to set initial state
	// Initial seeding and the occasional global update event may call this function with no parameters at all
	// Certain variable types may suppress newValue/oldValue even when setting is specified, use is possible but discouraged
	private function ConfigUpdated(setting:String, newValue, oldValue):Void {
		// For each setting bound to a UI element
		if (setting == "SettingName" || setting == undefined) {
			// Set state of bound UI elements
		}
	}
	
	// Current version does not have resizable config windows, this is informational should that feature be enabled
	// Overrides base class, where it's currently a no-op
	private function SetSize(width:Number, height:Number):Void {
		// Adjust the size/layout of the config UI to fit the new window size
		SignalSizeChanged.Emit(); // Trigger a layout pass		
	}
	
	// Called when window is closed
	// Overrides base class, where it's currently a no-op
	// BUG: Due to a logic issue, directly toggling the DV will skip this; esc stack, x button, and mod icon toggles will trigger this	
	private function Close():Void {
		// Connected Signals will detach automatically, and most sub-items can simply pass out of scope
		// Any other cleanup that needs to be done
	}
	
	/// Sample UI trigger bindings
	// TODO: Data binding objects as a library feature. These are pretty boilerplate which could be simplified
	// Basic checkbox bound to boolean setting
	private function CheckBoxSettingNameSelect(event:Object):Void {
		Config.SetValue("SettingName", event.selected);
	}
	// Basic checkbox bound to boolean flag based setting
	private function CheckBoxFlagSettingNameSelect(event:Object):Void {
		var FlagValue:Number = 1; // Placeholder, generally flags will be defined and imported from elsewhere
		Config.SetValue("FlagSettingName", FlagValue, event.selected);
	}
	// Basic text field bound to string based setting
	private function TextFieldSettingNameChanged(field:TextField):Void {
		Config.SetValue("SettingName", field.text);
	}

	/// Local cached copy
	private var Config:ConfigWrapper;
}
