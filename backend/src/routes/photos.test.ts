import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";

const { mockGenerateImageFromReference } = vi.hoisted(() => ({
  mockGenerateImageFromReference: vi.fn(),
}));

vi.mock("../lib/gemini.js", () => ({
  generateImageFromReference: mockGenerateImageFromReference,
  ImageGenerationRefusedError: class ImageGenerationRefusedError extends Error {
    readonly name = "ImageGenerationRefusedError";
  },
}));

const { app } = await import("../server.js");

const validImage = Buffer.from("small-image").toString("base64");

describe("POST /photos/generate", () => {
  beforeEach(() => {
    mockGenerateImageFromReference.mockReset();
    mockGenerateImageFromReference.mockResolvedValue({
      b64_json: "generated-image-data",
      mimeType: "image/png",
    });
  });

  it("returns 200 with generated image for a valid body", async () => {
    const res = await request(app).post("/photos/generate").send({
      image: validImage,
      mimeType: "image/png",
      prompt: "On a yacht at sunset",
    });

    expect(res.status).toBe(200);
    expect(res.body).toEqual({
      b64_json: "generated-image-data",
      mimeType: "image/png",
    });
    expect(mockGenerateImageFromReference).toHaveBeenCalled();
  });

  it("returns 400 when prompt is missing", async () => {
    const res = await request(app).post("/photos/generate").send({
      image: validImage,
      mimeType: "image/png",
    });

    expect(res.status).toBe(400);
    expect(res.body).toEqual({
      error: "Please provide a photo, its type, and a scene description.",
    });
    expect(mockGenerateImageFromReference).not.toHaveBeenCalled();
  });

  it("returns 400 for an unsupported mime type", async () => {
    const res = await request(app).post("/photos/generate").send({
      image: validImage,
      mimeType: "image/gif",
      prompt: "On a yacht",
    });

    expect(res.status).toBe(400);
    expect(res.body).toEqual({
      error: "Unsupported image type. Please upload a JPEG, PNG, or WebP photo.",
    });
    expect(mockGenerateImageFromReference).not.toHaveBeenCalled();
  });

  it("returns 400 when image is too large", async () => {
    const largeImage = "A".repeat(Math.ceil((7 * 1024 * 1024 * 4) / 3) + 4);

    const res = await request(app).post("/photos/generate").send({
      image: largeImage,
      mimeType: "image/jpeg",
      prompt: "On a yacht",
    });

    expect(res.status).toBe(400);
    expect(res.body).toEqual({
      error: "That photo is too large. Please choose an image under 7 MB.",
    });
    expect(mockGenerateImageFromReference).not.toHaveBeenCalled();
  });

  it("returns 422 when gemini refuses", async () => {
    const { ImageGenerationRefusedError } = await import("../lib/gemini.js");
    mockGenerateImageFromReference.mockRejectedValue(
      new ImageGenerationRefusedError("blocked"),
    );

    const res = await request(app).post("/photos/generate").send({
      image: validImage,
      mimeType: "image/png",
      prompt: "With a celebrity",
    });

    expect(res.status).toBe(422);
    expect(res.body.error).toContain("Couldn't generate that one");
  });
});
