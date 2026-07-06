import {
  GoogleGenerativeAI,
  HarmBlockThreshold,
  HarmCategory,
} from "@google/generative-ai";

const MODEL = "gemini-2.0-flash-preview-image-generation";

export class ImageGenerationRefusedError extends Error {
  readonly name = "ImageGenerationRefusedError";
  constructor(message: string) {
    super(message);
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY ?? "");

export async function generateImageFromReference(
  prompt: string,
  ref: { data: string; mimeType: string },
): Promise<{ b64_json: string; mimeType: string }> {
  const model = genAI.getGenerativeModel({
    model: MODEL,
    safetySettings: [
      {
        category: HarmCategory.HARM_CATEGORY_HARASSMENT,
        threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH,
      },
      {
        category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
        threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH,
      },
      {
        category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
        threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH,
      },
      {
        category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
        threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH,
      },
    ],
    generationConfig: {
      // @ts-expect-error responseModalities is supported by image-gen models
      responseModalities: ["IMAGE", "TEXT"],
    },
  });

  const result = await model.generateContent([
    {
      inlineData: {
        data: ref.data,
        mimeType: ref.mimeType,
      },
    },
    { text: prompt },
  ]);

  const response = result.response;
  const candidate = response.candidates?.[0];

  if (candidate?.finishReason && candidate.finishReason !== "STOP") {
    throw new ImageGenerationRefusedError(
      `Image generation was blocked (${candidate.finishReason}).`,
    );
  }

  const parts = candidate?.content?.parts ?? [];
  const imagePart = parts.find(
    (part: { inlineData?: { data?: string; mimeType?: string } }) =>
      part.inlineData,
  );

  if (!imagePart?.inlineData?.data) {
    throw new ImageGenerationRefusedError(
      "The model did not return an image for this request.",
    );
  }

  return {
    b64_json: imagePart.inlineData.data,
    mimeType: imagePart.inlineData.mimeType || "image/png",
  };
}
