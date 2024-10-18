DO $$ BEGIN
 CREATE TYPE "public"."course_level" AS ENUM('LowerDiv', 'UpperDiv', 'Graduate');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."division" AS ENUM('Undergraduate', 'Graduate');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."final_exam_status" AS ENUM('SCHEDULED_FINAL', 'TBA_FINAL', 'NO_FINAL');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."term" AS ENUM('Fall', 'Winter', 'Spring', 'Summer1', 'Summer10wk', 'Summer2');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."websoc_section_type" AS ENUM('Act', 'Col', 'Dis', 'Fld', 'Lab', 'Lec', 'Qiz', 'Res', 'Sem', 'Stu', 'Tap', 'Tut');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."websoc_status" AS ENUM('OPEN', 'Waitl', 'FULL', 'NewOnly');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "calendar_term" (
	"id" varchar PRIMARY KEY GENERATED ALWAYS AS ("calendar_term"."year" || ' ' || CASE WHEN "calendar_term"."quarter" = 'Fall' THEN 'Fall' WHEN "calendar_term"."quarter" = 'Winter' THEN 'Winter' WHEN "calendar_term"."quarter" = 'Spring' THEN 'Spring' WHEN "calendar_term"."quarter" = 'Summer1' THEN 'Summer1' WHEN "calendar_term"."quarter" = 'Summer10wk' THEN 'Summer10wk' WHEN "calendar_term"."quarter" = 'Summer2' THEN 'Summer2' ELSE '' END) STORED NOT NULL,
	"year" varchar NOT NULL,
	"quarter" "term" NOT NULL,
	"instruction_start" date NOT NULL,
	"instruction_end" date NOT NULL,
	"finals_start" date NOT NULL,
	"finals_end" date NOT NULL,
	"soc_available" date NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "course" (
	"id" varchar PRIMARY KEY NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"department" varchar NOT NULL,
	"course_number" varchar NOT NULL,
	"course_numeric" integer GENERATED ALWAYS AS (CASE REGEXP_REPLACE("course"."course_number", '\D', '', 'g') WHEN '' THEN 0 ELSE REGEXP_REPLACE("course"."course_number", '\D', '', 'g')::INTEGER END) STORED NOT NULL,
	"school" varchar NOT NULL,
	"title" varchar NOT NULL,
	"course_level" "course_level" NOT NULL,
	"min_units" numeric(4, 2) NOT NULL,
	"max_units" numeric(4, 2) NOT NULL,
	"description" text NOT NULL,
	"department_name" varchar NOT NULL,
	"prerequisite_tree" json NOT NULL,
	"prerequisite_text" text NOT NULL,
	"repeatability" varchar NOT NULL,
	"grading_option" varchar NOT NULL,
	"concurrent" varchar NOT NULL,
	"same_as" varchar NOT NULL,
	"restriction" text NOT NULL,
	"overlap" text NOT NULL,
	"corequisites" text NOT NULL,
	"is_ge_1a" boolean NOT NULL,
	"is_ge_1b" boolean NOT NULL,
	"is_ge_2" boolean NOT NULL,
	"is_ge_3" boolean NOT NULL,
	"is_ge_4" boolean NOT NULL,
	"is_ge_5a" boolean NOT NULL,
	"is_ge_5b" boolean NOT NULL,
	"is_ge_6" boolean NOT NULL,
	"is_ge_7" boolean NOT NULL,
	"is_ge_8" boolean NOT NULL,
	"ge_text" varchar NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "degree" (
	"id" varchar PRIMARY KEY NOT NULL,
	"name" varchar NOT NULL,
	"division" "division" NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "instructor" (
	"ucinetid" varchar PRIMARY KEY NOT NULL,
	"name" varchar NOT NULL,
	"title" varchar NOT NULL,
	"email" varchar NOT NULL,
	"department" varchar NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "instructor_to_websoc_instructor" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"instructor_ucinetid" varchar,
	"websoc_instructor_name" varchar NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "larc_section" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"course_id" uuid NOT NULL,
	"days" varchar NOT NULL,
	"time" varchar NOT NULL,
	"instructor" varchar NOT NULL,
	"bldg" varchar NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "major" (
	"id" varchar PRIMARY KEY NOT NULL,
	"degree_id" varchar NOT NULL,
	"code" varchar NOT NULL,
	"name" varchar NOT NULL,
	"requirements" json NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "minor" (
	"id" varchar PRIMARY KEY NOT NULL,
	"name" varchar NOT NULL,
	"requirements" json NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "prerequisite" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"dep_dept" varchar NOT NULL,
	"prerequisite_id" varchar NOT NULL,
	"dependency_id" varchar NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "specialization" (
	"id" varchar PRIMARY KEY NOT NULL,
	"major_id" varchar NOT NULL,
	"name" varchar NOT NULL,
	"requirements" json NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "study_location" (
	"id" varchar PRIMARY KEY NOT NULL,
	"name" varchar NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "study_room" (
	"id" varchar PRIMARY KEY NOT NULL,
	"name" varchar NOT NULL,
	"capacity" integer NOT NULL,
	"location" varchar NOT NULL,
	"description" varchar NOT NULL,
	"directions" varchar NOT NULL,
	"tech_enhanced" boolean NOT NULL,
	"study_location_id" varchar NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "study_room_slot" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"study_room_id" varchar NOT NULL,
	"start" timestamp NOT NULL,
	"end" timestamp NOT NULL,
	"is_available" boolean NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "websoc_course" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"department_id" uuid NOT NULL,
	"course_id" varchar GENERATED ALWAYS AS ("websoc_course"."dept_code" || "websoc_course"."course_number") STORED NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"year" varchar NOT NULL,
	"quarter" "term" NOT NULL,
	"school_name" varchar NOT NULL,
	"dept_code" varchar NOT NULL,
	"course_title" varchar NOT NULL,
	"course_number" varchar NOT NULL,
	"course_numeric" integer GENERATED ALWAYS AS (CASE REGEXP_REPLACE("websoc_course"."course_number", '\D', '', 'g') WHEN '' THEN 0 ELSE REGEXP_REPLACE("websoc_course"."course_number", '\D', '', 'g')::INTEGER END) STORED NOT NULL,
	"course_comment" text NOT NULL,
	"prerequisite_link" varchar NOT NULL,
	"is_ge_1a" boolean DEFAULT false NOT NULL,
	"is_ge_1b" boolean DEFAULT false NOT NULL,
	"is_ge_2" boolean DEFAULT false NOT NULL,
	"is_ge_3" boolean DEFAULT false NOT NULL,
	"is_ge_4" boolean DEFAULT false NOT NULL,
	"is_ge_5a" boolean DEFAULT false NOT NULL,
	"is_ge_5b" boolean DEFAULT false NOT NULL,
	"is_ge_6" boolean DEFAULT false NOT NULL,
	"is_ge_7" boolean DEFAULT false NOT NULL,
	"is_ge_8" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "websoc_department" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"school_id" uuid NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"year" varchar NOT NULL,
	"quarter" "term" NOT NULL,
	"dept_code" varchar NOT NULL,
	"dept_name" varchar NOT NULL,
	"dept_comment" text NOT NULL,
	"section_code_range_comments" text[] NOT NULL,
	"course_number_range_comments" text[] NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "websoc_instructor" (
	"name" varchar PRIMARY KEY NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "websoc_location" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"building" varchar NOT NULL,
	"room" varchar NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "websoc_meta" (
	"name" varchar PRIMARY KEY NOT NULL,
	"last_scraped" timestamp with time zone NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "websoc_school" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"year" varchar NOT NULL,
	"quarter" "term" NOT NULL,
	"school_name" varchar NOT NULL,
	"school_comment" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "websoc_section" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"course_id" uuid NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"year" varchar NOT NULL,
	"quarter" "term" NOT NULL,
	"units" varchar NOT NULL,
	"status" "websoc_status",
	"instructors" text[] NOT NULL,
	"meetings" json NOT NULL,
	"final_exam_string" varchar NOT NULL,
	"final_exam" json NOT NULL,
	"section_num" varchar NOT NULL,
	"max_capacity" integer NOT NULL,
	"section_code" integer NOT NULL,
	"section_type" "websoc_section_type" NOT NULL,
	"num_requested" integer NOT NULL,
	"restriction_string" varchar NOT NULL,
	"restriction_a" boolean DEFAULT false NOT NULL,
	"restriction_b" boolean DEFAULT false NOT NULL,
	"restriction_c" boolean DEFAULT false NOT NULL,
	"restriction_d" boolean DEFAULT false NOT NULL,
	"restriction_e" boolean DEFAULT false NOT NULL,
	"restriction_f" boolean DEFAULT false NOT NULL,
	"restriction_g" boolean DEFAULT false NOT NULL,
	"restriction_h" boolean DEFAULT false NOT NULL,
	"restriction_i" boolean DEFAULT false NOT NULL,
	"restriction_j" boolean DEFAULT false NOT NULL,
	"restriction_k" boolean DEFAULT false NOT NULL,
	"restriction_l" boolean DEFAULT false NOT NULL,
	"restriction_m" boolean DEFAULT false NOT NULL,
	"restriction_n" boolean DEFAULT false NOT NULL,
	"restriction_o" boolean DEFAULT false NOT NULL,
	"restriction_r" boolean DEFAULT false NOT NULL,
	"restriction_s" boolean DEFAULT false NOT NULL,
	"restriction_x" boolean DEFAULT false NOT NULL,
	"num_on_waitlist" integer,
	"num_waitlist_cap" integer,
	"section_comment" text NOT NULL,
	"num_new_only_reserved" integer,
	"num_currently_total_enrolled" integer,
	"num_currently_section_enrolled" integer,
	"is_cancelled" boolean GENERATED ALWAYS AS ("websoc_section"."section_comment" LIKE '*** CANCELLED ***%') STORED NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "websoc_section_enrollment" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"section_id" uuid NOT NULL,
	"created_at" date DEFAULT now() NOT NULL,
	"year" varchar NOT NULL,
	"quarter" "term" NOT NULL,
	"max_capacity" integer NOT NULL,
	"num_currently_total_enrolled" integer,
	"num_on_waitlist" integer,
	"num_waitlist_cap" integer,
	"num_requested" integer,
	"num_new_only_reserved" integer,
	"status" "websoc_status"
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "websoc_section_grade" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"section_id" uuid NOT NULL,
	"grade_a_count" integer NOT NULL,
	"grade_b_count" integer NOT NULL,
	"grade_c_count" integer NOT NULL,
	"grade_d_count" integer NOT NULL,
	"grade_f_count" integer NOT NULL,
	"grade_p_count" integer NOT NULL,
	"grade_np_count" integer NOT NULL,
	"grade_w_count" integer NOT NULL,
	"average_gpa" numeric(3, 2),
	CONSTRAINT "websoc_section_grade_section_id_unique" UNIQUE("section_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "websoc_section_meeting" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"section_id" uuid NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"section_code" integer NOT NULL,
	"meeting_index" integer NOT NULL,
	"time_string" varchar NOT NULL,
	"time_is_tba" boolean GENERATED ALWAYS AS ("websoc_section_meeting"."time_string" LIKE '%TBA%') STORED NOT NULL,
	"start_time" timestamp,
	"end_time" timestamp,
	"days_string" varchar NOT NULL,
	"meets_monday" boolean,
	"meets_tuesday" boolean,
	"meets_wednesday" boolean,
	"meets_thursday" boolean,
	"meets_friday" boolean,
	"meets_saturday" boolean,
	"meets_sunday" boolean
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "websoc_section_meeting_to_location" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"section_id" uuid NOT NULL,
	"location_id" uuid NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "websoc_section_to_instructor" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"section_id" uuid NOT NULL,
	"instructor_name" varchar NOT NULL
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "instructor_to_websoc_instructor" ADD CONSTRAINT "instructor_to_websoc_instructor_instructor_ucinetid_instructor_ucinetid_fk" FOREIGN KEY ("instructor_ucinetid") REFERENCES "public"."instructor"("ucinetid") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "instructor_to_websoc_instructor" ADD CONSTRAINT "instructor_to_websoc_instructor_websoc_instructor_name_websoc_instructor_name_fk" FOREIGN KEY ("websoc_instructor_name") REFERENCES "public"."websoc_instructor"("name") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "larc_section" ADD CONSTRAINT "larc_section_course_id_websoc_course_id_fk" FOREIGN KEY ("course_id") REFERENCES "public"."websoc_course"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "major" ADD CONSTRAINT "major_degree_id_degree_id_fk" FOREIGN KEY ("degree_id") REFERENCES "public"."degree"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "specialization" ADD CONSTRAINT "specialization_major_id_major_id_fk" FOREIGN KEY ("major_id") REFERENCES "public"."major"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "study_room" ADD CONSTRAINT "study_room_study_location_id_study_location_id_fk" FOREIGN KEY ("study_location_id") REFERENCES "public"."study_location"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "study_room_slot" ADD CONSTRAINT "study_room_slot_study_room_id_study_room_id_fk" FOREIGN KEY ("study_room_id") REFERENCES "public"."study_room"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "websoc_course" ADD CONSTRAINT "websoc_course_department_id_websoc_department_id_fk" FOREIGN KEY ("department_id") REFERENCES "public"."websoc_department"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "websoc_department" ADD CONSTRAINT "websoc_department_school_id_websoc_school_id_fk" FOREIGN KEY ("school_id") REFERENCES "public"."websoc_school"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "websoc_section" ADD CONSTRAINT "websoc_section_course_id_websoc_course_id_fk" FOREIGN KEY ("course_id") REFERENCES "public"."websoc_course"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "websoc_section_enrollment" ADD CONSTRAINT "websoc_section_enrollment_section_id_websoc_section_id_fk" FOREIGN KEY ("section_id") REFERENCES "public"."websoc_section"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "websoc_section_grade" ADD CONSTRAINT "websoc_section_grade_section_id_websoc_section_id_fk" FOREIGN KEY ("section_id") REFERENCES "public"."websoc_section"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "websoc_section_meeting" ADD CONSTRAINT "websoc_section_meeting_section_id_websoc_section_id_fk" FOREIGN KEY ("section_id") REFERENCES "public"."websoc_section"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "websoc_section_meeting_to_location" ADD CONSTRAINT "websoc_section_meeting_to_location_section_id_websoc_section_meeting_id_fk" FOREIGN KEY ("section_id") REFERENCES "public"."websoc_section_meeting"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "websoc_section_meeting_to_location" ADD CONSTRAINT "websoc_section_meeting_to_location_location_id_websoc_location_id_fk" FOREIGN KEY ("location_id") REFERENCES "public"."websoc_location"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "websoc_section_to_instructor" ADD CONSTRAINT "websoc_section_to_instructor_section_id_websoc_section_id_fk" FOREIGN KEY ("section_id") REFERENCES "public"."websoc_section"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "websoc_section_to_instructor" ADD CONSTRAINT "websoc_section_to_instructor_instructor_name_websoc_instructor_name_fk" FOREIGN KEY ("instructor_name") REFERENCES "public"."websoc_instructor"("name") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "instructor_idx" ON "instructor_to_websoc_instructor" USING btree ("instructor_ucinetid");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "websoc_instructor_idx" ON "instructor_to_websoc_instructor" USING btree ("websoc_instructor_name");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "instructor_to_websoc_instructor_idx" ON "instructor_to_websoc_instructor" USING btree ("instructor_ucinetid","websoc_instructor_name");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "larc_section_course_idx" ON "larc_section" USING btree ("course_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "degree_idx" ON "major" USING btree ("degree_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "dependency_dept_idx" ON "prerequisite" USING btree ("dep_dept");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "prereq_id_idx" ON "prerequisite" USING btree ("prerequisite_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "depend_id_idx" ON "prerequisite" USING btree ("dependency_id");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "prerequisite_idx" ON "prerequisite" USING btree ("prerequisite_id","dependency_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "major_idx" ON "specialization" USING btree ("major_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "study_location_idx" ON "study_room" USING btree ("study_location_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "study_room_idx" ON "study_room_slot" USING btree ("study_room_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "dept_idx" ON "websoc_course" USING btree ("department_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "websoc_course_course_id_idx" ON "websoc_course" USING btree ("course_id");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "websoc_course_idx" ON "websoc_course" USING btree ("year","quarter","school_name","dept_code","course_number","course_title");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "ge_1a_query_idx" ON "websoc_course" USING btree ("year","quarter","is_ge_1a");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "ge_1b_query_idx" ON "websoc_course" USING btree ("year","quarter","is_ge_1a");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "ge_2_query_idx" ON "websoc_course" USING btree ("year","quarter","is_ge_1a");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "ge_3_query_idx" ON "websoc_course" USING btree ("year","quarter","is_ge_1a");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "ge_4_query_idx" ON "websoc_course" USING btree ("year","quarter","is_ge_1a");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "ge_5a_query_idx" ON "websoc_course" USING btree ("year","quarter","is_ge_1a");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "ge_5b_query_idx" ON "websoc_course" USING btree ("year","quarter","is_ge_1a");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "ge_6_query_idx" ON "websoc_course" USING btree ("year","quarter","is_ge_1a");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "ge_7_query_idx" ON "websoc_course" USING btree ("year","quarter","is_ge_1a");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "ge_8_query_idx" ON "websoc_course" USING btree ("year","quarter","is_ge_1a");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "dept_query_idx" ON "websoc_course" USING btree ("year","quarter","dept_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "course_query_idx" ON "websoc_course" USING btree ("year","quarter","dept_code","course_number");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "school_idx" ON "websoc_department" USING btree ("school_id");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "websoc_department_idx" ON "websoc_department" USING btree ("year","quarter","school_id","dept_code");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "websoc_location_idx" ON "websoc_location" USING btree ("building","room");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "websoc_school_idx" ON "websoc_school" USING btree ("year","quarter","school_name");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "course_idx" ON "websoc_section" USING btree ("course_id");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "websoc_section_idx" ON "websoc_section" USING btree ("year","quarter","section_code");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "meeting_section_idx" ON "websoc_section_enrollment" USING btree ("section_id");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "websoc_section_enrollment_idx" ON "websoc_section_enrollment" USING btree ("section_id","created_at");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "grade_section_idx" ON "websoc_section_grade" USING btree ("section_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "section_idx" ON "websoc_section_meeting" USING btree ("section_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "meeting_idx" ON "websoc_section_meeting_to_location" USING btree ("section_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "location_idx" ON "websoc_section_meeting_to_location" USING btree ("location_id");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "websoc_section_meeting_to_location_idx" ON "websoc_section_meeting_to_location" USING btree ("section_id","location_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "websoc_section_to_instructor_section_idx" ON "websoc_section_to_instructor" USING btree ("section_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "websoc_section_to_instructor_instructor_idx" ON "websoc_section_to_instructor" USING btree ("instructor_name");