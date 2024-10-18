/**
 * Data that is specific to a publishable key.
 *
 * A publishable key is intended for frontend use, so we ensure that the origin of the request bearing this key matches
 * one of the origins on file. If it doesn't, we reject the request.
 */
type PublishableKeyData = {
  _type: "publishable";
  origins: string[];
};

/**
 * Data that is specific to a secret key.
 *
 * A secret key is intended for backend use, so we don't do any additional verification.
 */
type SecretKeyData = {
  _type: "secret";
};

/**
 * Data that is common to all types of keys.
 */
type BaseKeyData = {
  /**
   * If present, requests made using this key will be subject to a rate limit of this many requests per hour,
   * instead of the default limit.
   */
  rateLimitOverride?: number;
};

export type KeyData = BaseKeyData & (PublishableKeyData | SecretKeyData);
