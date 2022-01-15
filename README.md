# `WordleSolver`

Solve Wordle puzzles interactively. This is a demonstration project and not ready for prime time. Requires that a list of words be found in `/usr/share/dict/words`. 

## Play Wordle with the computer

To try to guess a secret word, use the function `wordle_play()`. You then enter five-letter words and the computer scores them. With each guess, the computer types your entry back to you and beneath the word are symbols to indicate correct letter and position `*`, correct letter but wrong position `+`, or letter is not in the word `-`.

This is also reported using a 5-tuple where `0` indicates letter is not in the word, `1` indicates letter is in the word but in the wrong position, and `2` indicates letter is in the word and in the correct position. 

For example, if the secret word is `LLAMA` and the user guesses `KARMA`, here is the output:
```
Enter your guess: karma  
K A R M A 
- + - * * 
Score = (0, 1, 0, 2, 2)
```

The game will stop when the correct word is entered. However, to stop the game and have the answer revealed, type a single question mark.
```
Enter your guess: ?
The code word is LLAMA
```

## Have the computer solve a Wordle puzzle

Use the function `wordle_solver()` to have the computer try to guess your secret word. 

The computer guesses words and then the user is required to score the word as a list of five comma-separated numbers. As above, a `0` indicates the letter is not in the word, a `1` indicates the letter in the word but in the wrong position, and a `2` indicates the letter is in the word and in the correct position. For example, suppose the secret word is `KARMA`:
```
julia> wordle_solver()

I guess the word is IZOTE
Enter the result --> 0,0,0,0,0

I guess the word is GRUSS
Enter the result --> 0,1,0,0,0

I guess the word is MAHAR
Enter the result --> 1,2,0,1,1

I guess the word is KARMA
Enter the result --> 2,2,2,2,2

Success in 4 guesses!!
```

### Repeated letters

If the code word or the guess has repeated letters. When scoring a guess, we first check for letters that are correct and in the correct position; they get scored `2`. 

If there is a letter in the word that is in the correct position, it now gets a `1`, but what should we do if that letter appears twice in the word. For example, suppose the word we are trying to find is `ANKLE` and we guess `KARMA`. There are two `A`s in `KARMA`, neither in the correct position. In this case, we assign a `1` to the first `A` and a `0` to the second.
```julia
julia> WordleSolver.wordle_score("KARMA", "ANKLE")
(1, 1, 0, 0, 0)
```



## Need a better dictionary

The dictionary `/usr/share/dict/words` includes many obscure words. That means that when trying to guess the computer's word, it is often the case that the secret word is unfamiliar. 

And there are common five-letter words that are not included in the dictionary, such as `PASTA`. 







