import { z } from "@hono/zod-openapi";
import { instructorPreviewSchema } from "./instructors";

const inputCourseLevels = ["LowerDiv", "UpperDiv", "Graduate"] as const;

const inputGECategories = [
  "GE-1A",
  "GE-1B",
  "GE-2",
  "GE-3",
  "GE-4",
  "GE-5A",
  "GE-5B",
  "GE-6",
  "GE-7",
  "GE-8",
] as const;

export const outputCourseLevels = [
  "Lower Division (1-99)",
  "Upper Division (100-199)",
  "Graduate/Professional Only (200+)",
] as const;

export const outputGECategories = [
  "GE Ia: Lower Division Writing",
  "GE Ib: Upper Division Writing",
  "GE II: Science and Technology",
  "GE III: Social & Behavioral Sciences",
  "GE IV: Arts and Humanities",
  "GE Va: Quantitative Literacy",
  "GE Vb: Formal Reasoning",
  "GE VI: Language Other Than English",
  "GE VII: Multicultural Studies",
  "GE VIII: International/Global Issues",
] as const;

export const coursesPathSchema = z.object({
  id: z
    .string({ message: "Parameter 'id' is required" })
    .openapi({ param: { name: "id", in: "path" } }),
});

export const coursesQuerySchema = z
  .object({
    department: z.string().optional(),
    courseNumber: z.string().optional(),
    courseNumeric: z.coerce.number().optional(),
    titleContains: z.string().optional(),
    courseLevel: z
      .enum(inputCourseLevels, {
        message: "If provided, 'courseLevel' must be 'LowerDiv', 'UpperDiv', or 'Graduate'",
      })
      .optional(),
    minUnits: z.coerce.number().optional(),
    maxUnits: z.coerce.number().optional(),
    descriptionContains: z.string().optional(),
    geCategory: z
      .enum(inputGECategories, {
        message:
          "If provided, 'geCategory' must be one of 'GE-1A', 'GE-1B', 'GE-2', 'GE-3', 'GE-4', 'GE-5A', 'GE-5B', 'GE-6', 'GE-7', or 'GE-8'",
      })
      .optional(),
  })
  .refine((x) => Object.keys(x).length > 0, {
    message:
      "At least one filter must be provided. To get all courses, use the /courses/all REST endpoint or allCourses GraphQL query.",
  });

export const prerequisiteSchema = z.discriminatedUnion("prereqType", [
  z.object({
    prereqType: z.literal<string>("course"),
    courseId: z.string().openapi({
      description: "The ID of the course that is a prerequisite/corequisite",
      example: "I&C SCI 46",
    }),
    minGrade: z.string().optional().openapi({
      description: "The minimum grade, if any, required to satisfy the prerequisite",
      example: "C",
    }),
    coreq: z.boolean().openapi({ description: "Whether this course is a corequisite" }),
  }),
  z.object({
    prereqType: z.literal<string>("exam"),
    examName: z.string().openapi({
      description: "The name of the exam that is a prerequisite",
      example: "AP CALCULUS BC",
    }),
    minGrade: z.string().optional().openapi({
      description: "The minimum grade, if any, required to satisfy the prerequisite",
      example: "4",
    }),
  }),
]);

export const prerequisiteTreeSchema = z.object({
  AND: z.object({}).array().optional().openapi({
    description:
      "All of these prerequisites must have been fulfilled before this course can be taken.",
  }),
  OR: z.object({}).array().optional().openapi({
    description:
      "At least one of these prerequisites must have been fulfilled before this course can be taken.",
  }),
  NOT: z.object({}).array().optional().openapi({
    description:
      "None of these prerequisites must have been fulfilled before this course can be taken.",
  }),
});

export const coursePreviewSchema = z.object({
  id: z.string().openapi({ example: "COMPSCI161" }),
  title: z.string().openapi({ example: "Design and Analysis of Algorithms" }),
  department: z.string().openapi({ example: "COMPSCI" }),
  courseNumber: z.string().openapi({ example: "161" }),
});

export const courseSchema = z.object({
  id: z.string().openapi({ example: "COMPSCI161" }),
  department: z.string().openapi({ example: "COMPSCI" }),
  courseNumber: z.string().openapi({ example: "161" }),
  courseNumeric: z.number().int().openapi({ example: 161 }),
  school: z
    .string()
    .openapi({ example: "Donald Bren School of Information and Computer Sciences" }),
  title: z.string().openapi({ example: "Design and Analysis of Algorithms" }),
  courseLevel: z.enum(outputCourseLevels).openapi({ example: "Upper Division (100-199)" }),
  minUnits: z.number().openapi({ example: 4 }),
  maxUnits: z.number().openapi({ example: 4 }),
  description: z.string().openapi({}),
  departmentName: z.string().openapi({ example: "Computer Science" }),
  instructors: instructorPreviewSchema.array(),
  prerequisiteTree: prerequisiteTreeSchema,
  prerequisiteText: z.string(),
  prerequisites: coursePreviewSchema.array(),
  dependencies: coursePreviewSchema.array(),
  repeatability: z.string(),
  gradingOption: z.string(),
  concurrent: z.string(),
  sameAs: z.string(),
  restriction: z.string(),
  overlap: z.string(),
  corequisites: z.string(),
  geList: z.enum(outputGECategories).array(),
  geText: z.string(),
  terms: z.string().array(),
});
