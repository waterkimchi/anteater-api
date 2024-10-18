import type { Cache, ResponseCachePluginExtensions } from "@graphql-yoga/plugin-response-cache";
import type { ExecutionResult } from "graphql";

export class YogaKVCache implements Cache {
  constructor(private readonly kv: KVNamespace<string>) {}

  async get(
    key: string,
  ): Promise<ExecutionResult<Record<string, unknown>, ResponseCachePluginExtensions> | undefined> {
    return JSON.parse((await this.kv.get(key, "text")) ?? "null") ?? undefined;
  }

  async set(id: string, data: ExecutionResult, _: unknown, ttl: number): Promise<void> {
    await this.kv.put(id, JSON.stringify(data), { expirationTtl: ttl });
  }

  // This is a no-op because our API doesn't have mutations.
  invalidate(_: unknown) {}
}
