export auto_play

"""
    auto_play(code::String)
    auto_play
Computer solves a Wordle puzzle without user inputs.
"""
function auto_play(code::String)
    code = uppercase(code)
    hist = Dict{String,NTuple{five,Int}}()
    words = load_words()
    nw = length(words)
    words = words[randperm(nw)]


    for g in words
        if wordle_validate(g, hist)

            result = wordle_score(g, code)

            present_score(g, result)
            println()

            if result == Tuple(2 for _ = 1:five)
                steps = length(hist) + 1
                println("Success in $steps guesses!!")
                return
            end
            hist[g] = result
        end
    end
    println("I give up.")
    return hist
end


function auto_play()
    ww = load_words()
    nw = length(ww)
    idx = mod1(rand(Int), nw)
    code = ww[idx]
    auto_play(code)
end
