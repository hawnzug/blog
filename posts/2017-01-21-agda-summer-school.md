---
title: Some notes on Agda Summer School
---

After watching lecture video on [OPLSS](https://www.cs.uoregon.edu/research/summerschool/summer14/curriculum.html)
about Programming in Agda given by Ulf Norell,
I want to do some exercise and clone the [repo](https://github.com/UlfNorell/agda-summer-school),
but only to find that it cannot even pass the type checker. The steps in the
README is somewhat out of date. It takes me hours to figure out how to make it work, and here are some notes.

First you need Agda installed, and do not use agda standard library by default
because this project using another [library](https://github.com/UlfNorell/agda-prelude),
which is incompatible with the standard library. You may install Agda from your package
manager, or install it with stack or cabal.

Then, believe it or not, finally you must want to use Emacs to write Agda, so
install it if you haven't and setup agda-mod.

Now clone these two repositories.
```
git clone https://github.com/UlfNorell/agda-prelude
git clone https://github.com/UlfNorell/agda-summer-school
```

There are many ways to tell Agda about the location of the agda-prelude library,
you can refer to the [docs](http://agda.readthedocs.io/en/latest/tools/package-system.html).
I simply add the agda-prelude to `~/.agda/defaults` and `~/.agda/libraries`.

I'm using Agda version 2.5.2 but the default branch of that [repo](https://github.com/UlfNorell/agda-summer-school)
is only compatible with Agda 2.4.2. So if you are using the same version as me,
you need checkout to another branch called OPLSS-2.5.1.

Install Haskell package ieee754 and text.

```
stack install ieee754
stack install text
```

Add these lines into `agda-summer-school/exercises/Lambda.agda` before the
main function.

```
{-# IMPORT Data.Text #-}
{-# IMPORT Data.Text.IO #-}
postulate readFile : String -> IO String
{-# COMPILED readFile Data.Text.IO.readFile . Data.Text.unpack #-}
```

Now we can compile `Lambda.agda` and run the executable.
Using stack to run agda will ensure that GHC can find your pre-installed Haskell packages.
```
stack exec -- agda -c Lambda.agda
./Lambda example.lam
```

Now we can do the exercises and play with Agda!
