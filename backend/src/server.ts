import "dotenv/config";
import { fileURLToPath } from "node:url";
import express, { type Express } from "express";
import cors from "cors";
import healthRouter from "./routes/health.js";
import chatRouter from "./routes/chat.js";
import photosRouter from "./routes/photos.js";

const app: Express = express();

app.use(cors());
app.use(express.json({ limit: "10mb" }));

app.use(healthRouter);
app.use(chatRouter);
app.use(photosRouter);

const PORT = Number(process.env.PORT) || 3000;

const isMain = process.argv[1] === fileURLToPath(import.meta.url);

if (isMain) {
  app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
  });
}

export { app };
