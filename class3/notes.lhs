Lecture Notes for Class 3 on Haskell Programming.


Today we're going to start by looking at parsing files in Haskell

Coming from the land of C/C++ thinking about parsing streams in Haskell
may seem odd or difficult. However once you realize that streams are essentially
lazy lists, you should see that they are quite natural to work with.

Since streams are just lazy lists we can just work with a string.
(note: in reality you'll need to import Data.ByteString to read from a binary file
       this lecture will cover the way to think about parsing data, there should
       be plenty of material online to get your familiar with how to read data
       from a binary file using Haskell)

Here's our imaginary WIL file format,

>wilExample = "WIL070408WilliamKurtEngineer"

So this file format should be pretty easy to figure out
we have a header "WIL070408"
"WIL" indicates that we are dealing with the WIL file format
07 indicates the size of the first name field
04 indicates the size of the last name field
08 indicates the size of the job title field

If you open up most Haskell books and look into parsing binary data you're likely to 
get an unexpected lecture on : Parsec (a great library for parsing), Functors (a 
useful typeclass that defines map), and/or Monads (a topic we've touched on 
that we'll fill out later). All of these topics are fine and dandy, but can
add unnecessary complexity while we're still trying to get started with 
understanding the basics of functional programming.

For now we're just going to worry about 'Solving our Problem', not doing it
perfect. Most of real world software is solving a problem however imperfect
that solution may be... However it is important to realize that there are 
better ways to solve these problems in Haskell.

So what do we need to solve this problem..
Let's get the get that header first

we know it's 3 + 2 + 2 + 2 chars so...

>getHeader wil = take 9 wil

now that we have the head we need to parse that
for now we don't really care about the 'WIL' so we can ignore it

let's get the sizes

>getFirstNameSizev1 wil = take 2 $ drop 3 header
>    where header = getHeader wil

>getLastNameSizev1 wil =  take 2 $ drop 5 header
>    where header = getHeader wil

... hmmmm there's a lot wrong with this already
first this take drop stuff is getting tedious..

>takeDrop t d = (take t . drop d)

and for sizes we know they are all 2

>getSize = takeDrop 2

..and dispite our awesome get header function we don't actually need it

first let's just assign these offsets to variables so our code is a bit more readable

>fnSizeOffset = 3
>lnSizeOffset = 5
>titleSizeOffset = 7

that's a little cleaner

>getFirstNameSize' = getSize fnSizeOffset

Almost there but we don't realy care about the string value
so let's just stick a 'read' on there

>getFirstNameSize :: String -> Int
>getFirstNameSize = (read . getSize fnSizeOffset)

there that's pretty readable (don't forget that we need the type signature 
since right now the compiler has no idea what we intend to read)

>getLastNameSize :: String -> Int
>getLastNameSize = (read . getSize lnSizeOffset)

>getTitleNameSize :: String -> Int
>getTitleNameSize = (read . getSize titleSizeOffset)

So now we have our size, all we need to do is grab
the content of those fields...

this will come in handy...

>headerSize = 9

>getFirstName wil  =  takeDrop fnSize headerSize wil
>    where fnSize = getFirstNameSize wil

not perfect but certainly readable and gets the job done

>getLastName wil = takeDrop fnSize offsetSize wil
>    where fnSize = getLastNameSize wil
>          offsetSize = headerSize + (getFirstNameSize wil)

>getTitle wil = takeDrop fnSize offsetSize wil
>    where fnSize = getTitleNameSize wil
>          offsetSize = headerSize + (getFirstNameSize wil) + (getLastNameSize wil)


So this isn't so bad, but you should notice some pretty obvious efficeincy issues
First off we call 'getFirstNameSize' 3 times and 'getLastName' twice.  This in itself
isn't so bad since this just means going to the header a few extra times, and the header is small

if we had 100 fields this mean this header would be read a over 5000 times just for getting that 
one section. For each of the hundred fields we'd also have to get them roughly 5000 times.

But that's not even our biggest hidden cost.
for every nth feild the entire file had to be reread total-n times!

So why did I say this wasn't so bad? Well we probably won't be adding any fields to our file format
and if we do probably not on the order of 100.  For the 3 fields we have this overhead is 
reasonably acceptable.


What we need is a way to share information between functions. Now normally we could just return 
the value we need and have the next function use that value. After all this is essentially
just composing a function. Our problem is that we have a lot of information to keep track
of. What we need is a 'type' that expresses our data.

