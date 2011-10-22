Lecture Notes for Class 2 on Haskell Programming.


So if you looked quickly at the code from the last class you may have made the logical
but incorrect assumption that, like Python, Haskell is a dynamically typed language. 
After all there are no type signatures whatsoever, the only possible hint to a type 
system at all is one or two uses of 'fromIntegral', but Python has methods like 
'str()', so this seems like no big deal.

However if you wrote and compiled some Haskell you probably know it has a Type system,
since very likely any errors you had were type errors ;)

It turns out that Haskell doesn't need type declarations like most other statically 
typed langauged, it uses something called Type Inference, to make a guess on what type
you meant based on how you used a function.  If you're feeling particularly nerdy 
you can investigate Hindley-Milner type inference http://en.wikipedia.org/wiki/Hindley%E2%80%93Milner

Not only does Haskell have a Type system but is has probably the most powerful type
system in use.  This is one of Haskell's greatest strengths and one of the strongest
reasons that once your code compiles, it also probably works.

Let's look at some of our code from last lecture

>add1 x = 1 + x

If we're using ghci we can actually check what type is inferred by typing

:t add1

but before we do that let's go ahead and try some type signatures...

>add1v1 :: Int -> Int
>add1v1 x = 1 + x

This is a pretty reasonably type signature right? Coming from C/C++ this makes sense
the first 'Int' is the type that our argument is and the second 'Int' is what
we expect our result to be

'Int' is a Haskell type is that very similiar to 'int' in C/C++

We could do this another way

>add1v2 :: Integer -> Integer
>add1v2 x = 1 + x

So what's the difference here?

One limitation with 'Int' is that it's bounded by some max
for example

>ex1 = add1v1 123456789123456789

is -1395630314 because we have over flow

but this 

>ex2 = add1v2 123456789123456789

is 123456789123456790 because the Integer class is not bounded.
Math nerds and people who like computing large numbers will really appreciate that
this is built in, Haskell has a lot of smart features like this.

Okay so let's try one more time

>add1v3 :: Double -> Double
>add1v3 x = x + 1

Once again this is sensible since there are times were we don't want to have to cast
to a double... 

But this is also a pain in the butt right? We really, really don't want to have to have
at least 3 different functions just to add things we call numbers...

So let's examine what our type infrence thoguht our original add1 should be

We'll use that to make our final add1

>add1v4 :: Num a => a -> a
>add1v4 x = x + 1

So what's going on here?

