# Trickster 🎩

A personal iOS utility built for performing magic tricks using the iPhone's physical volume buttons.

Trickster lets you secretly enter either a **two-digit number** or a **playing card** using the Volume Up and Volume Down buttons. The result is stored locally and can be retrieved through **Apple Shortcuts**, allowing the iPhone's **Action Button** to trigger a shortcut that sends the result through Messages.

No backend.
No Twilio.
No external API.
No monthly service required.

> Trickster is designed as a personal iPhone utility and is not intended for App Store distribution.

---

## ✨ How It Works

The app uses the iPhone's physical volume buttons as discreet controls.

### Number Mode

* **Volume Up** controls the first digit.
* **Volume Down** controls the second digit.

Example:

```text
Volume Up × 4
Volume Down × 7

Result: 47
```

Each digit cycles through:

```text
0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 0
```

---

### Card Mode

Card Mode converts the same two physical controls into a playing card.

**Volume Up** controls the card rank:

```text
2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → J → Q → K → A
```

**Volume Down** controls the suit:

```text
♠︎ → ♥︎ → ♦︎ → ♣︎
```

Example:

```text
Volume Up → K
Volume Down → ♠︎

Result: K ♠︎
```

---

## 🃏 Modes

Trickster includes two input modes:

```text
NUMBER     CARD
```

### Number

Displays a two-digit value such as:

```text
47
```

### Card

Displays a playing card such as:

```text
K ♠︎
```

The mode can be changed from the selector at the top of the app.

---

## 🎭 Practice & Stealth

### Practice Mode

Practice Mode visibly displays the current value so you can learn and test the controls.

Useful for:

* rehearsing the trick
* testing volume-button input
* confirming the current value
* checking card rank and suit

### Stealth Mode

Stealth Mode hides the secret value while still accepting physical volume-button input.

The stored value continues updating normally and remains available to Apple Shortcuts.

This allows the performer to operate the app without revealing the selected number or card.

---

## 📲 Apple Shortcuts Integration

Trickster exposes an App Intent to Apple Shortcuts:

```text
Get Magic Number
```

This action retrieves the most recently stored secret value.

For Number Mode:

```text
47
```

For Card Mode, the app can expose the appropriate stored representation depending on the implementation.

The value is stored locally so Shortcuts can retrieve it even when the app has been backgrounded after entering the secret.

---

## ⚡ Action Button Setup

On supported iPhones, such as iPhone 15 Pro and newer models with an Action Button, Trickster works especially well with Apple Shortcuts.

Example workflow:

```text
Trickster
    ↓
Volume buttons secretly enter value
    ↓
Value stored locally
    ↓
Hold Action Button
    ↓
Shortcut runs
    ↓
Get Magic Number
    ↓
Send Message
    ↓
Recipient receives result
```

### Create the Shortcut

Open **Shortcuts** on your iPhone.

Create a new shortcut and add:

```text
Get Magic Number
        ↓
Send Message
```

In the **Send Message** action:

1. Set the message content to the output of `Get Magic Number`.
2. Select the desired recipient.
3. Disable **Show When Run** if available and appropriate.
4. Name the shortcut:

```text
Trick Number
```

Then go to:

```text
Settings
→ Action Button
→ Shortcut
→ Trick Number
```

Now holding the Action Button can trigger the shortcut.

> Messages and Shortcuts behavior is ultimately controlled by iOS. Depending on system permissions and configuration, iOS may occasionally request confirmation.

---

## 🎨 Interface

The interface is designed as a premium, minimal magic utility with inspiration from modern glass and liquid UI styles.

Visual elements include:

* dark premium appearance
* glass-style surfaces
* subtle gradients
* animated value transitions
* fluid motion
* elegant typography
* discreet Stealth Mode
* responsive haptic feedback
* polished Number/Card mode switching

