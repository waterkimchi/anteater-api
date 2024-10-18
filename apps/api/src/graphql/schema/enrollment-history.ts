export const enrollmentHistorySchema = `#graphql
type EnrollmentHistoryMeeting @cacheControl(maxAge: 300) {
    bldg: [String!]!
    days: String!
    time: String!
}

type EnrollmentHistory @cacheControl(maxAge: 300) {
    year: String!
    quarter: Term!
    sectionCode: String!
    department: String!
    courseNumber: String!
    sectionType: SectionType!
    sectionNum: String!
    units: String!
    instructors: [String!]!
    meetings: [EnrollmentHistoryMeeting!]!
    finalExam: String!
    dates: [String!]!
    maxCapacityHistory: [String!]!
    totalEnrolledHistory: [String!]!
    waitlistHistory: [String!]!
    waitlistCapHistory: [String!]!
    requestedHistory: [String!]!
    newOnlyReservedHistory: [String!]!
    statusHistory: [String!]!
}

input EnrollmentHistoryQuery {
    year: String
    quarter: Term
    instructorName: String
    department: String
    courseNumber: String
    sectionCode: Int
    sectionType: SectionType
}

extend type Query {
    enrollmentHistory(query: EnrollmentHistoryQuery): [EnrollmentHistory!]!
}
`;
