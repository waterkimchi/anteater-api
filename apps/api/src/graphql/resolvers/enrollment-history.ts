import type { GraphQLContext } from "$graphql/graphql-context";
import { enrollmentHistoryQuerySchema } from "$schema";
import { EnrollmentHistoryService } from "$services";

export const enrollmentHistoryResolvers = {
  Query: {
    enrollmentHistory: async (_: unknown, args: { query: unknown }, { db }: GraphQLContext) => {
      const service = new EnrollmentHistoryService(db);
      return await service.getEnrollmentHistory(enrollmentHistoryQuerySchema.parse(args.query));
    },
  },
};
