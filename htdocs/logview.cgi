#!/usr/bin/env gosh
;;
;; logview.cgi
;;
(require "../setting")
(require "../lib/rawlog")

(define (it s) #`"<i>,|s|</i>")
(define (tt s) #`"<tt>,|s|</tt>")
(define (brown s) #`"<font color=\"#cc9999\">,|s|</font>")
(define (green s) #`"<font color=\"#339966\">,|s|</font>")
(define (gray s) #`"<font color=\"#999999\">,|s|</font>")

(define (logview-filter timestamp user cmd room msg)
    (case cmd
      [(JOIN)
       (string-append (brown timestamp) " "
                      (gray (tt #`"[,|user|'in]"))
                      "<br>\n")]
      [(PART QUIT)
       (string-append (brown timestamp) " "
                      (gray (tt #`"[,|user|'out]"))
                      (gray (it #`" ; ,|msg|"))
                      "<br>\n")]
      [(PRIVMSG)
       (string-append (brown timestamp) " "
                      (green #`"&lt;,|user|&gt; ,|msg|")
                      "<br>\n")]
      [(NICK)
       (string-append (brown timestamp) " "
                      (gray (it "&lt;,|user| =&gt; |msg|&gt;"))
                      "<br>\n")]
      [(TOPIC)
       (string-append (brown timestamp) " "
                      (green (string-append "&lt;" user "&gt; "
                                            #`"TOPIC =&gt; ,|msg|"))
                      "<br>\n")]
      [else #f]))
  
(define query-string (sys-getenv "QUERY_STRING"))

(unless (and query-string (rxmatch #/^20[0-9][0-9]-[01][0-9]-[0-3][0-9]$/ query-string))
  (display "Content-type: text/html") (newline) (newline)
  (error "invalid query string"))

(define date-str query-string)

(display "Content-type: text/html\r\n\r\n")
(print "<html>
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<title>" irc-channel " : " date-str "</title>
</head>
<body>
"

(daily-log date-str logview-filter)

"
</body>
</html>")
