# `WordleSolver`

Various tools to play Wordle and analyze strategies. Not for prime time.

## Human Plays Wordle

The function `wordle_play` presents the user with a standard Wordle game, 
but allows unlimited moves. 

Each guess is scored both using colors and a five-tuple of integers with the following
meanings:
* A green character and the value `2` is a correct letter that is in the right position.
* A red character and the value `1` is a correct letter that is in the wrong position.
* A dark gray character and the value `0` is a letter that is not in the word.

The game ends when the user enters the correct five-letter word. Alternatively,
entering a single question mark (`?`) ends the game and the hidden word is revealed.

## Computer Plays Wordle

The function `wordle_solver` has the computer try to guess the user's word. After each
guess presented by the computer, the user needs to enter a comma separated list of integers
to indicate whether a letter is correct and in the correct position (`2`), correct but
in the wrong position (`1`), or not in the word (`0`).

```
julia> wordle_solver()

I guess the word is SERAI
Enter the result --> 0,0,0,1,0

I guess the word is OCTYL
Enter the result --> 0,0,0,0,1

I guess the word is PLANK
Enter the result --> 0,2,2,0,0

I guess the word is LLAMA
Enter the result --> 2,2,2,2,2

Success in 4 guesses!!
```

### Scoring Functions

The `wordle_solver` function can be called with an optional argument that specifies a
scoring function. There are three options:
* `min_max_score` (default)
* `entropy_score` 
* `equi_score`

These functions are used in the process of evaluating a best next guess given the 
results thus far.

## Automatic Play

The function `auto_play` allows the computer to play Wordle in which the user does not
have to evaluate each guess. 

```
julia> auto_play("LLAMA")  # text coloring not shown in this README
ARISE
TALCY
BLAND
LLAMA
4
```

If `auto_play` is called without any arguments, the computer selects the hidden word.
```
julia> auto_play()
ARISE
TALPA
TACIT
3
```

The value returned by `auto_play` is the number of guesses.

### Optional arguments

`auto_play` can take two optional, named arguments:

* `scorer` is the scoring function (defaults to `min_max_score`)
* `verbose` is a Boolean that, when set to `false` suppresses output.

```
julia> auto_play("PLUMP", scorer=entropy_score, verbose=false) 
4

julia> auto_play(scorer=equi_score)
ABACK
SILER
ROUTH
RUDER
4
```

### Scoring testing

The function `score_all` runs `auto_play` on all 2315 possible Wordle hidden words. 
It returns a 2315-long vector whose entries are the number of steps taken to solve each
possible hidden word.
```
julia> x = score_all();
Progress: 100%|██████████████████████████████████████████| Time: 0:07:03

julia> sum(x)/length(x)
3.5965442764578834
```