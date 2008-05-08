;;
;; settings
;;
(define debug #f)

(define irc-server "irc.server.host")
(define irc-server-port 6667)
(define irc-channel "#ChannelName")
(define bot-nick "UNIQUE_BOTNAME")

(define irc-client-address "localhost")

(define rdf-name "irclog.rdf")
(define log-dir "/PATH/TO/RAW/LOG/DIRECTORY") ;; absolute path

(define rss-output-dir "/PATH/TO/RSS/OUTPUT/DIRECTORY") ;; absolute path
(define rss-output-dir-url "http://www.example.com/")
(define logview-root-url "http://www.example.com/LOGVIEW_DIR/")

(define (logview-url date-str) ;; date-str must be in YYYY-MM-DD
  (string-append logview-root-url "logview.cgi?" date-str)) ;;

(define log-encoding "utf-8")
(define irc-in-encoding "utf-8")
(define irc-out-encoding "utf-8")
