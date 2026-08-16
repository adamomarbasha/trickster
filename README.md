# Trickster 🎩

A personal iOS magic utility that turns the iPhone’s physical volume buttons into discreet secret inputs.

Trickster supports two performance modes:

* **Number Mode** — secretly enter a two-digit number.
* **Card Mode** — secretly enter a playing-card rank and suit.

The selected result is stored locally and exposed to **Apple Shortcuts** through an App Intent, making it easy to trigger a reveal with the iPhone **Action Button**.

No backend.
No Twilio.
No external API.
No monthly service required.

> Trickster is designed as a personal performance utility for your own iPhone and is not intended for App Store distribution.

---

## How It Works

The app uses the iPhone’s physical volume buttons as hidden controls.

### Number Mode

* **Volume Up** increments the first digit.
* **Volume Down** increments the second digit.
* Each digit cycles from `0` through `9`.

Example:

```text
Volume Up × 4
Volume Down × 7

Result: 47
```

Cycle:

```text
0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 0
```

Reset returns Number Mode to:

```text
00
```

---

## Card Mode

Card Mode uses the same physical buttons, but interprets them as card controls.

### Rank

**Volume Up** advances the rank:

```text
A → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → J → Q → K → A
```

Internally, Card Mode also has a reset-only rank state:

```text
0
```

### Suit

**Volume Down** advances the suit:

```text
♥︎ → ♦︎ → ♠︎ → ♣︎ → ♥︎
```

Internally, Card Mode also has a reset-only suit state:

```text
X
```

So after Reset, Card Mode displays:

```text
0 X
```

The first Volume Up press advances the rank from `0` to `A`.

The first Volume Down press advances the suit from `X` to `♥︎`.

Example:

```text
K ♠︎
```

---

## Number / Card Selector

At the top of the interface is a polished segmented selector:

```text
NUMBER    CARD
```

Switching between the modes changes how the stored inputs are presented and how the Shortcut result is returned.

The selected display mode is saved locally and restored when the app launches again.

---

## Independent Card State

Card Mode does not simply reinterpret the two numeric digits.

It maintains its own persisted state:

```text
card.rankIndex
card.suitIndex
```

Rank values:

```text
0 = Reset state
1 = A
2 = 2
3 = 3
...
10 = 10
11 = J
12 = Q
13 = K
```

Suit values:

```text
0 = X
1 = ♥︎
2 = ♦︎
3 = ♠︎
4 = ♣︎
```

This keeps Card Mode deterministic and independent from Number Mode.

---

## Reset Behavior

Reset is designed to restore both modes cleanly.

### Number Mode

```text
00
```

### Card Mode

```text
0 X
```

The reset logic uses a short reset guard so state-change callbacks do not accidentally advance the card immediately after resetting.

This prevents issues such as:

```text
Reset
→ A ♥︎
```

when the expected state is:

```text
Reset
→ 0 X
```

---

## Practice Mode

Practice Mode visibly displays the current secret.

### Number Mode

Shows the two-digit result prominently:

```text
47
```

### Card Mode

Shows the current playing card:

```text
K ♠︎
```

The interface uses a premium glass/liquid-inspired design with:

* large animated typography
* glass surfaces
* subtle gradients
* soft glow
* smooth transitions
* elegant card presentation
* responsive value animations
* native SwiftUI effects

---

## Stealth Mode

Stealth Mode hides the secret result while preserving all input behavior.

You can still use:

* Volume Up
* Volume Down
* Number Mode
* Card Mode
* persistent state
* Apple Shortcuts

without visibly revealing the selected value.

This is intended for live performance situations where the screen should remain discreet.

---

## Volume Button Controls

Trickster does not modify the meaning of the physical buttons at the low-level input layer.

The existing volume detection feeds the app state:

```text
Volume Up
    ↓
First input

Volume Down
    ↓
Second input
```

The current display mode decides how those inputs are interpreted.

### Number Mode

```text
Volume Up   → first digit
Volume Down → second digit
```

### Card Mode

```text
Volume Up   → next rank
Volume Down → next suit
```

---

## Volume Button Reliability

iOS does not expose public APIs such as:

```swift
volumeUpPressed()
volumeDownPressed()
```

Trickster instead observes system media-volume changes.

The implementation uses:

* `AVAudioSession`
* `AVAudioSession.outputVolume`
* `MPVolumeView`
* direction detection
* debounce / cooldown handling
* system-volume recentering

