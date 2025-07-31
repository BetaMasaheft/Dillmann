xquery version "3.1";

(: used to test new functionalities of the upconversion script :)
let $text :=
"&lt;Sla&lt; &lt;1&lt; [[ +n. pr.+ ]] regis Israelitarum &gt;la&gt; David &gt;.&gt;1&gt; &lt;2&lt; &gt;la&gt; psalterium &gt;, liber biblicus (ab auctore psalmorum potissimo dictus); \*gez*ተፈጸመ፡ ዳዊት፡\* (explicit psalterium) Ps. in subscr. (in ((ed.)) *Lud.|318*p.|); \*gez*ወትደግም፡ ፻ወ፶ ዳዊት፡\* *Genz.|13*f.|; \*gez*ወእምዝ፡ ትብል፡ ጸሎተ፡ ቅዳሕ፡ ዘእምዳዊት፡ በዜማ፡ ግዕዝ፡\* Genz. f. 123; \*gez*በዳዊት፡\* *Clem.|125*f.|; *Gad. Joh.|* ; *Gad. Kar.|* , al.&gt;2&gt; &gt;S&gt; &lt;Sen&lt; &lt;1&lt; &gt;gez! dāwit &gt; [[ +n. pr.+ ˆm.ˆ ]] (personal name) e.g. &gt;gez! Dāwit &gt; king of the Israelite kingdom (= above, Dillmann 1) [page,54:2 (ed.); 60:7 (ed.)]bm:Marrassini1993AmdaSeyon *Chron. Am.|12* *Chron. Am.|28* &gt;1&gt; &lt;2&lt; #D2 &gt;gez! Dāwit &gt; book of the Bible (= above, Dillmann 2) [page, 70:11 (ed.); 76:4 (ed.)]bm:Marrassini1993AmdaSeyon *Chron. Am.|62* *Chron. Am.|79* &gt;2&gt; &gt;S&gt;"

let $newsense := transform:transform(
  <node>{ $text }</node>,
  "xmldb:exist:///db/apps/gez-en/xslt/upconversion.xsl",
  <parameters><param name="source" value="dillmann" /></parameters>
)
return $newsense