We'll use something call the 'record syntax' to make our type easier to work with.

to start we'll use the keyword 'data', the name of our new type and the type constructor (which is usually the same)

>data WilParseData = WilParseData {

next we'll start to declare the fields we'll need and their type
first we need to keep track our input

>         input :: String,

the field size

>         firstNameSize :: Int,
>         lastNameSize :: Int,
>         titleSize :: Int,

and of course the fields for our actual data

>         firstName :: String,
>         lastName :: String,
>         title :: String
>    }


Cool! now we have a representation to play with, but lets see how we use this type

For this test example we'll just fill in the fields we actually want and not the ones we don't
care about, so this isn't a correct example


>testWil = WilParseData { input= "BLAHBLAHBLAH"
>                       ,firstNameSize = 0
>                       ,lastNameSize = 0
>                       ,titleSize = 0
>                       ,firstName = "John"
>                       ,lastName = "Smith"
>                       ,title = "Everyman" } 

The great thing is now we have an easy way to access this data

>exTitle = title testWil
>exFullName = (firstName testWil) ++ " " ++ (lastName testWil)


Just a note here: record syntax gives us some nice accessor function for free.
we could have also define the above simply as

>data WilParseData2 = WilParseData2 String Int Int Int String String String

and constructed it like this

>testWil2 = WilParseData2 "BLAHBLAHBLAH" 0 0 0 "John" "Smith" "Everyman"

but we don't get our acessors... we have to write them ours selves like this...

>firstName2 :: WilParseData2 -> String
>firstName2 (WilParseData2 _ _ _ _ x _ _) = x

>exFirstName2 = firstName2 testWil2

however it's important to note we can use record syntax int he same way as above if we want

>firstName3 :: WilParseData -> String
>firstName3 (WilParseData _ _ _ _ x _ _) = x

>exFirstName3 = firstName3 testWil


So then why ever NOT use record syntax? Well sometime you don't really need all 
of that extra data, for example you might want a 3d point

>data Point3d = Point3d Double Double Double

Which in which case it might make more sense not to use record syntax


Okay back to business! We want to parse that file!

So we're going to want to pass around a WilParseData type to do our book keeping
which means we'll have to initialize it to all sorts of defaults.
It's real pain to have to fill in the blanks everytime so we'll hide it all like this

>parseWil :: String -> WilParseData
>parseWil s = parseWil' WilParseData { input = s
>                       ,firstNameSize = 0
>                       ,lastNameSize = 0
>                       ,titleSize = 0
>                       ,firstName = ""
>                       ,lastName = ""
>                       ,title = ""
>                       }

using a function to hide the initialization is a very common pattern in functional
programming with recursion.

The whole way down we'll be using this type 

first we'll throw away those first 3 (we'll use them eventually I promise ;)

>parseWil' :: WilParseData -> WilParseData
>parseWil' r = parseFirstNameSize r {input = trimmed}
>    where trimmed = drop 3 $ input r 

Whoa wait, what's up with r {input = trimmed}
did we just change the value of something!!!
well yes and now, we passed essentially a new piece of data and, thanks
to the record syntax, we only had to mention which value we are
changing.  So we're still purely functional, but we do get to change values!

>parseFirstNameSize r = parseLastNameSize r {input = trimmed, firstNameSize = fns}
>    where trimmed = drop 2 $ input r
>          fns = read $ take 2 (input r)

Let's keep going...

>parseLastNameSize r = parseTitleSize r {input = trimmed, lastNameSize = lns}
>    where trimmed = drop 2 $ input r
>          lns = read $ take 2 (input r)

>parseTitleSize r = parseFirstName  r { input = trimmed, titleSize = ts}
>    where trimmed = drop 2 $ input r
>          ts = read $ take 2 (input r)

..Weee!

>parseFirstName r = parseLastName r {input = trimmed, firstName = f}
>    where size = firstNameSize r 
>          trimmed = drop size $ input r
>          f = take size $ input r

>parseLastName r = parseTitle r {input = trimmed, lastName = l}
>    where size = lastNameSize r 
>          trimmed = drop size $ input r
>          l = take size $ input r


>parseTitle r = r {input = trimmed, title = t}
>    where size = titleSize r 
>          trimmed = drop size $ input r
>          t = take size $ input r


Okay! let's see it in action now

