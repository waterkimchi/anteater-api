import { z } from "@hono/zod-openapi";
import type { FinalExamStatus } from "@packages/db/schema";
import { courseLevels, terms, websocSectionTypes, websocStatuses } from "@packages/db/schema";
import { isBaseTenInt } from "@packages/stdlib";

const anyArray = ["ANY"] as const;

const geCategories = [
  "ANY",
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

const allDays = [
  "M",
  "Mo",
  "Mon",
  "Tu",
  "Tue",
  "Tues",
  "W",
  "We",
  "Wed",
  "Th",
  "Thu",
  "Thur",
  "F",
  "Fr",
  "Fri",
  "S",
  "Sa",
  "Sat",
  "Su",
  "Sun",
] as const;

const normalizedDays = ["M", "Tu", "W", "Th", "F", "S", "Su"] as const;

const dayMapping: Record<(typeof allDays)[number], (typeof normalizedDays)[number]> = {
  M: "M",
  Mo: "M",
  Mon: "M",
  Tu: "Tu",
  Tue: "Tu",
  Tues: "Tu",
  W: "W",
  We: "W",
  Wed: "W",
  Th: "Th",
  Thu: "Th",
  Thur: "Th",
  F: "F",
  Fr: "F",
  Fri: "F",
  S: "S",
  Sa: "S",
  Sat: "S",
  Su: "Su",
  Sun: "Su",
};

const fullCoursesOptions = [
  "ANY",
  "SkipFull",
  "SkipFullWaitlist",
  "FullOnly",
  "Overenrolled",
] as const;

const cancelledCoursesOptions = ["Exclude", "Include", "Only"] as const;

const restrictionCodes = [
  "A",
  "B",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "I",
  "J",
  "K",
  "L",
  "M",
  "N",
  "O",
  "S",
  "R",
  "X",
] as const;

export type ParsedInteger = {
  _type: "ParsedInteger";
  value: number;
};

export type ParsedString = {
  _type: "ParsedString";
  value: string;
};

export type ParsedRange = {
  _type: "ParsedRange";
  min: number;
  max: number;
};

export type ParsedNumber = ParsedInteger | ParsedString | ParsedRange;

const isValidDay = (day: string): day is (typeof allDays)[number] =>
  !!(dayMapping as Record<string, unknown>)[day];

const isValidRestrictionCode = (code: string): code is (typeof restrictionCodes)[number] =>
  (restrictionCodes as readonly string[]).includes(code);

const MILLISECONDS_PER_MINUTE = 60 * 1000;
const MILLISECONDS_PER_HOUR = 60 * MILLISECONDS_PER_MINUTE;

const transformTime = (time?: string): Date | undefined => {
  if (!time || time === "") return undefined;
  const [hourString, minuteString] = time.split(":");
  return new Date(
    (hourString === "12"
      ? minuteString.endsWith("am")
        ? 0
        : 12 * MILLISECONDS_PER_HOUR
      : Number.parseInt(hourString, 10) * MILLISECONDS_PER_HOUR) +
      Number.parseInt(minuteString, 10) * MILLISECONDS_PER_MINUTE +
      (hourString === "12" ? 0 : minuteString.endsWith("am") ? 0 : 12 * MILLISECONDS_PER_HOUR),
  );
};

export const websocQuerySchema = z.object({
  year: z
    .string({ message: "Parameter 'year' is required " })
    .length(4, { message: "Parameter 'year' must have length 4" }),
  quarter: z.enum(terms),
  ge: z
    .enum(geCategories)
    .optional()
    .transform((x) => (x === "ANY" ? undefined : x)),
  department: z.string().optional(),
  courseTitle: z.string().optional(),
  courseNumber: z
    .string()
    .optional()
    .transform((nums, ctx) => {
      if (!nums) return undefined;
      const parsedNums: ParsedNumber[] = [];
      for (const num of nums.split(",").map((num) => num.trim())) {
        if (num.includes("-")) {
          const [lower, upper] = num.split("-");
          if (!(isBaseTenInt(lower) && isBaseTenInt(upper))) {
            ctx.addIssue({
              code: z.ZodIssueCode.custom,
              message: `'${num}' is not a valid course number range. The lower and upper bounds of a course number range must both be base-10 integers.`,
            });
            return z.NEVER;
          }
          parsedNums.push({
            _type: "ParsedRange",
            min: Number.parseInt(lower, 10),
            max: Number.parseInt(upper, 10),
          });
          continue;
        }
        if (!isBaseTenInt(num)) {
          parsedNums.push({ _type: "ParsedString", value: num });
        } else {
          parsedNums.push({ _type: "ParsedInteger", value: Number.parseInt(num, 10) });
        }
      }
      return parsedNums;
    }),
  sectionCodes: z
    .string()
    .optional()
    .transform((codes, ctx) => {
      if (!codes) return undefined;
      const parsedNums: Exclude<ParsedNumber, ParsedString>[] = [];
      for (const code of codes.split(",").map((code) => code.trim())) {
        if (code.includes("-")) {
          const [lower, upper] = code.split("-");
          if (!(isBaseTenInt(lower) && isBaseTenInt(upper))) {
            ctx.addIssue({
              code: z.ZodIssueCode.custom,
              message: `'${code}' is not a valid section code range. A valid section code range consists of valid section codes, which are base-10 integers.`,
            });
            return z.NEVER;
          }
          parsedNums.push({
            _type: "ParsedRange",
            min: Number.parseInt(lower, 10),
            max: Number.parseInt(upper, 10),
          });
          continue;
        }
        if (!isBaseTenInt(code)) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: `'${code}' is not a valid section code. A valid section code is a base-10 integer.`,
          });
          return z.NEVER;
        }
        parsedNums.push({ _type: "ParsedInteger", value: Number.parseInt(code, 10) });
      }
      return parsedNums;
    }),
  instructorName: z.string().optional(),
  days: z
    .string()
    .optional()
    .transform((days, ctx) => {
      if (!days) return undefined;
      const parsedDays: Array<(typeof normalizedDays)[number]> = [];
      for (const day of days.split(",").map((day) => day.trim())) {
        if (!isValidDay(day)) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: `'${day}' is not a valid day of the week. Valid days of the week are ${allDays.join(", ")}.`,
          });
          return z.NEVER;
        }
        parsedDays.push(dayMapping[day]);
      }
      return parsedDays;
    }),
  building: z.string().optional(),
  room: z.string().optional(),
  division: z
    .enum(courseLevels)
    .or(z.literal("ANY"))
    .optional()
    .transform((x) => (x === "ANY" ? undefined : x)),
  sectionType: z
    .union([z.enum(anyArray), z.enum(websocSectionTypes)])
    .optional()
    .transform((x) => (x === "ANY" ? undefined : x)),
  fullCourses: z
    .enum(fullCoursesOptions)
    .optional()
    .transform((x) => (x === "ANY" ? undefined : x)),
  cancelledCourses: z.enum(cancelledCoursesOptions).optional(),
  units: z.optional(z.literal("VAR").or(z.string())),
  startTime: z
    .optional(z.literal("").or(z.string().regex(/([1-9]|1[0-2]):[0-5][0-9][ap]m/)))
    .transform(transformTime),
  endTime: z
    .optional(z.literal("").or(z.string().regex(/([1-9]|1[0-2]):[0-5][0-9][ap]m/)))
    .transform(transformTime),
  excludeRestrictionCodes: z
    .string()
    .optional()
    .transform((codes, ctx) => {
      if (!codes) return undefined;
      const parsedCodes: Array<(typeof restrictionCodes)[number]> = [];
      for (const code of codes.split(",").map((code) => code.trim())) {
        if (!isValidRestrictionCode(code)) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: `'${code}' is not a valid restriction code. Valid restriction codes are ${restrictionCodes.join(", ")}.`,
          });
          return z.NEVER;
        }
        parsedCodes.push(code);
      }
      return parsedCodes;
    }),
});

