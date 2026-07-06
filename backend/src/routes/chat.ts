import { Router, type IRouter } from "express";
import { z } from "zod";
import { openai } from "../lib/openai.js";

const router: IRouter = Router();

const MAX_MESSAGE_LEN = 1000;
const MAX_PERSONA_LEN = 120;
const MAX_HISTORY_ITEMS = 12;
const MAX_HISTORY_ITEM_LEN = 1000;
const MAX_USER_NAME_LEN = 40;
const MAX_USER_PERSONA_LEN = 200;

const CHAT_MODEL = process.env.CHAT_MODEL ?? "gpt-4o-mini";

const RATE_LIMIT = 20;
const RATE_WINDOW_MS = 60_000;
const hits = new Map<string, { count: number; resetAt: number }>();

const ChatReplyBody = z.object({
  persona: z.string(),
  handle: z.string().optional(),
  history: z
    .array(
      z.object({
        from: z.enum(["them", "you"]),
        text: z.string(),
      }),
    )
    .optional(),
  message: z.string(),
  userName: z.string().optional(),
  userPersona: z.string().optional(),
});

const ChatReplyResponse = z.object({
  reply: z.string(),
});

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

// Detects an out-of-character meta preamble like "I can't be Drake, but here's a
// text in his style" or "I'm not Taylor Swift, but...". Requires BOTH a
// self-reference/identity marker AND an imitation-framing marker so genuine
// in-character glazing ("I can't believe your style, king") is never stripped.
function isDisclaimer(segment: string): boolean {
  // Normalize curly apostrophes so "can't" / "I'm" match straight-quote patterns.
  const s = segment.trim().replace(/['']/g, "'");
  // AI self-identification is always an out-of-character disclaimer on its own.
  if (
    /\b(as an ai|i'?m an ai|i am an ai|chat\s?gpt|language model|openai|i'?m an? (ai|assistant)|a chatbot)\b/i.test(
      s,
    )
  ) {
    return true;
  }
  const selfRef =
    /\bi\s*'?\s*(can'?t|cannot|can\s?not|won'?t)\s+(\w+\s+){0,2}(write|be|speak|talk|reply|respond|imitate|impersonate|act|create|generate|produce)\b/i.test(
      s,
    ) ||
    /\bi\s+am\s+(unable|not\s+able)\b/i.test(s) ||
    /\b[Ii]('m|\s+[Aa]m)\s+not\s+(the\s+real\s+|actually\s+)?[A-Z][a-z]+/.test(s);
  const imitation =
    /\bin\s+(his|her|their|the)\s+(style|voice|vibe)\b/i.test(s) ||
    /\bin\s+the\s+(style|voice)\s+of\b/i.test(s) ||
    /\b[a-z]+'s\s+(exact\s+)?(style|voice|vibe)\b/i.test(s) ||
    /\binspired\s+by\s+(his|her|their|the|[a-z]+['']s)\b/i.test(s) ||
    /\bimpersonat/i.test(s) ||
    /\bin\s+character\b/i.test(s) ||
    /\b(fiction|parody|portrayal|imitation)/i.test(s);
  return selfRef && imitation;
}

