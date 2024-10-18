/**
 * Type guard that asserts the input is defined.
 */
export const notNull = <T>(x: T): x is NonNullable<T> => x != null;
