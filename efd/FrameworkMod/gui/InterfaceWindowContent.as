// Copyright 2017-2018, Earthfiredrake
// Released under the terms of the MIT License
// https://github.com/Earthfiredrake/SWL-FrameworkMod

import com.Components.WindowComponentContent;

class efd.FrameworkMod.gui.InterfaceWindowContent extends WindowComponentContent {

	/// Initialization (called in this order)
	private function InterfaceWindowContent() { // Indirect construction only
		super();
	}

	private function configUI():Void {
		// Do any runtime configuration of static elements here
		// Ex: Localized text replacement, focus trap disabling etc.
		super.configUI();
	}

	// Overrides base class, where it's currently a no-op
	// Will be triggered from the mod subclass, through a handler for the window loading event
	public function SetData(/* Specify arguments as needed */):Void {
		// Do any data -> UI binding required to render the interface
	}

	/// Window state updates
	// Used to resize content when outer window is resized
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
}
