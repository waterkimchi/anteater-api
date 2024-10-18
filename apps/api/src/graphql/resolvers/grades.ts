import type { GraphQLContext } from "$graphql/graphql-context";
import { gradesQuerySchema } from "$schema";
import { GradesService } from "$services";

export const gradesResolvers = {
  Query: {
    rawGrades: async (_: unknown, args: { query: unknown }, { db }: GraphQLContext) => {
      const service = new GradesService(db);
      return await service.getRawGrades(gradesQuerySchema.parse(args.query));
    },
    gradesOptions: async (_: unknown, args: { query: unknown }, { db }: GraphQLContext) => {
      const service = new GradesService(db);
      return await service.getGradesOptions(gradesQuerySchema.parse(args.query));
    },
    aggregateGrades: async (_: unknown, args: { query: unknown }, { db }: GraphQLContext) => {
      const service = new GradesService(db);
      return await service.getAggregateGrades(gradesQuerySchema.parse(args.query));
    },
    aggregateGradesByCourse: async (
      _: unknown,
      args: { query: unknown },
      { db }: GraphQLContext,
    ) => {
      const service = new GradesService(db);
      return await service.getAggregateGradesByCourse(gradesQuerySchema.parse(args.query));
    },
    aggregateGradesByOffering: async (
      _: unknown,
      args: { query: unknown },
      { db }: GraphQLContext,
    ) => {
      const service = new GradesService(db);
      return await service.getAggregateGradesByOffering(gradesQuerySchema.parse(args.query));
    },
  },
};
