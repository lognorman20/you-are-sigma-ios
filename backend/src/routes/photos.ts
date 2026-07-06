import { Router, type IRouter } from "express";
import { z } from "zod";
import {
  generateImageFromReference,
  ImageGenerationRefusedError,
} from "../lib/gemini.js";

const router: IRouter = Router();

// Image generation is a paid, comparatively expensive operation, and a single
// photo upload fans out into five "look" generations. Keep a stricter limit
// than the chat endpoint so a client cannot drive runaway cost.
const RATE_LIMIT = 15;
const RATE_WINDOW_MS = 5 * 60_000;
const hits = new Map<string, { count: number; resetAt: number }>();

function isRateLimited(key: string): boolean {
  const now = Date.now();
  const entry = hits.get(key);
  if (!entry || now > entry.resetAt) {
    hits.set(key, { count: 1, resetAt: now + RATE_WINDOW_MS });
    return false;
  }
  entry.count += 1;
  return entry.count > RATE_LIMIT;
}

const ALLOWED_MIME_TYPES = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
]);

// Gemini inline input data is capped at 8 MB. Keep the decoded reference image
// comfortably below that so the request never gets rejected by the model.
const MAX_IMAGE_BYTES = 7 * 1024 * 1024;

const GenerateLuxuryPhotoBody = z.object({
  image: z.string(),
  mimeType: z.string(),
  prompt: z.string(),
});

function approxBase64Bytes(base64: string): number {
  // Each base64 char encodes 6 bits; 4 chars => 3 bytes.
  const padding = base64.endsWith("==") ? 2 : base64.endsWith("=") ? 1 : 0;
  return Math.floor((base64.length * 3) / 4) - padding;
}

router.post("/photos/generate", async (req, res) => {
  const ip = req.ip ?? "unknown";
  if (isRateLimited(ip)) {
    res.status(429).json({
      error: "Too many photo generations. Give it a few minutes and try again.",
    });
    return;
  }

  const parsed = GenerateLuxuryPhotoBody.safeParse(req.body);

  if (!parsed.success) {
    res.status(400).json({
      error: "Please provide a photo, its type, and a scene description.",
    });
    return;
  }

  const { image, mimeType, prompt } = parsed.data;

  if (!ALLOWED_MIME_TYPES.has(mimeType)) {
    res.status(400).json({
      error: "Unsupported image type. Please upload a JPEG, PNG, or WebP photo.",
    });
    return;
  }

  if (approxBase64Bytes(image) > MAX_IMAGE_BYTES) {
    res.status(400).json({
      error: "That photo is too large. Please choose an image under 7 MB.",
    });
    return;
  }

  if (prompt.trim().length === 0) {
    res.status(400).json({
      error: "Please describe the luxury scene you want to be in.",
    });
    return;
  }

  const fullPrompt = [
    "Using the person in the provided photo as the reference, generate a new, photorealistic image of that exact same person.",
    "Faithfully preserve their facial features, likeness, skin tone, hair, and overall identity so they are clearly recognizable.",
    `Place them in this scene: ${prompt.trim()}.`,
    "Make it look like a candid, high-end lifestyle photo: cinematic lighting, shallow depth of field, luxurious and aspirational mood.",
  ].join(" ");

  try {
    const result = await generateImageFromReference(fullPrompt, {
      data: image,
      mimeType,
    });
    res.json({ b64_json: result.b64_json, mimeType: result.mimeType });
  } catch (err) {
    if (err instanceof ImageGenerationRefusedError) {
      res.status(422).json({
        error:
          "Couldn't generate that one — the scene may have been blocked (named celebrities often are). Try a different scene or wording.",
      });
      return;
    }

    res.status(500).json({
      error: "Something went wrong generating your photo. Please try again.",
    });
  }
});

export default router;
