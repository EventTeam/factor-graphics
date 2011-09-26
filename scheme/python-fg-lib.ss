(library (python-fg-lib)
         (export fg->image fg->img-score image->factor-graph)
         (import (except (rnrs) string-hash string-ci-hash)
                 (scheme-tools py-pickle)
                 (util)
                 )

         (define fg-dir "python /Users/yitingy/Graphics/factor-graphics/")

         (define fg->image
           (py-pickle-function (string-append fg-dir "python/fg2image.py")))

         (define fg->img-score
           (py-pickle-function (string-append fg-dir "python/scoreImFg.py")))

         (define (image->factor-graph image)
           (let ([image->string-fg (py-pickle-function (string-append fg-dir "python/im2fg.py"))])
             (strings->symbols (image->string-fg image))))

         (define (strings->symbols sexpr)
           (sexp-search string? string->symbol sexpr))

         )
