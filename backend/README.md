# You Are Sigma — Backend

Local Node.js API server for the You Are Sigma iOS app. Handles celebrity chat replies (OpenAI) and luxury photo generation (Gemini).

## Prerequisites

- Node.js 20+
- npm

## Setup

```bash
npm install
cp .env.example .env
```

Add your API keys to `.env`:

| Variable | Description |
|----------|-------------|
| `OPENAI_API_KEY` | OpenAI API key for celebrity chat replies |
| `GEMINI_API_KEY` | Google Gemini API key for photo generation |
| `PORT` | Server port (default: `3000`) |

## Development

```bash
npm run dev
```

Starts the server on `http://localhost:3000`. The iOS simulator connects to this URL by default.

## Testing

```bash
npm test
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/healthz` | Health check |
| `POST` | `/chat/reply` | Celebrity chat reply (OpenAI) |
| `POST` | `/photos/generate` | Luxury photo generation (Gemini) |

## Note

This is a local-only dev backend. Do not deploy to production without adding authentication, rate limiting, and proper secret management.