The design is inspired in part by the visual concepts found in [Canvas UI](https://github.com/DavidHDev/canvas-ui), recreated natively using SwiftUI.

Canvas UI itself is **not included or embedded** in this project.

---

## 🏗 Architecture

```text
Physical Volume Buttons
        ↓
VolumeButtonObserver
        ↓
MagicNumberStore
        ↓
Persistent Local Storage
        ↓
SwiftUI Interface
        +
App Intent
        ↓
Apple Shortcuts
        ↓
Optional Send Message Action
```

There is no remote server involved.

---

## 🔒 Privacy

Trickster does not require:

* user accounts
* analytics
* advertising
* tracking
* Twilio
* external SMS providers
* external APIs
* remote databases
* backend servers

The secret value is stored locally on the device.

Any message sent using Apple Shortcuts is handled by Apple's Shortcuts and Messages systems.

---

## 🛠 Technologies

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

## 📁 Project Structure

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
VolumeButtonObserver.swift
MagicNumberStore.swift
GetMagicNumberIntent.swift
MagicNumberViewModel.swift
ContentView.swift
PracticeModeView.swift
StealthModeView.swift
SettingsView.swift
```

---

## 🚀 Running the App

### Requirements

* Mac
* Xcode
* iPhone
* Apple ID
* iOS device with physical volume buttons

A physical iPhone is required to properly test volume-button behavior.

### Open the Project

From Terminal:

```bash
cd trickster
open ios/MagicNumber/MagicNumber.xcodeproj
```

Or open:

```text
ios/MagicNumber/MagicNumber.xcodeproj
```

directly in Xcode.

---

## 📱 Install on Your Personal iPhone

You do **not** need to publish Trickster to the App Store.

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

If requested on the iPhone, enable:

```text
Settings
→ Privacy & Security
→ Developer Mode
```

You may also need to trust the developer profile under:

```text
Settings
→ General
→ VPN & Device Management
```

---

## 🆓 Free Apple ID Installation

A paid Apple Developer account is not required for personal testing.

With a free Apple ID, Xcode can install the application directly onto your personal device.

The development signing profile generally expires after approximately **7 days**.

After expiration:

1. Connect the iPhone to the Mac again.
2. Open the project in Xcode.
3. Press **Run**.

The app can then be used normally again.

During the valid signing period, the Mac does **not** need to remain connected.

You can launch Trickster directly from the iPhone Home Screen like any other app.

---

## 🔊 Volume Button Detection

iOS does not expose a public API such as:

```swift
volumeUpPressed()
volumeDownPressed()
```

Trickster instead observes changes to the system media volume.

The implementation uses:

* `AVAudioSession`
* `outputVolume` observation
* `MPVolumeView`
* volume direction detection

Conceptually:

```text
Volume increases
→ Volume Up

Volume decreases
→ Volume Down
```

The system volume is recentered when necessary so both physical buttons can continue generating detectable changes.

---

## ⚠️ Volume Button Limitations

Because this relies on system media-volume behavior, there are unavoidable iOS limitations.

### The app should be active

For reliable physical volume-button detection, Trickster should be open in the foreground while entering the secret value.

Once the value has been stored, Apple Shortcuts can retrieve that value afterward.

### Audio routes can affect behavior

Volume detection may behave differently while connected to:

* AirPods
* Bluetooth speakers
* AirPlay
* CarPlay
* external audio devices
* active phone calls

For performances, testing the exact setup beforehand is recommended.

### iOS controls system behavior

Future iOS updates may alter how system volume observation behaves.

Trickster uses public Apple APIs only.

---

## 🧪 Basic Test

Open Trickster on a physical iPhone.

### Number Test

Reset the value.

Press:

```text
Volume Up × 4
Volume Down × 7
```

Expected result:

```text
47
```

Then run:

```text
Get Magic Number
```

from Shortcuts.

Expected output:

```text
47
```

---

## 🃏 Card Test

Switch to Card Mode.

Use Volume Up to cycle through ranks.

Use Volume Down to cycle through suits.

Confirm that the displayed card updates correctly while preserving the existing volume-button input behavior.

---

## 🎩 Performance Example

A basic performance workflow could be:

```text
1. Open Trickster.

2. Enter the secret value using the physical
   volume buttons.

3. Keep the phone naturally in your hand.

4. Hold the Action Button.

5. "Trick Number" runs.

6. Apple Shortcuts retrieves the stored result.

7. The result is sent to the configured recipient.
```

---

## 🐛 Troubleshooting

### Volume buttons do nothing

Make sure:

* you are using a physical iPhone
* Trickster is open in the foreground
* the app has been running for a moment after launch
* no unusual external audio route is active

Try reopening the app if iOS interrupted the audio session.

### UI becomes unresponsive

The hidden `MPVolumeView` used for volume handling should:

* remain tiny
* remain offscreen
* have user interaction disabled
* never cover the SwiftUI interface

### Shortcut cannot find `Get Magic Number`

Try:

1. Run the latest version of Trickster once.
2. Open Shortcuts.
3. Search again for:

```text
Get Magic Number
```

If necessary, delete an older instance of the action from the shortcut and add it again.

### Shortcut returns an old value

Open Trickster and change the secret value again.

The app persists changes immediately so the App Intent can retrieve the latest stored result.

### Shortcut opens Messages but does not include the number

Edit the shortcut and make sure the output variable from:

```text
Get Magic Number
```

is inserted into the **Message** field of the `Send Message` action.

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

---

## License

See [LICENSE](LICENSE).

---

## Disclaimer

Trickster is a personal utility created for entertainment and magic-performance purposes.

Use messaging functionality responsibly and only send messages to people who have agreed to participate.

---

# Trickster

**Volume buttons become secret inputs.
Shortcuts becomes the reveal.** 🎩
