# You Are Sigma — iOS

Native SwiftUI iOS app. You are a sigma king. Celebrities worship you.

## What It Is

A comedy app that lets you:
1. Set up your profile (name, selfie, bio)
2. Generate luxury lifestyle photos of yourself (private jet, mega yacht, etc.)
3. Read texts from celebrities begging for your advice
4. Check your fake $42M vault

## Project Structure

- `You Are Sigma/` — SwiftUI iOS app
- `backend/` — Local Node.js API server (OpenAI chat + Gemini image generation)
- `You Are SigmaTests/` — Unit tests
- `You Are SigmaUITests/` — UI smoke tests

## Setup

### Backend
See `backend/README.md`.

### iOS App
1. Open `You Are Sigma.xcodeproj` in Xcode 26+
2. Set your development team in project settings
3. Start the backend: `cd backend && npm run dev`
4. Run on simulator or device

## Requirements
- iOS 26.4+
- Xcode 26+
- Node.js 20+ (for backend)
- OpenAI API key (chat)
- Google Gemini API key (photo generation)