The hidden `MPVolumeView` is:

```text
tiny
offscreen
non-interactive
single-instance
```

to prevent it from blocking SwiftUI touches.

The observer also uses bounded retries when waiting for a key window.

---

## Single-Step Volume Handling

To reduce accidental double increments from a single hardware press, Trickster uses:

* a cooldown state
* a debounce interval
* a minimum volume delta
* protection while volume is being recentered

This helps ensure:

```text
one physical press
=
one increment
```

as consistently as iOS allows.

---

## Persistent Storage

Trickster stores its state locally using `UserDefaults`.

Important persisted values include:

```text
magic.combinedDigits
card.rankIndex
card.suitIndex
displayModePreference
```

This allows the app and Apple Shortcuts to share the latest result.

No cloud database is required.

---

## Apple Shortcuts Integration

Trickster exposes an App Intent:

```text
Get Magic Number
```

Despite the name, the action returns the current result based on the selected mode.

### Number Mode

Example:

```text
47
```

### Card Mode

Example:

```text
K ♠︎
```

### Reset state in Card Mode

```text
0 X
```

The App Intent reads the same persisted values used by the main interface, so the Shortcut result matches what the app shows.

---

## Action Button Workflow

On an iPhone with an Action Button, the intended workflow is:

```text
Open Trickster
    ↓
Secretly enter value with volume buttons
    ↓
Value is stored locally
    ↓
Hold Action Button
    ↓
Shortcut runs
    ↓
Get Magic Number
    ↓
Send Message
    ↓
Recipient receives the reveal
```

---

## Create the Shortcut

Open the **Shortcuts** app on your iPhone.

Create a new shortcut with:

```text
Get Magic Number
        ↓
Send Message
```

For the **Send Message** action:

1. Tap the Message field.
2. Choose **Select Variable**.
3. Select the output from **Get Magic Number**.
4. Choose the desired recipient.
5. Disable **Show When Run** if available and appropriate.
6. Name the Shortcut:

```text
Trick Number
```

Then assign it to the Action Button:

```text
Settings
→ Action Button
→ Shortcut
→ Trick Number
```

---

## Shortcut Output Examples

### Number Mode

App:

```text
47
```

Shortcut returns:

```text
47
```

### Card Mode

App:

```text
Q ♦︎
```

Shortcut returns:

```text
Q ♦︎
```

### Card Mode after Reset

App:

```text
0 X
```

Shortcut returns:

```text
0 X
```

---

## Premium UI

The interface is inspired by modern glass, liquid, and motion-based UI design.

Visual inspiration includes concepts from:

https://github.com/DavidHDev/canvas-ui

The Canvas UI library itself is **not imported into the app**.

Instead, similar visual ideas are recreated natively using SwiftUI.

The app uses techniques such as:

* SwiftUI gradients
* glass-style surfaces
* blur
* animated transitions
* glow
* native materials
* smooth value morphing
* premium typography
* subtle ambient effects

The goal is to make the app feel like a polished performance tool rather than a debug utility.

---

## Architecture

```text
Physical Volume Buttons
        ↓
VolumeButtonObserver
        ↓
MagicNumberViewModel
        ↓
MagicNumberStore
        ↓
Persistent UserDefaults
        ↓
        ├── SwiftUI Interface
        │
        └── GetMagicNumberIntent
                 ↓
            Apple Shortcuts
                 ↓
            Send Message
```

Card Mode also maintains its own persisted rank and suit indices.

---

## Technologies

Built with:

* Swift
* SwiftUI
* App Intents
* Apple Shortcuts
* AVFoundation
* MediaPlayer
* UserDefaults
* native iOS haptics
* Xcode

---

## Repository Structure

```text
trickster/
└── ios/
    └── MagicNumber/
        ├── MagicNumber.xcodeproj
        └── MagicNumber/
            ├── App/
            ├── Assets.xcassets/
            ├── Models/
            ├── Services/
            ├── Utilities/
            ├── ViewModels/
            ├── Views/
            └── Info.plist
```

Important files include:

```text
MagicNumberApp.swift
ContentView.swift
PracticeModeView.swift
StealthModeView.swift
SettingsView.swift
MagicNumberViewModel.swift
MagicNumberStore.swift
VolumeButtonObserver.swift
GetMagicNumberIntent.swift
AppSettings.swift
Haptics.swift
```

