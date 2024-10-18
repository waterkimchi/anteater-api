# @apps/api

This project contains the API part of Anteater API.

## Directory Structure

- `graphql`: The GraphQL API and related configuration.
  - `plugins`: Plugins for the GraphQL server.
  - `resolvers`: Resolvers for GraphQL queries.
  - `schema`: The GraphQL schema.
- `hooks`: Custom hooks for the API.
- `middleware`: Custom middleware for the API.
- `rest`: The REST API and related configuration.
  - `routes`: The routes that make up the REST API.
- `schema`: The Zod schema used by both APIs.
- `services`: The service layer, containing all business logic, used by both APIs.
