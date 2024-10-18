import { z } from "@hono/zod-openapi";

export const responseSchema = <T extends z.ZodType>(data: T) =>
  z.object({
    ok: z.literal<boolean>(true).openapi({}),
    data: data.openapi({ description: "The data that was requested" }),
  });
