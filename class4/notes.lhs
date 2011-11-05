Lecture Notes for Class 4 on Haskel Programming

Okay let's go back to thinking about more abstract things

--- Building Lists From Scratch!!! ------

What if we didn't have a 'list' type build into Haskell in the first place?
how would we make our own?

If we think back to when we learned about lists we remember the most
simple one is
[ ] just the empty list

and the next most simple is

1:[] (remember [1] is just syntactic sugar)

from there on it's just 

1:2:[]

1:2:3[] etc

So our list is really just 2 very simply things

Empty 
- or -
value : a List

if we remmber another term for ':' is cons, we can define our list

>data List a = Cons a (List a) | Empty


this is our first example of a recursive data type
But if your read this type definition carefully,
you should see that it makes sense, it merely says exactly 
what we described a list to be

okay let's make our list an instance of show so that
we can play with it more

>instance (Show a) => Show (List a) where
>    show Empty = "[]"
>    show (Cons v vs) =  (show v) ++ ":" ++ (show vs)

Now you may have noticed that we have something extra that we didn't have
last time we implemented show... the intial '(Show a) =>'

Our List type can take any type as an arguemnt, but not all types implement show.
However in our implementation of show we need to make the assumption that they do
The way we've solved this is by requring that what ever list we're calling
'show' on, must be made up of members that also implement show.

Other than that little bit, our recursive definition of show should be pretty straight forward

Okay let's look at some examples

>emptyList = Empty
>oneElement = Cons 1 Empty
>twoElement = Cons 1 (Cons 2 Empty)
>anotherTwo = Cons 2 (Cons 3 Empty)
>threeElement = Cons 1 anotherTwo

and one example for good measure

>example = Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 Empty))))

The output for these lists in GHCI should look like regular
desugared lists, and as you can see by the example of 'threeElement'
our 'Cons' constructor works pretty much exactly like 


let's define our primative that we learned about on the first day of class

First head

>myHead :: List a -> a
>myHead (Cons a _) = a 

And now we can see why myHead fails on an empty list right?

myHead returns a type 'a'
however Empty cannot return anything
we could try

myHead Empty = Empty 
but that would be of type 'List a', not type 'a'

so the best we can do is

>myHead Empty = error "cannot call head on an empty list"

Now that that's resolve we can do 'tail'

>myTail :: List a -> List a
>myTail (Cons _ b) = b
>myTail Empty = Empty

because Empty is of type List a, it's okay for us to handle that case this time

let's do cons next... 
one funny thing about haskell is is that it let's you define your own operators.

I actualy tend to not like this, but let's just see how it works
our new ':' operator will be '+>'


>(+>) :: a -> List a -> List a
>x +> xs = Cons x xs

>smallList = Cons 2 Empty
>consExample = 1 +> smallList

Okay now that we've got those basics let's build some simple functions
just to see how it goes

>myLength :: List a -> Int
>myLength Empty = 0
>myLength (Cons x xs) = 1 + (myLength xs)

and here's a function to see if a value is in a list

>contains :: (Eq a) => a -> List a -> Bool
>contains _ Empty = False
>contains v (Cons x xs) | v == x = True
>                       | otherwise = contains v xs


Okay that's easy, now let's define something a bit harder
remember filter?

>myFilter ::  (a -> Bool) -> List a -> List a
>myFilter _ Empty = emptyList

remember we defined emptyList earlier, we'll need to use it as value know

>myFilter f (Cons x xs) | f x = x +> (myFilter f xs)
>                       | otherwise = myFilter f xs

for a higher order function... not to bad. If at the end of the list
we know we're done, 
if not empty and an item passed the test keep it,
otherwise continue on

>filterTest = myFilter even example

now let's do the ever important map

>myMap :: (a -> b) -> List a -> List b

now take a moment to really take in what this means, and remember
that we will start and end with a List, but our the type our list is
constructed with may change

>myMap _ Empty = emptyList
>myMap f (Cons x xs) = f x +> (myMap f xs)

Surprisingly simple isn't it? As usual it's a bit dense
but keep in mind we're only working with our own homemade 
List type, we've be able to write right something as 
sophisticated as map with only function and type
we didn't even stard with Lists! that's pretty awesome!

--- Strange Experiemnt -----


Remember our intersting recursive list type

data List a = Cons a (List a) | Empty

What would happen if we made up a type, we'll call it 'L'
that was just like List only didn't use recusion.

>data L a = LCons a | LEmpty

Just to be perfectly clear... all we have done is systematically
removed recursion from the original type, that's it.

