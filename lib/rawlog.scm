;(require "./setting")

(use srfi-1)
(use file.util)

(define (daily-log date-str filter-proc)
  ;; date-str must be in %Y-%m-%d format
  (define (uncolon s)
	(cond [(string=? "" s)
		   ""]
		  [(eq? #\: (string-ref s 0))
		   (substring s 1 -1)]
		  [else s]))
  (define (unquote s)
	(cond [(string=? "" s)
		   ""]
		  [(eq? #\" (string-ref s 0))
		   (substring s 1 (- (string-length s) 1))]
		  [else s]))

  (define (month-abbrev->number s)
	(case (string->symbol s)
	  [(Jan) 1] [(Feb) 2] [(Mar) 3] [(Apr) 4] [(May) 5] [(Jun) 6]
	  [(Jul) 7] [(Aug) 8] [(Sep) 9] [(Oct) 10] [(Nov) 11] [(Dec) 12]
	  [else #f]))

  (let1 raw-log-path (string-append log-dir "/" date-str ".log")
	(if (file-exists? raw-log-path)
		(string-join
		 (filter identity
				 (map (lambda (line)
						(let (;;[month (month-abbrev->number (substring line 0 3))]
							  ;;[day (string->number (substring line 4 6))]
							  [timestamp (substring line 7 15)]
							  [f (string-split (substring line 17 -1) " ")])
						  (if (string=? "[RECEIVED]" (car f))
							  (let ([user (uncolon (regexp-replace #/!.*$/ (second f) ""))]
									[cmd (string->symbol (third f))]
									[room (uncolon (fourth f))])
								(case cmd
								  [(JOIN)
								   (filter-proc timestamp user cmd room "")]
								  [(PART)
								   (filter-proc timestamp user cmd room
												(unquote (uncolon (string-join (cddddr f) " "))))]
								  [(QUIT)
								   (filter-proc timestamp user cmd #f
												(unquote (uncolon (string-join (cdddr f) " "))))]
								  [(PRIVMSG)
								   (filter-proc timestamp user cmd room (uncolon (string-join (cddddr f) " ")))]
								  [(NICK)
								   (filter-proc timestamp user cmd #f (uncolon (string-join (cdddr f) " ")))]
								  [(TOPIC)
								 (filter-proc timestamp user cmd #f (uncolon (string-join (cdddr f) " ")))]
								  [else
								   (filter-proc timestamp user cmd room (uncolon (string-join (cddddr f) " ")))]
								  ))
							  #f)))
					  (file->string-list raw-log-path))
				 ) "")
		#f)))
