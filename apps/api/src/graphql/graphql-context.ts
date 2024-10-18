import type { database } from "@packages/db";

export interface GraphQLContext {
  db: ReturnType<typeof database>;
}
