# Info.plist Configuration

## API Base URL

Add this key to the app's Info.plist to override the default localhost backend URL:

Key: `API_BASE_URL`
Value: `http://localhost:3000` (development) or your production URL

The app reads this via `Bundle.main.infoDictionary?["API_BASE_URL"]`.
