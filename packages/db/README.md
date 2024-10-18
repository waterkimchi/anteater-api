# @packages/db

This package (re-)exports the following things:

- The `database` function, which returns a Drizzle client that connects to the PostgreSQL database indicated by the connection string provided.
- The Drizzle schema through `@packages/db/schema`.
- Some helpful Drizzle-related utilities through `@packages/db/utils`.
- Everything in `drizzle-orm` through `@packages/db/drizzle`, so packages that need to interact with the database only need to depend on this package.

This package also includes the `drizzle-kit` config and the Dockerfile for the local development database.
