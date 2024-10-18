import type { DurableObjectRateLimiter } from "@hono-rate-limiter/cloudflare";

export interface Bindings extends Env {
  RATE_LIMITER: DurableObjectNamespace<DurableObjectRateLimiter>;
}
