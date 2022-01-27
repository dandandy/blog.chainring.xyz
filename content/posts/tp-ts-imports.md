---
title: "fp-ts Simple Import Convention"
date: 2022-01-25T21:49:58+11:00
draft: false
---

When using the [fp-ts](https://gcanti.github.io/fp-ts/) library we can end up with files containing many imports of different functors, applicative or monads. Managing fp-ts library imports can be a challenge because Typescript offers us many different ways to import libraries. There are [other blog articles](https://blog.atomist.com/typescript-imports/) that already break down the different ways we can import libraries, but due to the nature of fp-ts I suggest this simple import convention which will make your code more understandable and concise than just doing what your IDE suggests.

An import convention is necessary when using fp-ts because a lot of the different files in the library have colliding namespaces. For example, by definition all functors have a `map` function. To get around this colliding namespace problem we should use qualified imports for all of the library files. The import should be qualified with the upper case initial of the file name:

```typescript
import * as O from "fp-ts/Option"
import * as E from "fp-ts/Either"
...
```

This way we can access map for Option and Either via `O.map` and `E.map` respectively.

For the types in each of the library files we have a separate import:

```typescript
...
import { Option } from "fp-ts/Option"
import { Either } from "fp-ts/Either"
```

By importing the types separately we only need to write `Either` instead of `E.Either` in our type signatures, allowing for cleaner type signatures.

In comparison to this simple import convention, IDE auto-imports are inadequate since they tend to prefer unqualified imports. Like I mentioned above, unqualified imports are not helpful in this instance because of the colliding namespaces of the different parts of the fp-ts library. 
