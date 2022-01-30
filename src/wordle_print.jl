using Crayons

function wordle_print(word::String, score::NTuple{five,Int})

    bg = Crayon(foreground = :black)

    bad = merge(bg, Crayon(foreground = :dark_gray))
    ok = merge(bg, Crayon(foreground = :yellow))
    good = merge(bg, Crayon(foreground = :green))

    style = [bad, ok, good]

    for idx = 1:five
        col = style[score[idx]+1]
        c = word[idx]
        print(col(string(c)))
    end
    println()
end
