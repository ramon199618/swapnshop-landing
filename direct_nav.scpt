tell application "Xcode"
	activate
	open "/Users/ramonbieri/swapshop_clean/ios/Runner.xcworkspace"
end tell

-- Warte bis Xcode geladen ist
delay 3

tell application "System Events"
	tell process "Xcode"
		-- Klicke auf das Runner-Projekt im Navigator
		click button 1 of row 1 of outline 1 of scroll area 1 of splitter group 1 of window 1
		
		-- Warte kurz
		delay 1
		
		-- Klicke auf das Runner-Target
		click button 1 of row 2 of outline 1 of scroll area 1 of splitter group 1 of window 1
		
		-- Warte kurz
		delay 1
		
		-- Klicke auf den Build Settings Tab
		click button "Build Settings" of tab group 1 of group 1 of splitter group 1 of window 1
		
		-- Warte kurz
		delay 1
		
		-- Scrolle nach oben zu Base Configuration
		repeat 5 times
			key code 126 -- Pfeil nach oben
			delay 0.2
		end repeat
	end tell
end tell 