Now let's redo everything we did before for list, 
only we'll give it the appropriate name and
just cross out recursion.  Some weird stuff may happen


We'll reimplement show, only let's just add an
'L' in front so we don't get too confused

>instance (Show a) => Show (L a) where
>    show LEmpty = "L []"
>    show (LCons v)  =  "L " ++(show v) 


again, no rething the logic, just systematically renaming
and crossing out recursion

>lEmpty = LEmpty
>oneL = LCons 1


>lHead :: L a -> a
>lHead (LCons a) = a 

>lHead LEmpty = error "cannot call head on an empty l"

We have the same problem as before regarding an empty head

so tail is weird 

>lTail :: L a -> L a
>lTail a = a

Since tail goes through the list recursively 
when we remove the recursion it just becomes the identity function


cons also changes a lot
but at it's course it's just going to 
be a synomn for the constructor

>lCons :: a -> L a
>lCons x = LCons x 

We also had to make lCons a uniary function
rather than a binary one.. but it doesn't matter
since anywhere we used +> 


>lConsExample = lCons 1

Okay so the primatives produced some interesting results
somewhat insightful, but nothing amazing

>lLength :: L a -> Int
>lLength LEmpty = 0
>lLength (LCons x) = 1 

lLength IS interesting right? 
First off notice that the type signature did not change at all

In this case we only removed the recursion and renamed as we've been doing
as best as possible whenver we can.

What do we get? well lLength is now a function that essentially maps an L 
to 0 or 1, when you think about how many complicated systems can be
built from just 0 and 1 this should be a least a little interesting

>lContains :: (Eq a) => a -> L a -> Bool
>lContains _ LEmpty = False
>lContains v (LCons x) | v == x = True
>                      | otherwise = False

we could have called lContatins 'is'
it checks essentially we'ther or not a value 'is' the value hidden in the LCons


>lFilter ::  (a -> Bool) -> L a -> L a
>lFilter _ LEmpty = lEmpty
>lFilter f (LCons x)  | f x = lCons x 
>                    | otherwise = lEmpty

>lExample = LCons 2
>lFilterTest1 = lFilter even lExample
>lFilterTest2 = lFilter even oneL

So now filter either preserves an 'L' if it passes the test
or makes it LEmpty if it fails
we could have called this 'emptyIf' 



>lMap :: (a -> b) -> L a -> L b
>lMap _ LEmpty = lEmpty
>lMap f (LCons x) = lCons (f x)

First i want you to notice that even though we removed recursion
the type signatures for the last view examples hasn't chagned.
That's a good sign that we're hitting at something interesting

lMap is actually very interesting for example

>ex1 = lMap show (LCons 1)

>ex2 = lMap (show . (+1)) (LCons 1)

What neat is that we're able to get that value inside of the LCons,
modify it and return the value back inside of the LCons!

but what happens when we have LEmpty

>ex3 = lMap (show. (+1)) lEmpty

We keep the empty L!

Now maybe this wouldn't be so interesting if it weren't for something you
hopefully have realized

the type 
data L = LCons a | LEmpty 

is exactly the same type as another we've seen...

data Maybe = Just a | Nothing

the only difference here is simply the naming of constructors, which is
entirely superficial

Maybe is the same thing as a List without recursion.


So does the actual maybe have any of the above functions?

yes it does!

'lHead' is actually 'fromJust'

>m1 = Just 1
>mN = Nothing

mEx1 = fromJust m1


We'll talk more about this later but
'lCons' is actually the same a 'return'


And most importantly
'lMap' and in fact regular 'map' are actually both 'fmap'

>mEx2 = fmap (show . (+1)) m1

what's really neat about fmap is it let's just change the value in
a Maybe we'll still keeping that value in the context of a Maybe

In fact this is so valuable that fmap is actually the sole function in the type class:

--Functor--

Many different types belong to the type class Function.

Cleary Maybe and List do.

The only thing that members of the class Functor are required to have in common
is the function 'fmap' which allows us to modify a value in a context
while keeping it in that context

We'll end today looking at this used with IO String

the goal will be to read an int, and square it

>squareInput :: IO String -> IO Int
>squareInput i = fmap ((\x->x*x) . read) i


>main = do
>  v <- squareInput getLine
>  putStrLn $ show v

Although this example is trivial and contrived 
it should be clear how the use of 'fmap' can 
replace something this pattern for he same problem

i <- getLine
intI <- return $ read i
sq <- square intI * intI
putStrLn $ show sq
