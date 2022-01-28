---
title: "Using the fp-ts IO & Task monads together"
date: 2022-01-27T17:36:30+11:00
draft: false
---

> tldr: convert IO monads to Task monads 

Over the short while I've been using the [fp-ts](https://gcanti.github.io/fp-ts/) library I have found it a challenge to use different monads together. One case I recently came across was using the IO and Task monads together, however I came up with a simple solution: convert IO monads to Task monads, then proceed as usual with Task Monads. In this blog post I want to show how to convert an IO monad to a Task monad and why it is ok to do this.

This technique is useful when we have a function that does some kind of asynchronous action like an API call which also needs to handle Dates. We note that Dates in fp-ts are wrapped in the IO monad to maintain referential transparency. This conversion technique means that instead of the return signature being `IO<Task<A>>` it is `Task<A>`.

## How to convert an IO monad to a Task monad

In a Typescript project with the fp-ts library imported you can use the [FromIO](https://gcanti.github.io/fp-ts/modules/Task.ts.html#fromio) function to convert an IO monad to a Task monad:

```Typescript
import * as T from "fp-ts/Task"
import { Task } from "fp-ts/Task"
import * as D from "fp-ts/Date"
import * as IO from "fp-ts/IO"

const date: Task<Date> =  T.fromIO(D.create)
```

## Why is converting an IO monad to a Task monad acceptable

When we look at the interfaces defined for the IO and Task monads we notice that they are very similar with the only difference being that a Task always returns a promise:

```Typescript
interface IO<A> {
  (): A
}

interface Task<A> {
  (): Promise<A>
}
```

(links to the relevant documentation [here](https://gcanti.github.io/fp-ts/modules/Task.ts.html#task-overview) and [here](https://gcanti.github.io/fp-ts/modules/IO.ts.html#io-overview))

This means that in theory we can define a Task in terms of an IO monad like so:

```Typescript
type Task<A> = IO<Promise<A>>
```

which highlights at the fact that a Task is just an IO monad that returns a promise.

## Example

Let's say we want to write a function that will send the current date via a fetch API call and return the response. We would write the function like so using the conversion technique:

```Typescript
import * as T from "fp-ts/Task";
import * as TE from "fp-ts/TaskEither";
import { ReaderTaskEither } from "fp-ts/ReaderTaskEither";
import * as IO from "fp-ts/IO";
import axios, { AxiosResponse } from "axios";
import { pipe } from "fp-ts/lib/function";

const sendDate = <A>(
  currentDate: IO.IO<Date>
): ReaderTaskEither<{url: string}, Error, AxiosResponse<A>> => (config: {url: string}) => {
  return pipe(
    currentDate,        //  IO<Date>
    T.fromIO,           //  Task<Date>
    T.map((date) =>     //  Task<Task<Date>>
      TE.tryCatch(
        () => axios.post<A>(config.url, { date }),
        (error: unknown): Error => new Error(String(error))
      )
    ),
    T.flatten           //  Task<Task<Date>>
  );
};
```

The comments in the snippet above show the types as we move through the pipe. Note that we could use `T.chain` instead of `T.map` which would avoid the need for the `T.flatten`.