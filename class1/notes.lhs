Lecture Notes for Class 1 on Haskell Programming.

If you read no other book on Haskell, please take the time to read at least the first few chapters of:
Learn You a Haskell For Great Good
http://learnyouahaskell.com
It's free and it's fantastic!

So Welcome to Haskell!

Haskell is an amazing programming language, but it is also big, powerful and difficult (of course there is a relation between these attributes and it's awesomeness).

--Getting Started

First things first you'll need to get yourself a copy of the Haskell platform
http://hackage.haskell.org/platform/

The install should be painless on pretty much any platform.

Like C/C++, Haskell is a compiled language, instead of GCC/G++ you'll use GHC (Glasgow Haskell Compiler)
'ghc' is the command to run the compiler (just like 'gcc')


Like Python, Haskell also let's you play around in an interpeter (more specifically in the case of Haskell and Lisps a REPL, Read Eval Print Loop)
'ghci' is the command to start the Haskell interpreter

One more interesting point, these notes.. well they'll compile! This is a special type of file call 'literate haskell' which is a form of literate programming http://en.wikipedia.org/wiki/Literate_programming

--Functional Programming!!!

So what makes Haskell special? There's actually a lot, so for this first lecture I'll focus 
Functional Programming!!!

If you're a good CS student you have probably already heard a little (or even a lot) about
functional programming, but what does that really mean.

The abstract idea is that functional programming tries to make defining programs more like
how we define mathematical ideas.

For example the expression
x = x + 1
is common in most programming lanuages but nonsensical in mathematics, it's also non-sensical in Haskell.

This is because one of the rules of Haskell is that we can never have what are known as "side effects", 
which is quite simply any change that changes the state of the world.

Incrementing 'x' changes the value of 'x' therefor it is not allowed.

A better way to view is this that:
   for any given function
   given the same input
   the function will always return the same output

That's how math works right? 
you can never have f(x) -> y and sometime f(x) -> z where y != z

This idea is pretty powerful when you think about it.
Whenver you call a function in Haskell you know that it doesn't change anything about the world, it merely returns a value. When you write C/C++ think about how many time as function or a method changes the global state of the program you're running? Just as C draws some of it's power from allowing this Haskell draws strength from not allowing.

The concept is refered to as REFERENTIAL TRANSPARENCY
   
And this is essentially the core of what functional programming is about.

--Features of Functional Programming Languages

So before we dive into how we're going to think about coding in a funcitonal way, we need to be aware of
some of the things we usually have in a functional language.

1. First Class Functions
This is actually a feature of python, all it means is that we can pass functions just like any other
value. In fact a key concept of functional programming is that "Code is Data" (although this is more
important with lisps)

Here's a trivial example

let's make some simple function that take 1 argument and add a value to that

>add1 x = 1 + x
>add2 x = 2 + x

One thing to note here is that we don't have to call 'return', in functional languages a values is always returned, another nice guarantee

For our example let's make the opposite
that is a function that takes a function and applies the argument

>argIs1 func = func 1
>argIs2 func = func 2

now let's combine these to demonstrate how first class functions work

>answerIs2 = argIs1 add1
>answerIs3 = argIs2 add1
>alsoIs3 = argIs1 add2

even though this example is trivial and contrived the idea of passing functions around 
should make sense, and hopefully you can get an idea how this would be useful. If not
you'll soon see this.

2. Lambda the Ultimate!

Functional programming is actually based on a model of computation call the 
Lambda Calculus
a 'lambda function' is simply an unnamed function. It turns out you can do a lot
with unnamed functions, including implement recursion (how does an unnamed function call itself?)

You'll use these fairly frequently, but don't worry if these short examples don't
make the usage obvious.  Lambda functions are most commonly used when it would be 
silly to define a named function, almost always when a function is being used 
as an argument.

Here's an identity function

>idLambda = \x -> x

and here's a really verbose way of re-writing add

>lambdaAdd = \x y -> x + y

Although they seem simple, they are both very useful and very powerful from a theoretical standpoint.




