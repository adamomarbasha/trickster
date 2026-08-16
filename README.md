# Magic Number

A small personal iOS magic utility that converts physical volume-button presses into a two-digit number and sends that number to a configured phone using a secure SMS backend.

> This project is intended for your own iPhone. It is not designed for App Store distribution.

## Screenshots

Add screenshots after running the app:

- `docs/screenshots/practice.png`
- `docs/screenshots/stealth.png`
- `docs/screenshots/settings.png`

## Features

- Volume Up increments the left digit.
- Volume Down increments the right digit.
- Digits cycle from `0...9`.
- Practice Mode shows the two-digit value.
- Stealth Mode hides the value behind an innocuous clock-like screen.
- Stealth Mode can send with a double-tap in the center of the screen.
- SMS is sent through a backend so Twilio credentials never ship in the app.
- Local settings for recipient phone number, backend URL, auto-reset, stealth gesture, and haptics.
- Debug-only simulator controls for testing without physical volume buttons.

## Architecture

```text
iPhone App
    |
    | HTTPS POST /api/send-number
    v
Node.js + Express Backend
    |
    | Twilio REST API
    v
Recipient phone
```

Request body:

```json
{
  "recipient": "+19095551234",
  "value": "47"
}
```

The Twilio message body is only the two-digit value, for example:

```text
47
```

## Repository Layout

```text
.
├── ios/
│   └── MagicNumber/
├── backend/
│   ├── src/
│   ├── package.json
│   ├── tsconfig.json
│   └── .env.example
├── .gitignore
├── README.md
└── LICENSE
```

## Backend Setup

Install dependencies:

```bash
cd backend
npm install
```

Create your local environment file:

```bash
cp .env.example .env
```

Fill in `.env` with your Twilio values:

```text
PORT=3000
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=+15551234567
```

Run in development:

```bash
npm run dev
```

Build and run production JavaScript:

```bash
npm run build
npm start
```

Health check:

```bash
curl http://localhost:3000/health
```

Send test:

```bash
curl -X POST http://localhost:3000/api/send-number \
  -H "Content-Type: application/json" \
  -d '{"recipient":"+19095551234","value":"47"}'
```

## Twilio Setup

1. Create or sign in to a Twilio account.
2. Buy or configure an SMS-capable Twilio phone number.
3. Copy your Account SID and Auth Token from the Twilio Console.
4. Add the values to `backend/.env`.
5. If your Twilio account is in trial mode, verify the recipient phone number in Twilio first.

Never commit `.env`, Twilio credentials, API tokens, or private backend credentials. The repository ignores secret environment files by default.

## Backend Deployment

The backend is a standard Node.js service and can be deployed to providers such as Render, Railway, Fly.io, Heroku-compatible platforms, or a small VPS.

Typical deployment settings:

- Build command: `npm install && npm run build`
- Start command: `npm start`
- Environment variables:
  - `TWILIO_ACCOUNT_SID`
  - `TWILIO_AUTH_TOKEN`
  - `TWILIO_PHONE_NUMBER`
  - `PORT` if your host requires it

After deployment, copy your HTTPS backend URL into the iOS app Settings. You can enter either the host root, such as `https://magic-number.example.com`, or the full endpoint, such as `https://magic-number.example.com/api/send-number`.

## iOS Setup

Open the project:

```bash
open ios/MagicNumber/MagicNumber.xcodeproj
```

In Xcode:

1. Select the `MagicNumber` project.
2. Select the `MagicNumber` target.
3. Open **Signing & Capabilities**.
4. Choose your personal team.
5. If needed, change the bundle identifier from `com.adamomarbasha.MagicNumber` to something unique, such as `com.yourname.MagicNumber`.
6. Select your iPhone as the run destination.
7. Press **Run**.

The app targets modern iPhones on iOS 17 or later.

## Installing On Your Personal iPhone

You can install directly from Xcode using a free Apple ID:

1. Connect your iPhone to your Mac.
2. Trust the Mac from the iPhone prompt.
3. In Xcode, add your Apple ID under **Settings > Accounts**.
4. Select your personal team in **Signing & Capabilities**.
5. Choose your iPhone as the run destination.
6. Press **Run**.
7. On the iPhone, if prompted, trust the developer profile under **Settings > General > VPN & Device Management**.

Free Apple ID provisioning commonly expires after 7 days. After that, reinstall from Xcode. Paid Apple Developer Program accounts can sign builds for longer.

## App Configuration

Open the gear button in the app.

- Recipient phone number: enter the SMS destination in E.164 format, for example `+19095551234`.
- Backend API URL: enter your deployed backend URL or local LAN URL.
- Reset after successful send: enabled by default.
- Stealth double-tap send: enabled by default.
- Haptics: enabled by default.

For local device testing, `localhost` means the iPhone itself, not your Mac. Use your Mac's LAN IP, for example `http://192.168.1.25:3000`, and make sure the iPhone and Mac are on the same network.

## Testing Volume Up And Volume Down

On a physical iPhone while the app is active:

- Press Volume Up to increment the left digit.
- Press Volume Down to increment the right digit.
- Each digit cycles after 9 back to 0.

In DEBUG builds, the app shows simulator-only buttons:

- Simulate Up
- Simulate Down

These buttons are compiled out of Release builds.

## iOS Volume-Control Limitations

iOS does not provide public `volumeUpPressed` or `volumeDownPressed` callbacks. This app uses the current public approach:

- Activate an `AVAudioSession`.
- Observe `AVAudioSession.outputVolume`.
- Add an off-screen `MPVolumeView` to reduce the system volume HUD.
- Infer direction from volume increase or decrease.
- Recenter system volume near 50% after each event so both buttons continue to produce volume-change events.

Unavoidable limitations:

- The app must be active in the foreground.
- iOS can change behavior across releases.
- Some system states, audio routes, headphones, CarPlay, calls, or interruptions can affect volume events.
- Re-centering modifies the device media volume. This is intentional so the trick keeps working near 0% and 100%.
- The default HUD is usually suppressed by `MPVolumeView`, but iOS ultimately controls system overlays.

No private Apple APIs are used.

## Troubleshooting

- **No SMS arrives:** check Twilio trial recipient verification, Twilio balance, backend logs, and `TWILIO_PHONE_NUMBER`.
- **App says backend URL is invalid:** include `http://` or `https://`.
- **Works in Simulator but not on device:** use a physical iPhone for real volume buttons and verify the app is foregrounded.
- **Local backend cannot be reached from iPhone:** use your Mac LAN IP instead of `localhost`.
- **Volume presses stop counting:** press each button once after launch, verify no external audio route is interfering, and reopen the app if iOS interrupted the audio session.

## GitHub Setup

Initialize and commit locally:

```bash
git init
git add .
git commit -m "Initial Magic Number app"
```

Create a GitHub repository, then follow GitHub's instructions to add the remote and push. Do not commit `.env` or any Twilio credentials.
