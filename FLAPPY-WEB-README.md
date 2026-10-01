# Flappy Web for iPhone

A small, unofficial WKWebView app that opens https://flappybird.io/.
The game is loaded from its website, requires internet access, and is not bundled or copied into this app.

## Download and install

1. Open Actions > Build Flappy Web IPA in this repository.
2. Run the workflow on main, or open a successful run.
3. Download the FlappyWeb-unsigned-ipa artifact and extract its ZIP.
4. Sign FlappyWeb-unsigned.ipa using your chosen iPhone sideloading method.

The device IPA is unsigned and cannot be installed directly until it is signed and provisioned.
It targets arm64 iPhones running iOS 15 or later. It is not a Windows or iOS Simulator executable.
The simulator build is separate and is used only by the workflow for a launch and page-load smoke test.
The smoke test does not verify gameplay, sound, or installation on a physical phone.

The refresh button reloads the game. No Apple credentials are stored or required by the build workflow.
The workflow uses Apple's compiler and SDK already installed on GitHub's macOS runner.
It also uploads a simulator screenshot and logs as FlappyWeb-build-evidence.
Artifacts are retained for 30 days; download them or rerun the workflow before they expire.

## Files

- FlappyWeb.m: native app and web view.
- Info.plist: bundle metadata.
- build-ios.sh: compile the device or simulator app.
- AppIcon60x60@2x.png and AppIcon60x60@3x.png: original wrapper icons.
- .github/workflows/build-flappy-ipa.yml: build, smoke test, and upload.

This wrapper is not affiliated with the game or website owner.
