import "dotenv/config";

import { defineConfig } from "drizzle-kit";

const url = process.env.DB_URL;

if (!url) throw new Error("Database URL not provided. Please check your .env file.");

export default defineConfig({
  schema: "./src/schema.ts",
  out: "./migrations",
  dialect: "postgresql",
  dbCredentials: { url },
});
