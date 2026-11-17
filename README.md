# Back Gesture Android — RootHide prototype

Target build: RootHide Theos, arm64e package, iOS deployment target 15.0.

## What this prototype attempts
- Recognizes horizontal gestures starting at either screen edge in injected app processes.
- Draws a black liquid/drop indicator that tracks the finger.
- Attempts UIKit navigation pop or modal dismissal when the gesture passes a threshold.

## RootHide packaging
This project uses the official RootHide developer guidance:
- Install the RootHide fork of Theos.
- Build with `THEOS_PACKAGE_SCHEME=roothide`.
- RootHide packages use a relocated jbroot layout; do not relabel a standard rootless package as RootHide.

## Important runtime limitation
RootHide Bootstrap does not inject tweaks into every process automatically. Enable injection for target apps in Bootstrap's App List. This prototype is an app-process experiment; it does not promise a system-wide SpringBoard gesture. RootHide's documented default behavior does not inject into SpringBoard by default.

## Safety and status
This is an experimental, untested prototype, not a stable release. It can conflict with app-native edge gestures and custom navigation stacks. Test only with a way to disable the tweak from Bootstrap/Sileo. iOS 26.0 runtime compatibility has not yet been verified on-device.
