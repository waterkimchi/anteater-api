import type { Bindings } from "$types/bindings";
import type { Context, Next } from "hono";
import { cache } from "hono/cache";

export const productionCache =
  (cacheOptions: Parameters<typeof cache>[0]) =>
  async (c: Context<{ Bindings: Bindings }>, next: Next) =>
    c.env.CF_ENV === "prod" ? cache(cacheOptions)(c, next) : await next();
