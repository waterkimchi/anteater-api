import type { Context } from "hono";
import { createMiddleware } from "hono/factory";

export const headerInjector = createMiddleware(async (c: Context, next) => {
  await next();
  c.res.headers.append("X-Powered-By", "Anteater-API/2.0 (https://github.com/icssc/anteater-api)");
});
