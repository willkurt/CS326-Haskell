{-

Here is a very simple Hello World Script 

You can compile and run this just like any C/C++ program

Only instead of GCC/G++ you use GHC

>ghc main.hs -o hello
>./hello
Hello World!

Make sure this bit of code runs before you do anything else!

-}

main = do
  putStrLn "Hello World!"