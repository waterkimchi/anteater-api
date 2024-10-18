export const calendarSchema = `#graphql
type CalendarTerm @cacheControl(maxAge: 86400) {
    year: String!
    quarter: Term!
    instructionStart: String!
    instructionEnd: String!
    finalsStart: String!
    finalsEnd: String!
    socAvailable: String!
}

extend type Query {
    calendarTerm(year: String!, quarter: Term!): CalendarTerm!
    allCalendarTerms: [CalendarTerm!]!
}
`;
