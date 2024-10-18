import type { DrizzleConfig } from "drizzle-orm";
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";

export const database = (url: string, config?: DrizzleConfig) => drizzle(postgres(url), config);
