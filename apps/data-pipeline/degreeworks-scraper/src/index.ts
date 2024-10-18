import { exit } from "node:process";
import { Scraper } from "$components";
import { database } from "@packages/db";
import { degree, major, minor, specialization } from "@packages/db/schema";
import type { Division } from "@packages/db/schema";
import { conflictUpdateSetAllCols } from "@packages/db/utils";

async function main() {
  if (!process.env.DEGREEWORKS_SCRAPER_X_AUTH_TOKEN) throw new Error("Auth cookie not set.");
  if (!process.env.DB_URL) throw new Error("DB_URL not set.");
  const db = database(process.env.DB_URL);
  const scraper = await Scraper.new({
    authCookie: process.env.DEGREEWORKS_SCRAPER_X_AUTH_TOKEN,
    db,
  });
  await scraper.run();
  const {
    degreesAwarded,
    parsedSpecializations,
    parsedGradPrograms,
    parsedMinorPrograms,
    parsedUgradPrograms,
  } = scraper.get();
  const degreeData = Array.from(degreesAwarded.entries()).map(([id, name]) => ({
    id,
    name,
    division: (id.startsWith("B") ? "Undergraduate" : "Graduate") as Division,
  }));
  const majorData = [
    ...Array.from(parsedUgradPrograms.values()),
    ...Array.from(parsedGradPrograms.values()),
  ].map(({ name, degreeType, code, requirements }) => ({
    id: `${degreeType}-${code}`,
    degreeId: degreeType ?? "",
    code,
    name,
    requirements,
  }));
  const minorData = Array.from(parsedMinorPrograms.values()).map(
    ({ name, code: id, requirements }) => ({ id, name, requirements }),
  );
  const specData = Array.from(parsedSpecializations.values()).map(
    ({ name, degreeType, code, requirements }) => ({
      id: `${degreeType}-${code}`,
      majorId: `${degreeType}-${code.slice(0, code.length - 1)}`,
      name,
      requirements,
    }),
  );
  await db.transaction(async (tx) => {
    await tx
      .insert(degree)
      .values(degreeData)
      .onConflictDoUpdate({ target: degree.id, set: conflictUpdateSetAllCols(degree) });
    await tx
      .insert(major)
      .values(majorData)
      .onConflictDoUpdate({ target: major.id, set: conflictUpdateSetAllCols(major) });
    await tx
      .insert(minor)
      .values(minorData)
      .onConflictDoUpdate({ target: major.id, set: conflictUpdateSetAllCols(minor) });
    await tx
      .insert(specialization)
      .values(specData)
      .onConflictDoUpdate({ target: major.id, set: conflictUpdateSetAllCols(specialization) });
  });
  exit(0);
}

main().then();
