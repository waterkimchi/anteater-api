export const gradesSchema = `#graphql
type RawGrade @cacheControl(maxAge: 86400) {
    year: String!
    quarter: Term!
    sectionCode: String!
    department: String!
    courseNumber: String!
    courseNumeric: Int!
    geCategories: [String!]!
    instructors: [String!]!
    gradeACount: Int!
    gradeBCount: Int!
    gradeCCount: Int!
    gradeDCount: Int!
    gradeFCount: Int!
    gradePCount: Int!
    gradeNPCount: Int!
    gradeWCount: Int!
    averageGPA: Float
}

type GradesOptions @cacheControl(maxAge: 86400) {
    years: [String!]!
    departments: [String!]!
    sectionCodes: [String!]!
    instructors: [String!]!
}

type AggregateGradesSection @cacheControl(maxAge: 86400) {
    year: String!
    quarter: Term!
    sectionCode: String!
    department: String!
    courseNumber: String!
    courseNumeric: Int!
    geCategories: [String!]!
    instructors: [String!]!
}

type AggregateGradesDistribution @cacheControl(maxAge: 86400) {
    gradeACount: Int!
    gradeBCount: Int!
    gradeCCount: Int!
    gradeDCount: Int!
    gradeFCount: Int!
    gradePCount: Int!
    gradeNPCount: Int!
    gradeWCount: Int!
    averageGPA: Float
}

type AggregateGrades @cacheControl(maxAge: 86400) {
    sectionList: [AggregateGradesSection!]!
    gradeDistribution: AggregateGradesDistribution!
}

type AggregateGradeByCourse @cacheControl(maxAge: 86400) {
    department: String!
    courseNumber: String!
    gradeACount: Int!
    gradeBCount: Int!
    gradeCCount: Int!
    gradeDCount: Int!
    gradeFCount: Int!
    gradePCount: Int!
    gradeNPCount: Int!
    gradeWCount: Int!
    averageGPA: Float
}

type AggregateGradeByOffering @cacheControl(maxAge: 86400) {
    department: String!
    courseNumber: String!
    instructor: String!
    gradeACount: Int!
    gradeBCount: Int!
    gradeCCount: Int!
    gradeDCount: Int!
    gradeFCount: Int!
    gradePCount: Int!
    gradeNPCount: Int!
    gradeWCount: Int!
    averageGPA: Float
}

input GradesQuery {
    year: String
    quarter: Term
    instructor: String
    department: String
    courseNumber: String
    sectionCode: String
    division: CourseLevel
    ge: String
    excludePNP: Boolean
}

extend type Query {
    rawGrades(query: GradesQuery): [RawGrade!]!
    gradesOptions(query: GradesQuery): GradesOptions!
    aggregateGrades(query: GradesQuery): AggregateGrades!
    aggregateGradesByCourse(query: GradesQuery): [AggregateGradeByCourse!]!
    aggregateGradesByOffering(query: GradesQuery): [AggregateGradeByOffering!]!
}
`;
