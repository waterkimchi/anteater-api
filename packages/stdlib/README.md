# @packages/stdlib

This package contains an assortment of "standard library" functions that are used in different components of the API.

## Criteria for Inclusion

Utilities in this package should not reference any functions other than those found in the Node.js standard library, or functions that are already in the package.

If there is some code that has external dependencies that is being reused in the codebase, consider abstracting that code away in some other manner.
