{-
Another trival example of Haskell IO
-}


-- Just like C++  you'll need to have a main function defined somewhere
main = do
  putStrLn "What's your name?"
  name <- getLine
--putStr is just like putStrLn only you don't get the new line at the end
  putStr "Hi "
-- the '++' operate concates to lists, just as strings in C are really arrays
-- of chars, likewise in haskell they are just lists of chars, 
-- by concatenating 2 strings we get a new one
  putStrLn (name ++ "!")