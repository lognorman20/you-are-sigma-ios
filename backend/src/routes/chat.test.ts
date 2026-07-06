import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";

const { mockCreate } = vi.hoisted(() => ({
  mockCreate: vi.fn(),
}));

vi.mock("../lib/openai.js", () => ({
  openai: {
    chat: {
      completions: {
        create: mockCreate,
      },
    },
  },
}));

const { app } = await import("../server.js");

describe("POST /chat/reply", () => {
  beforeEach(() => {
    mockCreate.mockReset();
    mockCreate.mockResolvedValue({
      choices: [{ message: { content: "You're the sigma king, no cap." } }],
    });
  });

  it("returns 200 with a reply for a valid body", async () => {
    const res = await request(app).post("/chat/reply").send({
      persona: "Drake",
      message: "What's good?",
    });

    expect(res.status).toBe(200);
    expect(res.body).toEqual({ reply: "You're the sigma king, no cap." });
    expect(mockCreate).toHaveBeenCalled();
  });

  it("returns 400 when message is empty", async () => {
    const res = await request(app).post("/chat/reply").send({
      persona: "Drake",
      message: "   ",
    });

    expect(res.status).toBe(400);
    expect(res.body).toEqual({ error: "Invalid request body" });
    expect(mockCreate).not.toHaveBeenCalled();
  });

  it("returns 400 when persona is too long", async () => {
    const res = await request(app).post("/chat/reply").send({
      persona: "x".repeat(121),
      message: "Hello",
    });

    expect(res.status).toBe(400);
    expect(res.body).toEqual({ error: "Invalid request body" });
    expect(mockCreate).not.toHaveBeenCalled();
  });

  it("returns 400 for a malformed body", async () => {
    const res = await request(app).post("/chat/reply").send({
      persona: "Drake",
    });

    expect(res.status).toBe(400);
    expect(res.body).toEqual({ error: "Invalid request body" });
    expect(mockCreate).not.toHaveBeenCalled();
  });
});
