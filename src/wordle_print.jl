using Crayons

function wordle_print(word::String, score::NTuple{five,Int})

    bg = Crayon(background = :white)

    bad = merge(bg, Crayon(foreground = :dark_gray))
    ok = merge(bg, Crayon(foreground = :red))
    good = merge(bg, Crayon(foreground = :green))

    style = [bad, ok, good]

    for idx = 1:five
        col = style[score[idx]+1]
        c = word[idx]
        print(col(string(c)))
    end
    println()
end


function wordle_print(idx::Int, b::Byte)
    word = GUESS_LIST[idx]
    score = byte_2_code(b)
    wordle_print(word, score)
end