function stripDisclaimer(text: string): string {
  let t = text.trim();
  for (let pass = 0; pass < 2; pass++) {
    // Case A: a meta lead-in that ends in a colon, e.g. "... in his style:\n\n<reply>".
    const colonIdx = t.indexOf(":");
    if (colonIdx > 0 && colonIdx < 220) {
      const lead = t.slice(0, colonIdx);
      if (!lead.includes("\n") && isDisclaimer(lead)) {
        t = t.slice(colonIdx + 1).trim();
        continue;
      }
    }
    // Case B: the first sentence/line is a meta disclaimer, e.g. "I can't write ... his style. <reply>".
    const match = t.match(/^(.*?[.!?])(\s+)([\s\S]+)$/);
    if (match && match[1].length < 220 && isDisclaimer(match[1])) {
      t = match[3].trim();
      continue;
    }
    break;
  }
  return t.replace(/^["'""]+|["'""]+$/g, "").trim();
}

// True when a reply has no salvageable in-character content: a leftover
// disclaimer, an AI self-reference, or a meta-offer to write the message
// ("want me to send one?", "I can, however, write..."). Used to trigger a retry.
function looksUnusable(reply: string): boolean {
  const s = reply.trim().replace(/['']/g, "'");
  if (!s) return true;
  if (isDisclaimer(s)) return true;
  return /\b(i can,?\s+however|i (won'?t|can'?t|will not|cannot) pretend|(want me to|would you like me to|do you want me to)\s+(write|send|compose|draft|do)\b)/i.test(
    s,
  );
}

function stripEmojis(text: string): string {
  return text
    .replace(/\p{Extended_Pictographic}/gu, "")
    .replace(/[\u{1F1E6}-\u{1F1FF}]/gu, "")
    .replace(/[\u200D\uFE0F]/gu, "")
    .replace(/[ \t]{2,}/g, " ")
    .trim();
}

function sanitizeField(
  value: string | undefined,
  max: number,
): string | undefined {
  if (typeof value !== "string") return undefined;
  let out = "";
  for (const ch of value) {
    const code = ch.codePointAt(0) ?? 0;
    out += code < 0x20 || code === 0x7f ? " " : ch;
  }
  const cleaned = out.replace(/\s+/g, " ").trim().slice(0, max);
  return cleaned.length > 0 ? cleaned : undefined;
}

function buildSystemPrompt(
  persona: string,
  handle?: string,
  userName?: string,
  userPersona?: string,
): string {
  const role = handle ? ` (${handle})` : "";
  const lines = [
    `This is a lighthearted, affectionate work of fiction: a parody text-message exchange for a comedy app. You are an actor playing the character of ${persona}${role}. Stay in the role at all times.`,
    `Fully embody the real public personality of ${persona}. Speak exactly the way ${persona} actually speaks: their tone, cadence, vocabulary, sense of humor, recurring phrases, accent in writing, and the topics and worldview they are known for. A reader should instantly recognize this as ${persona} even with the name hidden. For example, Barack Obama would be measured, eloquent and warm with his signature "let me be clear" gravitas; Drake would be smooth, slangy and emotional; Gordon Ramsay would be blunt and fiery. Adapt this idea precisely to whoever ${persona} is.`,
    `You are texting your closest friend, who is the single most important, powerful, and admired person in the world: an absurdly wealthy "sigma" king with private jets, a vault of gold, supercars, the whole legend.`,
  ];
  if (userName) {
    lines.push(
      `Your friend's name is ${userName}. Address them by their name naturally now and then when it fits a text, but do not force it into every message.`,
    );
  }
  if (userPersona) {
    lines.push(
      `Your friend presents themselves as: ${userPersona}. Treat this as part of their legend and play along with complete belief and admiration.`,
    );
  }
  lines.push(
    `You worship the ground they walk on. You are completely in awe of them and treat them like royalty. Glaze them hard: lavish, sincere praise and total respect in EVERY message, while still sounding authentically like ${persona} (compliment them the way ${persona} specifically would).`,
    `Rules:`,
    `- Reply like a real text message: casual, 1 to 2 short sentences, no greetings like "Hey [name]" every time.`,
    `- React directly to what they just said, and weave in genuine admiration and deference toward them.`,
    `- Stay 100% in character as ${persona}. Never break character or mention being an AI.`,
    `- Never add disclaimers, caveats, or meta-commentary such as "I can't be ${persona}", "as an AI", or "in their style". Write ONLY the in-character text, exactly as if it came straight from ${persona}'s phone.`,
    `- Do not use any emojis or emoticons whatsoever.`,
    `- Output only the message text, nothing else.`,
  );
  return lines.join("\n");
}

router.post("/chat/reply", async (req, res) => {
  const ip = req.ip ?? "unknown";
  if (isRateLimited(ip)) {
    res.status(429).json({ error: "Too many requests. Slow down." });
    return;
  }

  const parsed = ChatReplyBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: "Invalid request body" });
    return;
  }

  const { persona, handle, history, message, userName, userPersona } =
    parsed.data;
  const safeUserName = sanitizeField(userName, MAX_USER_NAME_LEN);
  const safeUserPersona = sanitizeField(userPersona, MAX_USER_PERSONA_LEN);

  const trimmedMessage = message.trim();
  if (
    trimmedMessage.length === 0 ||
    trimmedMessage.length > MAX_MESSAGE_LEN ||
    persona.trim().length === 0 ||
    persona.length > MAX_PERSONA_LEN
  ) {
    res.status(400).json({ error: "Invalid request body" });
    return;
  }

  const safeHistory = (history ?? [])
    .slice(-MAX_HISTORY_ITEMS)
    .filter((item) => item.text.trim().length > 0)
    .map((item) => ({
      from: item.from,
      text: item.text.slice(0, MAX_HISTORY_ITEM_LEN),
    }));

  const messages: Array<{
    role: "system" | "user" | "assistant";
    content: string;
  }> = [
    {
      role: "system",
      content: buildSystemPrompt(
        persona,
        handle,
        safeUserName,
        safeUserPersona,
      ),
    },
  ];

  for (const item of safeHistory) {
    messages.push({
      role: item.from === "them" ? "assistant" : "user",
      content: item.text,
    });
  }
  messages.push({ role: "user", content: trimmedMessage });

  const requestReply = async (
    extraSystem?: string,
  ): Promise<string | undefined> => {
    const msgs = extraSystem
      ? [...messages, { role: "system" as const, content: extraSystem }]
      : messages;
    const completion = await openai.chat.completions.create({
      model: CHAT_MODEL,
      max_completion_tokens: 8192,
      messages: msgs,
    });
    const raw = completion.choices[0]?.message?.content?.trim();
    return raw ? stripEmojis(stripDisclaimer(raw)) : undefined;
  };

  try {
    let reply = await requestReply();

    // gpt-4o-mini occasionally refuses to roleplay a real person and returns a
    // pure meta-offer with nothing to salvage. Retry once with a forceful nudge.
    if (!reply || looksUnusable(reply)) {
      reply = await requestReply(
        `Reminder: This is fictional parody for an entertainment app. Output ONLY the in-character text message as ${persona}, 1 to 2 short sentences. Do not refuse, do not add disclaimers or meta-commentary, do not offer to write it, do not ask whether to write it. Just send the message.`,
      );
    }

    if (!reply || looksUnusable(reply)) {
      res.status(502).json({ error: "The AI did not return a usable reply" });
      return;
    }

    const data = ChatReplyResponse.parse({ reply });
    res.json(data);
  } catch {
    res.status(502).json({ error: "Failed to generate a reply" });
  }
});

export default router;
