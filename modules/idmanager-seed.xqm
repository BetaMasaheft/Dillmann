xquery version "3.1" encoding "UTF-8";

(:~
 : One-time seeding of the id-manager's "dillmann-entries" counter from the
 : live corpus. The id-manager starts at 0 while the corpus already holds
 : thousands of entries, so an unseeded counter would reissue numbers that
 : are taken. Not exposed via controller.xql - run once per target
 : instance, after the final data sync and before save-new-entity.xql goes
 : live:
 : xst run 'import module namespace seed="https://www.betamasaheft.uni-hamburg.de/gez-en/idmanager-seed" at "xmldb:exist:///db/apps/gez-en/modules/idmanager-seed.xqm"; seed:run(100)'
 :
 : Safe to re-run: it overwrites the counter with the current corpus max
 : plus buffer. Re-run (or use seed:check) if entries are created while it
 : runs.
 :)
module namespace seed = "https://www.betamasaheft.uni-hamburg.de/gez-en/idmanager-seed";

declare namespace t = "http://www.tei-c.org/ns/1.0";

import module namespace config = "http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";
import module namespace idmanager = "https://www.betamasaheft.uni-hamburg.de/gez-en/idmanager" at "idmanager.xqm";

(:~
 : Highest entry/@n across the whole of DillmannData, including /new, which
 : holds records created through the app since the last export. Non-numeric
 : values are ignored.
 :)
declare function seed:corpus-max() as xs:integer {
  let $ns :=
    for $n in collection($config:data-root)//t:entry/@n[. castable as xs:integer]
    return xs:integer($n)
  return (max($ns), 0)[1]
};

(:~
 : Sets the counter to corpus max + $buffer. $buffer is headroom for
 : entries created between seeding and cutover.
 :)
declare function seed:run($buffer as xs:integer) as map(*) {
  let $max := seed:corpus-max()
  let $target := $max + $buffer
  let $result := idmanager:reset-counter($target)
  return map {"corpusMax": $max, "seededTo": $target, "status": $result?status}
};

(:~
 : Post-seeding sanity check: reserves one number and reports whether it is
 : above the current corpus max. Consumes one number.
 :)
declare function seed:check() as map(*) {
  let $max := seed:corpus-max()
  let $r := idmanager:next-entry-n()
  let $n := $r?body?id
  return map {"corpusMax": $max, "issued": $n, "ok": $r?status eq 201 and xs:integer($n) gt $max}
};
