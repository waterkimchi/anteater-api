import { notNull } from "./not-null";

/**
 * If the input is defined, return it, otherwise return `null`.
 */
export const orNull = <T>(x: T): T | null => {
  return notNull(x) ? x : null;
};
