#!/usr/bin/env gosh
;;
;; index.cgi - listing logs
;;
(require "../setting")

(sys-chdir log-dir)

(display "Content-type: text/html\r\n\r\n")
(print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"
       \"http://www.w3.org/TR/html4/loose.dtd\">
<html>
<head>
<title>" irc-channel "</title>
<link rel=\"stylesheet\" href=\"wiliki.css\" type=\"text/css\" />
<link rel=\"alternate\" type=\"application/rss+xml\" title=\"RSS\" href=\"/" rdf-name "\" />
</head>
<body>
<h1>" irc-channel " IRC logs</h1>

<hr />
<ul>
"

(string-join (map (lambda (path)
                    (let1 date-str (regexp-replace #/\.log$/ path "")
                      #`"<li><a href=\"logview.cgi?,|date-str|\">,|date-str|</a></li>\n"))
                  (reverse! (glob "20[0-9][0-9]-[01][0-9]-[0-3][0-9].log")) ""))

"</ul>
<hr />

</body>
</html>")
