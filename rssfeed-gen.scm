;;;
;;; generate rss-1.0 from recent logs
;;;
;;; (c)2008 naoya_t
;;;
(require "./setting")
(require "./lib/rawlog")

(use srfi-19) ; date

(define today-jd (date->julian-day (current-date)))

(define (rss-1.0 links items)
  (string-append
   "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet href=\"./rdf.xsl\" type=\"text/xsl\"?>
<rdf:RDF xmlns:image=\"http://purl.org/rss/1.0/modules/image/\"
  xmlns:taxo=\"http://purl.org/rss/1.0/modules/taxonomy/\"
  xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
  xmlns:sy=\"http://purl.org/rss/1.0/modules/syndication/\"
  xmlns:dc=\"http://purl.org/dc/elements/1.1/\"
  xmlns:content=\"http://purl.org/rss/1.0/modules/content/\"
  xmlns:trackback=\"http://madskills.com/public/xml/rss/module/trackback/\"
  xmlns=\"http://purl.org/rss/1.0/\">
  <channel rdf:about=\"" rss-output-dir-url "\">
    <title>IRC " irc-channel " log</title>
    <link>" logview-root-url "</link>
    <description>" irc-channel " on " irc-server "</description>
    <items>
      <rdf:Seq>
"
   (string-join (map (cut format "        <rdf:li resource=\"~a\"/>\n" <>) links) "")
"     </rdf:Seq>
    </items>
    <taxo:topics>
      <rdf:Bag/>
    </taxo:topics>
  </channel>
"
  (string-join items "")
"
</rdf:RDF>"))

(define (hh:mm:dd->sec hh:mm:dd)
  (fold (lambda (x y) (+ x (* y 60))) 0 (map string->number (string-split hh:mm:dd ":"))))

(let loop ([ofs 1] [links '()] [items '()])
  (let ([last_t 86399]
		[sep #f])
	(define (plain-filter timestamp user cmd room msg)
	  (let1 msg (regexp-replace #/</ msg "&lt;")
		(case cmd
		  [(JOIN PART QUIT) #f]
		  [(PRIVMSG)
		   (let1 t (hh:mm:dd->sec timestamp)
			 (let1 s (format "~a~a &lt;~a&gt; ~a<br/>\n"
							 (if (< (+ last_t 3600) t) "<hr>\n" "") ; separator
							 timestamp user msg)
			   (set! last_t t)
			   s))]
		  [(NICK)
		   (format "~a &lt;~a =&gt; ~a&gt;<br/>\n" timestamp user msg)]
		  [(TOPIC)
		   (format "~a &lt;~a&gt; TOPIC => ~a><br/>\n" timestamp user msg)]
		  [else #f])))
	
	(let* ([d (julian-day->date (- today-jd ofs))]
		   [date-str (date->string d "~Y-~m-~d")] ;;(format "~4,'0d-~2,'0d-~2,'0d" (date-year d) (date-month d) (date-day d))]
		   [content (daily-log date-str plain-filter)])
		   (if (and (<= ofs 3) content)
			   (let* ([link (logview-url date-str)]
					  [description (string-append (substring content 0 (min (string-length content) 100)) " ...")]
					  [content-br (regexp-replace #/\n/ content "<br/>\n")]
					  [title date-str]
					  [subject date-str]
					  [item (format
"  <item rdf:about=\"~a\">
    <title>~a</title>
    <link>~a</link>
    <description>~a</description>
    <dc:subject>~a</dc:subject>
    <dc:date>~aT00:05:00+09:00</dc:date>
    <taxo:topics>
      <rdf:Bag/>
    </taxo:topics>
    <content:encoded><![CDATA[~a]]></content:encoded>
  </item>" link title link description subject date-str content-br)
							])
				 (loop (+ ofs 1)
					   (cons link links)
					   (cons item items)))
			   (with-output-to-file (string-append rss-output-dir "/" rdf-name)
				 (lambda ()
				   (print (rss-1.0 (reverse! links) (reverse! items)))
				   ))
			   ))))
