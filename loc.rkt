#lang racket

(require racket/file racket/path)


(define normalize
  (lambda (str)
    (string-downcase (string-replace str "\\" "/"))))



(struct cmd-in (path ext) #:transparent)
(define args (vector->list (current-command-line-arguments)))
(define cwd (normalize (path->string (current-directory))))



(define in
    (cond
      [(< 1 (length args)) (error (format "args required: 0-1 given: ~a" (length args)))]
      [(= 1 (length args)) (cmd-in cwd (first args))]
      [(= 0 (length args)) (cmd-in cwd "")]
      ))




(define safe-line-read
  (lambda (file)
    (with-handlers ([exn:fail? 
      (lambda (exn)
        ;(displayln (format "file ~a could not be read" file)) 
        `())])
        (file->lines file))))




(define ignored 
  (filter-map 
    (lambda (el)
      (cond 
        [(string-suffix? el "/") (normalize (string-append (cmd-in-path in) el))]
        [else #f]) 
      )
       (cons ".git/" (safe-line-read (string-append (cmd-in-path in) ".gitignore")))))


(define get-file-paths
  (lambda (path)
    (fold-files
     (lambda (start type ls)
       (cond
         [(eq? type `file) (cons (normalize (path->string start)) ls)]
         [(eq? type `dir) ls]
         [(eq? type `link) ls]
         ))
     `() path)))










(define should-be-ignored
  (lambda (path)
  (let 
    ([exclude-list (map (lambda (el) (string-contains? path el)) ignored)]
    )
      (foldl (lambda (a b) (or a b)) #f exclude-list))
  ))
    

(define get-files
  (lambda (path)
    (filter (lambda (file) (not (should-be-ignored file))) (get-file-paths path))))


(define filter-by-extension
  (lambda (ls ext)
    (filter (lambda (x) (or (string=? ext "") (string-suffix? x ext))) ls)))


(define extension-filtered (filter-by-extension (get-files (cmd-in-path in)) (cmd-in-ext in)))



(define loc
  (lambda (file)
    (foldl 
      (lambda (line count)
        (if (string=? (string-trim line) "")
          count
          (+ count 1)
          )) 0 (safe-line-read file))))

(define loc-map (map loc extension-filtered))



(define loc-total
  (foldl + 0 loc-map))

(define loc-per-file (map (lambda (file loc) (cons (string-replace file cwd "") loc)) extension-filtered loc-map))


(printf "\nlines of code for directory: ~a \n\n" cwd)


(for-each  (lambda (el) 
  (printf "~a : ~a\n" (car el) (cdr el))) loc-per-file)


(printf "\ntotal: ~a" loc-total)


