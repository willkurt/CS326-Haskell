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

We have 2 concepts to introduce

The 'Num' you see there is what is refered to as a 
Type Class
and the 'a' is simply a Type Variable, it's a stand-in for any variety of types

Let's take a look at another function from last week...

>idLambda :: a -> a
>idLambda = \x -> x

again we've used a Type Variable
In this case 'a' is a stand-in for any possible type since our
input is of one type and our output is obviously of the same type
Type Variables are essential since it would be terrible to have
to write an 'idLambda' for each possible type in existance..

>intIdLambda :: Int -> Int
>intIdLambda  = \x -> x

but if we wanted to, we always could.  If you look at lists, all the major operations
on lists also use Type Variables for the same reason.

Now back to that Type Class 'Num'
'Int', 'Integer', 'Double' and many more are all belong to the Type Class 'Num'
what this means is that they are all guaranteed to have certain funtions defined 
for them: +, -, *, etc

Again this makes sense becuase it would be stupid to have to define our add1 function
for every single possible thing that could be added.

let's look at another from last time

>argIs1 :: Num a => (a -> t) -> t
>argIs1 func = func 1

So this type class looks a little different again
The type listed as '(a -> t)' may look weird but let's think about it for a minute
the first and only argument to this function is in fact another function
and that function will have it's own type signature!
So this expression in Parenthesis is simply saying "this is a function"
and since it returns a type 't' the ultimate value return is also of type 't'

But why another Type Variable?  Well nothing in out code as made it clear
what 'func' actually does! It could return a string for all we know.

If we want to make our function reflect out intention, that is it will return the 
same type we can specifiy this..

>argIs1v2 :: Num a => (a -> a) -> a
>argIs1v2 func = func 1

But wait! it takes an 'a' and returns an 'a', doesn't this mean it can't change the 
value?  The important thing to remember is that this is a Type Variable, all this
means is that we must return the same TYPE, but certainly not the same value

for demonstration we could have written this:

>argIs1v3 :: (Num a, Num b) => (a -> b) -> b
>argIs1v3 func = func 1

So what's the difference?

We're still constricting our return value to the Type Class 'Num', however it 
doesn't have to be the SAME type class, for example we could take an Int and return 
a Double, this would not be possible in our example above.

So hopefully you'll see that in Haskell the type signature tells us a lot 
about what a function does, and can also do a lot to define how it behaves.

Even though you have the power of type inference, I STRONGLY suggest that you 
write out your type signature in full, firstly type inference can be not exactly
what you mean, as seen above.  Additionlly thinking about the type helps you write
more thoughtfully and reduces the probability that the compiler will yell at you ;)

A note on Type Classes: There are many of them, and they very useful
Two particularly useful are Read and Show

Types of Class 'Show' (which is most) implement a function named
'show' which takes their value and returns a string

>numShow :: Num a => a -> String
>numShow x = show x

Here we've retricted it a bit so that it will only show 'Num' but that's just for
demonstration.

Read is the opposite, Types of Class Read implement 'read' which takes a String
and return a value of their Type

>intRead :: String -> Int
>intRead x = read x 

Note here the type signature is essential. If the Type that is expected from 'read'
cannot be inferred and is not made explicit, read has no way to know what value to return!

if you just type in 
read "6" 
Haskell cannot possibly figure out what Type you want back!


Okay so hopefully you have a better sense of Haskell's amazing type system, there's
a lot more to it that we'll go into later.


So here's a new question for you, what's the type of

>main1 = do
>      putStrLn "What's my Type?"

It's even more odd right?
main1 :: IO()

We haven't seen this IO() before, and what the heck is the return value? I thought 
everything had to have a return value!

So back when I mentioned Referential Transparency and Side Effects a bit warning 
should have went off in your head.

Sure we can't have loops, or variables... big deal, we have recursion, we'll be fine.
Except... how.. in the world... are we going to do IO!!!!

You can't do IO without changing the world right?
right.

Most functional languages solve this problem by cheating, they say
"Hey we're 99% function, except IO"
The problem is there's not way to tell which code is 'pure' and which is 'impure'
All those cool guarantees we get with pure functional code go out the window if we
don't know if we're really being functional!

So Haskell has an interesting solution to this problem.  Everything that touchs IO
is 'tainted' and forever cannot be used outside of a 'pure' environment. 

When we write code in Haskell we try to write as much 'pure' code as possible, and then
only at the last minute do we let it become tainted by the impurity of IO.
That 'do' at the begining of main? It's part of being inside what is called the IO
monad. 

If you've been plaing arond there are a couple of other strange things that you may
have noticed

Let's walk through building building a tool that makes use of our Standard Deviation 
function as before.

Let's start with out pure code, first the sd function...

>mean xs = sum xs / fromIntegral(length xs)

>deviations xs = map (\x -> x -m) xs
>    where m = mean xs

>squareDeviations xs = map (^2) devs
>    where devs = deviations xs


>sumSquareDeviations xs = (sum . squareDeviations) xs

>sd xs = sqrt $ sumSqDeviations / lenMinus1
>        where sumSqDeviations = sumSquareDeviations xs
>              lenMinus1 = fromIntegral $ ((-1 + ) . length) xs

Filling in the types for that would be a good excerise, but for now let's be lazy ;)

What else do we need?

Well we need to take the user's input of a list and send it to sd, but it will be
a String form teh command line... of course we'll use read!

>inputToSd :: String -> Double
>inputToSd i = (sd . read) i

Rembember the '.' is for function composition, we're taking 'sd' and 'read' to make
one new function that takes a string, 'like read', and outputs a double, like 'sd'

A key point here is that we're still in a land of 'purity', no side effects so
far, but we're about done with that... now to our main


>main = do

Time for the dirty work.. IO :D

>    putStrLn "Enter a list for us to calculate"

since we're in now in an 'impure' space, we use '<-' to pull values 
out of impure funcitons, we can pretend the result is 'pure' and pass it to a 'pure'
function, but this is only becuase inside of a 'do' we promise never to return to purity

>    input <- getLine

now we finally get to use 'return'! the reason why is becuase we're using a 'pure' 
function but we're still in an 'impure' world, so we must 'return' it from the 'pure'
to the 'impure' and make it tainted forever!  We didn't need to make this explict 
with input because 'getLine' is already impure

>    answer <- return $ inputToSd input

one note, a 'do' statement must always end with an expression

>    putStrLn "Your answer is"
>    putStrLn $ show answer

and there we go!

For clarity here's all that without comments

main = do
    putStrLn "Enter a list for us to calculate"
    input <- getLine
    answer <- return $ inputToSd input
    putStrLn "Your answer is"
    putStrLn $ show answer