export const hourMinuteSchema = z.object({
  hour: z.number(),
  minute: z.number(),
});

export const websocSectionMeetingSchema = z.discriminatedUnion("timeIsTBA", [
  z.object({
    timeIsTBA: z.literal<boolean>(true),
  }),
  z.object({
    timeIsTBA: z.literal<boolean>(false),
    bldg: z.string().array(),
    days: z.string(),
    startTime: hourMinuteSchema,
    endTime: hourMinuteSchema,
  }),
]);

export const websocSectionFinalExamSchema = z.discriminatedUnion("examStatus", [
  z.object({
    examStatus: z.literal<FinalExamStatus>("NO_FINAL"),
  }),
  z.object({
    examStatus: z.literal<FinalExamStatus>("TBA_FINAL"),
  }),
  z.object({
    examStatus: z.literal<FinalExamStatus>("SCHEDULED_FINAL"),
    dayOfWeek: z.string(),
    month: z.number(),
    day: z.number(),
    startTime: hourMinuteSchema,
    endTime: hourMinuteSchema,
    bldg: z.string().array(),
  }),
]);

export const websocSectionSchema = z.object({
  units: z.string(),
  status: z.enum(websocStatuses).or(z.literal("")),
  meetings: websocSectionMeetingSchema.array(),
  finalExam: websocSectionFinalExamSchema,
  sectionNum: z.string(),
  instructors: z.string().array(),
  maxCapacity: z.string(),
  sectionCode: z.string(),
  sectionType: z.enum(websocSectionTypes),
  numRequested: z.string(),
  restrictions: z.string(),
  numOnWaitlist: z.string(),
  numWaitlistCap: z.string(),
  sectionComment: z.string(),
  numNewOnlyReserved: z.string(),
  numCurrentlyEnrolled: z.object({
    totalEnrolled: z.string(),
    sectionEnrolled: z.string(),
  }),
  updatedAt: z.coerce.date(),
});

export const websocCourseSchema = z.object({
  sections: websocSectionSchema.array(),
  deptCode: z.string(),
  courseTitle: z.string(),
  courseNumber: z.string(),
  courseComment: z.string(),
  prerequisiteLink: z.string(),
  updatedAt: z.coerce.date(),
});

export const websocDepartmentSchema = z.object({
  courses: websocCourseSchema.array(),
  deptCode: z.string(),
  deptName: z.string(),
  deptComment: z.string(),
  sectionCodeRangeComments: z.string().array(),
  courseNumberRangeComments: z.string().array(),
  updatedAt: z.coerce.date(),
});

export const websocSchoolSchema = z.object({
  departments: websocDepartmentSchema.array(),
  schoolName: z.string(),
  schoolComment: z.string(),
  updatedAt: z.coerce.date(),
});

export const websocResponseSchema = z.object({
  schools: websocSchoolSchema.array(),
});

export const websocTermResponseSchema = z.object({
  shortName: z.string(),
  longName: z.string(),
});