>printInfo s = fn ++ "\n" ++ ln ++ "\n" ++ t
>    where parsed =  parseWil s
>          fn = firstName parsed
>          ln = lastName parsed
>          t = title parsed

This being haskell we could always do better :) however let's take a moment to see what we did
While a little verbose, this parser will read out data in linear time, unlike the first
version which needed to do plenty of repitious work, this one is able to continue to
consume the input without needing to reread any pieces of data.
We do waste a bit of memory on the records that we toss after each call, but that will only
increase linearly with the number of fields, and is a pretty small price to pay.

This is cool, but we can do 2 things to make our lives easier when working with this 
data.

For starters we want to be able to print our WilParseData.
You notice if you run 
'parseWil wilExample'
in ghci you would normally get an error, because we WilParseData is
not currently a member of the 'Show' typeclass... but we can fix that


>instance Show WilParseData where
>    show r = "First Name: " ++ fn ++ "\n" ++
>             "Last Name: " ++ ln ++ "\n" ++
>             "Title: " ++ t ++ "\n"
>        where fn = firstName r
>              ln = lastName r
>              t = title r

So now we can call 'show' on instance of WilParseData!
this also means that users of our parser won't get errors if
they're messing around in ghci

Just a word of caution, 'show' is really ment to aid in debugging and
show your values in ghci etc, if you really want to prettyPrint your values
it's best that you actually write a seperate funtion for that.

Also you can always add " deriving(Show)" to the end of your
type definition and you'll get a basic 'show' without having to 
write it your self

okay let's try our main

>main1 = do
>  parsed <- return $ parseWil wilExample
>  putStrLn $ show parsed

now that's pretty clean! and we know it's a efficient! Not bad for purely functional ;)

There's still one irksome thing... we don't really know that we have a WIL file

>failFormat = "NOTWIL090294ljDFAsdfjsldkafjsdfASDLFAJSDF"

one solution have is to raise an error

>errParse s = if first3 == "WIL"
>             then parseWil s
>             else error "not a will file format!"
>    where first3 = take 3 s

feel free to try errParse in ghci.

This is pretty good, but if we're using this data and passing it arround between functions
it might be nice to have more flexibility with how we delt with this.

Haskell has a really intersting type call 'Maybe', which when you first approach it
can sound pretty funny.

The 'Maybe' type makes use of something called a type constructor.
If we were to define maybe it would look like this

data Maybe a = Just a | Nothing

So Maybe take a type parameter 'a' and has 2 type constructors.

so let's revise our parse one more time...

>safeParse :: String -> Maybe WilParseData

look at the type signature and make sure it makes sense.
we're going to take a string and return a 'Maybe' WilParseData
this can mean either 'Just WilParseData' or 'Nothing'
We can later pattern match against these to pull out our value
or deal with the fact that we didn't get a value

oh and while we're at it, let's use guards (organizationally this code is doing nearly
the same thing as errParse)

>safeParse s | first3 == "WIL" = Just (parseWil s)
>            | otherwise = Nothing
>    where first3 = take 3 s

Now this might not seem to obvious but let's look at 2 examples

>realData = safeParse wilExample
>fakeData = safeParse failFormat

what makes this preferable to throwing an exception is that we
can have a series function operate on this data and continually
defer handing that exception until later.

If you're still having trouble, Maybe is similiar to another type we've seen, IO
rember IO String, IO Int etc.

The big difference is while IO will not allow you to get data out, Maybe will

Here's something we couldn't do with an error message...

>safeShow :: Maybe WilParseData -> String
>safeShow (Just w) = show w
>safeShow Nothing = "Parse failed"

Let's put our main together one more time...

>main = do
>  goodData <- return $ safeParse wilExample
>  badData <- return $ safeParse failFormat
>  putStrLn $ safeShow goodData
>  putStrLn $ safeShow badData


Aside from a way to handle errors, Maybe is a great solution to the problem of 'null'.  
In the real world 'null' is a real pain, and there are far too many times where it
is the cause of unexpected bugs.  Writing code with the proper use of Maybe can really
reduce the occurrance of this type of bug.

Finally I cheated just a bit in all of the above since I was just parsing a string.
When you're reading a binary file you'll actually want to use either

Data.ByteString
-or-
Data.Lazy.ByteString

-and-

Data.Char8
-or-
Data.Lazy.Char8

check out
http://www.haskell.org/haskellwiki/DealingWithBinaryData
and
http://book.realworldhaskell.org/read/code-case-study-parsing-a-binary-data-format.html