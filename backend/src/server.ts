import cors from "cors";
import express, { type ErrorRequestHandler } from "express";
import rateLimit from "express-rate-limit";
import helmet from "helmet";
import { ZodError } from "zod";
import { loadConfig } from "./config.js";
import { createTwilioSmsService } from "./twilioSmsService.js";
import { sendNumberSchema } from "./validation.js";

const config = loadConfig();
const smsService = createTwilioSmsService(config);
const app = express();

app.disable("x-powered-by");
app.use(helmet());
app.use(cors({ origin: false }));
app.use(express.json({ limit: "8kb" }));
app.use(
  rateLimit({
    windowMs: 60_000,
    limit: 12,
    standardHeaders: "draft-8",
    legacyHeaders: false,
    message: {
      success: false,
      error: "Too many requests. Please wait a moment and try again."
    }
  })
);

app.get("/health", (_request, response) => {
  response.json({ ok: true });
});

app.post("/api/send-number", async (request, response, next) => {
  try {
    const payload = sendNumberSchema.parse(request.body);
    await smsService.sendNumber(payload.recipient, payload.value);
    response.json({ success: true });
  } catch (error) {
    next(error);
  }
});

const errorHandler: ErrorRequestHandler = (error, _request, response, _next) => {
  if (error instanceof ZodError) {
    response.status(400).json({
      success: false,
      error: error.issues[0]?.message ?? "Invalid request."
    });
    return;
  }

  if (error instanceof SyntaxError && "body" in error) {
    response.status(400).json({
      success: false,
      error: "Malformed JSON request body."
    });
    return;
  }

  console.error(error);
  response.status(500).json({
    success: false,
    error: "Unable to send SMS."
  });
};

app.use(errorHandler);

app.listen(config.port, () => {
  console.log(`Magic Number backend listening on port ${config.port}`);
});
