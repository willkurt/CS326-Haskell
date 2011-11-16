Lecture Notes for Class 5 on Haskell Programming

>import Control.Monad

-- More Maybe

By this point you're probably getting pretty comfortable
with the idea of 'Maybe', it provides a really elegant way of
of dealing with computations that may have failed

We've also talked about how 'Maybe' provides a context around
a computation and also how, in a strange way, Maybe is both like
a List and like IO.

Let's look at some Maybe values

>x :: Maybe Integer
>x = Just 5

>y :: Maybe Integer
>y = Just 7

>z :: Maybe Integer
>z = Nothing

These are all type Maybe Int, and there's some pretty obvious
things we might like to do with these... for example add them
together!

But this is actually furstratingly difficult

The most simply
x + y

fails completely

So I guess we need to write our own

>maybeAdd (Just a) (Just b) = Just (a + b)

This works but.. what if we use 'z'

So we need to add another pattern...

>maybeAdd Nothing _ = Nothing

We want this result to be 'Nothing' becuase a computation has failed
so any additional computation we do should also be Nothing

Oh and we of course have to also add the case where the arguements are 
reversed

>maybeAdd _ Nothing = Nothing

Now we also want to do multiplication, subtraction, division... yeck!
I thought functional programming was going to make life more elegant.
But we have to implement all these ourselves!

Well we're getting better at Haskell now so we shold be able to 
be smarter than this...

we can solve the generic case of binary functions for Maybe

>maybeBin :: (t -> t -> a) -> Maybe t -> Maybe t -> Maybe a
>maybeBin f (Just a) (Just b) = Just (f a b)
>maybeBin _ Nothing _ = Nothing
>maybeBin _ _ Nothing = Nothing

so this is definitely better... we can now define maybeAdd this way

>maybeAddv2 = maybeBin (+)

and multiplication

>maybeMult = maybeBin (*)

subtraction...

>maybeSub = maybeBin (-)

Much better... but that still isn't that great.

--Finally! Monads!

So last class we talked about how Lists, IO and Maybe were all members of 
the type class 'Functor' this simply ment that in a weird way all three of
these can be 'mapped' over the same way a List can.  Today we'll talk
about another class all of these belong to, the typeclass Monad, defined:

class Monad m where
  (>>=) :: m a -> (a -> m b) -> m b
  (>>) :: m a -> m b -> m b
  return :: a -> m a
  fail :: String -> m a


So unlike Functor which only demands 'fmap' be defined,  a Monad
has 4 functions which must be defined

However we're only going to really concern ourselves with 
(>>=) called 'bind'

and the already familiary
return

So we we look at the type signature for >>= we'll see
that it takes a type in a context
'm a' could be for example 'Maybe Int'

and takes a function takes the type within the context 
and returns it as a type in a context
and then return that

to make it clear we could have
Maybe Int -> (Int -> Maybe String) -> Maybe String

if you look 'return' has the same type as the second half of bind

>identity1 = x >>= return
>identity2 = z >>= return

So 'bind' takes care of all the worrying about matching Nothing vs Just

let's do an example that matches our previous type

>maybeShow m = m >>= \a-> return $ show a

What makes >>= really useful is we can change a bunch 
of actions together

>maybeShowExcited m = m >>= (\a -> return $ show a) >>= (\a -> return $ a ++ "!!!")

What's even cooler is that this doesn't work just on Maybe types, but
on all Monads, which means we could use this exact functions on IO types
and even lists

>listExample = maybeShowExcited [1,2,3,4,5]

Also note that this is an excellent example of when lambdas makes sense
we could have made these all named functions, but that would have taken up
more space and thinking than needed.

So using this knowledge let's write our add function again

>mAdd m1 m2 = m1 >>= (\a-> m2 >>= (\b -> return $ a  + b))

This technique of taking a normal function and turning it into
one that operates on Monads is so common that there's a built-in
function in the module Control.Monad called 'liftM'
which will take a regular function and 'lifts' it into on
that operates on Monads

For add we need to use 'liftM2' which works on functions with 2 args

>mAdd2 :: (Num b, Monad m) => m b -> m b -> m b
>mAdd2 = liftM2 (+)

Now one more really neat thing is that just like 'maybeShowExictied'
our add works on ALL Monads.

Now if we remember that a List can also be seen as a way to describe
non-deterministic computations, then we can describe all possible
sums of

>listA = [1,2,3,4,5]

and

>listB = [6,7,8,9,10,11,12]

this way

>possible = mAdd listA listB

Okay so if you were remember than IO is a Monad and everything 
you can do to one Monad you can do to another than you
might have wondered if we could just solve our
add problem the same way we would in io, that is

main = do 
     a <- x
     b <- y
     return $ a + b

and in fact we can!
the 'do' syntax is not specific to IO, but to all Monads!!!

So we can define mAdd one more time

>mAddDo m1 m2 = do
>  a <- m1
>  b <- m2
>  return $ a + b

Just a note though, Python often touts "there's one right way" well in Haskell there's
usually a few ;) one of the challenges learning Haskell is that code you'll find
in the wild can be written in many, many different ways. Of course the benefit to you
is there's many ways you can solve your problem.

So by now you should have started to see the secret of 'do'

'do' is just syntaxtic sugar for chaining together >>= operations

let's go back to typical IO example and write it without 'do'

oh and we'll also cover that '>>' syntax,
if you look at it's type signature
  (>>) :: m a -> m b -> m b
all it does is call on function and then take anther,
returning only the result of the later... it ill make more sense in action



>mainDo = do 
>  putStrLn "Hi What is your name"
>  name <- getLine
>  greeting <- return "Hi there "
>  putStrLn $ greeting ++ name

is equivalent to

>main = putStrLn "Hi What is your name?" >>=
>       (\_ -> getLine >>=
>        (\name -> (return "Hi there ") >>= 
>         (\greeting -> putStrLn $ greeting ++ name))) 

So hopefully now the 'do' syntax doesn't seem quite so much
like weird imperative 'magic' mixed in with your pure functional goodness ;)


Well that's it for these lectures! I hope you have a good sense of where you 
are in Haskell, there's a lot more out there, and Monads alone could fill up 
your free time for many months, maybe years.  

If you like functional programming but would prefer to not have the headache of Monads 
here's a basic overview of functional programming langauges


There are 2 major families of functional languages

Lisps and ML Derivatives

Lisps are typically dynamics languages and make use of
prefix notation.
e.g.
(== (+ 2 2))
Many people struggle with the syntax at first, but the cool thing
is that you're always working with essentially a tree structure for all
of your code, which let's you do some amazing stuff.

The biggest lisps are
Scheme
Common Lisp
and more contemporarily Clojure
Clojure and Scheme adhere more closely to the princples of functional programming
than Common Lisp

Haskell is a member of the ML family.

There are to major ML lanagues in use today Standard ML and OCAML
OCAML being the more widely used of the 2
Both have a very similiar type system to Haskell, but you'll have less 
head-desking from Monads ;)  If you like Haskell but would like just a little
less 'purity'/more sanity OCAML is probably a great choice.

If you're a .NET programmer, F# is the offering of choice and is essentially
a port of OCAML to the .NET environment. There's currently a pretty active
community of .NET users plus you can always claim.

Scala is yet another functional langauge, which runs on the JVM. Scala also has
a powerful type system and allows for objects.  This language has pretty large
traction, if you wanted to move to the Bay Area and get paid actual money to write
functional code this would be the way to go.

It's also worth mentioning Erlang, which is also a functional languae and know for 
extreme efficienty in handling concurrency.

Feel free to email me any time with questions! I'm always up for a good Functional
Programming talk ;D