---

## Running the App

### Requirements

* Mac
* Xcode
* iPhone
* Apple ID
* physical iPhone for volume-button testing

Open the project:

```bash
cd trickster
open ios/MagicNumber/MagicNumber.xcodeproj
```

---

## Install on Your iPhone

You do not need to publish Trickster to the App Store.

In Xcode:

1. Connect your iPhone to your Mac.
2. Unlock the iPhone.
3. Trust the Mac if prompted.
4. Select the `MagicNumber` project.
5. Select the `MagicNumber` target.
6. Open **Signing & Capabilities**.
7. Enable **Automatically manage signing**.
8. Select your Personal Team.
9. Select your iPhone as the run destination.
10. Press **Run**.

If prompted, enable Developer Mode:

```text
Settings
→ Privacy & Security
→ Developer Mode
```

You may also need to trust the developer profile:

```text
Settings
→ General
→ VPN & Device Management
```

---

## Free Apple ID Installation

A paid Apple Developer account is not required for personal use.

With a free Apple ID, Xcode can install the app directly onto your iPhone.

The free development signing profile commonly expires after roughly:

```text
7 days
```

After that:

1. Connect the iPhone to your Mac.
2. Open the project in Xcode.
3. Press **Run** again.

During the valid signing period, the app can be launched normally from the iPhone Home Screen.

Your Mac does not need to stay connected.

---

## Basic Testing

### Number Mode

Reset the app.

Press:

```text
Volume Up × 4
Volume Down × 7
```

Expected result:

```text
47
```

Run `Get Magic Number`.

Expected Shortcut output:

```text
47
```

---

## Card Mode Testing

Reset Card Mode.

Expected:

```text
0 X
```

Press Volume Up once.

Expected rank:

```text
A
```

Press Volume Down once.

Expected result:

```text
A ♥︎
```

Continue pressing Volume Up to cycle:

```text
A → 2 → 3 → ... → Q → K → A
```

Continue pressing Volume Down to cycle:

```text
♥︎ → ♦︎ → ♠︎ → ♣︎ → ♥︎
```

Run `Get Magic Number`.

The returned value should exactly match the card shown in the app.

---

## Troubleshooting

### UI is frozen

The hidden `MPVolumeView` should remain:

```text
offscreen
1 × 1
isUserInteractionEnabled = false
```

There should only be one instance.

### Volume button does nothing

Make sure:

* you are using a real iPhone
* the app is active in the foreground
* the observer has had a moment to initialize
* no unusual external audio route is interfering

### One press increments twice

The app includes debounce and cooldown logic.

If necessary, adjust:

```text
debounceInterval
minimumDelta
cooldown timing
```

carefully in `VolumeButtonObserver.swift`.

### Shortcut returns an old value

Open the app and change the value again.

The store persists changes immediately.

### Shortcut cannot find Get Magic Number

Try:

1. Run the newest build of Trickster.
2. Open Shortcuts.
3. Search for:

```text
Get Magic Number
```

If an old version is already inside your Shortcut, delete that action and add it again.

### Shortcut opens Messages without the value

Make sure the **Message** field contains the output variable from:

```text
Get Magic Number
```

rather than plain text.

---

## GitHub

Clone:

```bash
git clone https://github.com/adamomarbasha/trickster.git
cd trickster
```

After making changes:

```bash
git add .
git commit -m "Update Trickster"
git push
```

Example feature commit:

```bash
git add .
git commit -m "Polish Trickster UI and add card mode"
git push
```

---

## Privacy

Trickster does not require:

* accounts
* analytics
* tracking
* advertising
* external APIs
* Twilio
* backend servers
* external databases

The secret state is stored locally on the iPhone.

Messages are sent through Apple Shortcuts and Messages.

---

## Limitations

The app relies on public iOS volume APIs rather than dedicated volume-button callbacks.

Possible factors that can affect behavior include:

* Bluetooth audio
* AirPods
* AirPlay
* CarPlay
* phone calls
* external audio routes
* future iOS behavior changes

For reliable performances, test the exact device setup beforehand.

---

## License

See [LICENSE](LICENSE).

---

## Disclaimer

Trickster is a personal utility created for entertainment and magic-performance purposes.

Use messaging functionality responsibly and only with participants who have agreed to receive the message.

---

# Trickster

**Two buttons. One secret. One reveal. 🎩**
