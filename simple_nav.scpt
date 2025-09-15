tell application "Xcode"
	activate
	open "/Users/ramonbieri/swapshop_clean/ios/Runner.xcworkspace"
end tell

delay 5

tell application "System Events"
	tell process "Xcode"
		-- Klicke auf Build Settings Tab
		click button "Build Settings" of tab group 1 of group 1 of splitter group 1 of window 1
		
		delay 2
		
		-- Suche nach "Base Configuration"
		keystroke "f" using {command down}
		delay 1
		keystroke "Base Configuration"
		delay 2
		keystroke return
	end tell
end tell 