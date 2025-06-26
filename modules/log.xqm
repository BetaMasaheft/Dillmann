xquery version "3.1";

module namespace log="http://www.betamasaheft.eu/Dillmann/log";

import module namespace config="http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";
import module namespace util="http://exist-db.org/xquery/util";

declare namespace test="http://exist-db.org/xquery/xqsuite";


declare function log:add-log-message($message as xs:string)
as empty-sequence()
{
   util:log('info', $message)
};


declare function log:add-log-message($url as xs:string, $user as xs:string, $type as xs:string)
as empty-sequence()
{
   util:log('info',
              <logentry xmlns="http://log.log" timestamp="{current-dateTime()}">
                   <user>{ $user }</user>
                   <type>{ $type }</type>
                   <url>{ $url }</url>
              </logentry>
   )
};
