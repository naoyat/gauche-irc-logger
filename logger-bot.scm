;;
;; extract from OKUYAMA Atsushi's "IRCBOT", http://homepage3.nifty.com/oatu/gauche/try.html
;;
(use gauche.net)
(use gauche.logger)
(use gauche.threads)
(use gauche.charconv)
(use file.util)
(use srfi-19)

(require "./setting")

;; ===============================================
;; util

(define (guard-read-line port)
  (guard (exc
          ((<read-error> exc) "read error.")
          (else "error."))
         (read-line port))
  )

;; ===============================================
;; logging

(define (make-log-path)
  (build-path log-dir (date->string (current-date) "~Y-~m-~d.log"))
  )

(define log-drain (make <log-drain> :path (make-log-path) :prefix "~T: "))

(define (write-log . msg)
  (let1 msg1 (apply string-append msg)
    (display msg1)
    (newline)
    (let1 path (make-log-path)
      ;; log rotate
      (unless
          (string=? path (slot-ref log-drain 'path))
        (set! log-drain (make <log-drain> :path path :prefix "~T: "))
        ))
    (log-format log-drain "~a" (ces-convert msg1 "*JP" log-encoding))))

(define (write-debug-log . msg)
  (when debug
    (let1 msg1 (apply string-append msg)
      (write-log "[DEBUG] " msg1))))

;; ===============================================
;; irc

(define irc-socket
  (make-client-socket 'inet irc-server irc-server-port))

(define irc-socket-input-port
  (open-input-conversion-port
   (socket-input-port irc-socket :buffering #f)
   irc-in-encoding))

(define irc-socket-output-port
  (open-output-conversion-port
   (socket-output-port irc-socket :buffering #f)
   irc-out-encoding))

(define (irc-send-body . msg)
  (let1 msg1 (apply string-append msg)
    (display (string-append msg1 "\r\n") irc-socket-output-port)
    (flush irc-socket-output-port)))

(define (irc-send-internal . msg)
  (let1 msg1 (apply string-append msg)
    (write-debug-log "[SEND] " msg1)
    (irc-send-body msg1)))

(define (irc-send . msg)
  (let1 msg1 (apply string-append msg)
    (write-log "[SEND] " msg1)
    (irc-send-body msg1)))

;;;
;;;
;;;
(irc-send "NICK " bot-nick)
(irc-send "USER " bot-nick " " irc-server " " irc-client-address " " bot-nick)
(irc-send "JOIN " irc-channel)

(let loop ((str (string-incomplete->complete (guard-read-line irc-socket-input-port))))
  (if (eof-object? str)
      (begin (socket-close irc-socket))
      (begin
        (let ((str-list (string-split str " ")))
          (cond ((string=? "PING" (list-ref str-list 0))
                 (write-debug-log "[PING RECEIVED]" str)
                 (irc-send-internal "PONG " (list-ref str-list 1)))
                ((and (string=? "PRIVMSG" (list-ref str-list 1))
                      (string=? bot-nick (list-ref str-list 2)))
                 (write-log (string-append "msg got from " ((#/^[^!]*!/ (list-ref str-list 0)))))
                 )
                (else (write-log "[RECEIVED] " str)))
          )
        (loop (string-incomplete->complete (guard-read-line irc-socket-input-port))))
      ))
