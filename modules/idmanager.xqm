xquery version "3.1" encoding "UTF-8";

(:~
 : Client for the betmas-id-manager REST service. Dillmann uses it for one
 : thing: the sequential entry/@n of new lemmas (type "dillmann-entries"),
 : so that this container stays stateless and concurrent creations cannot
 : be handed the same number. The xml:id of an entry is NOT issued here: it
 : is random and generated in edit/save-new-entity.xql. See
 : https://github.com/BetaMasaheft/betmas-id-manager
 :)
module namespace idmanager = "https://www.betamasaheft.uni-hamburg.de/gez-en/idmanager";

declare namespace http = "http://expath.org/ns/http-client";

import module namespace config = "http://betamasaheft.aai.uni-hamburg.de:8080/exist/apps/gez-en/config" at "config.xqm";

(:~
 : Sends a request and normalizes the response into
 : map { "status": xs:integer, "body": map(*)? }. Network-level failures
 : surface as status 503 instead of an uncaught error.
 :)
declare %private function local:send($method as xs:string, $path as xs:string, $body as map(*)?) as map(*) {
  let $href := $config:idManagerUrl || $path
  let $bodyJson := if (exists($body)) then
    serialize($body, map {"method": "json"})
  else (
  )
  let $request := <http:request href="{ xs:anyURI($href) }" http-version="1.1" method="{ $method }">
    <http:header name="Accept" value="application/json" />
    {
      if (exists($bodyJson)) then (
        <http:header name="Content-Type" value="application/json" />,
        <http:body media-type="application/json" method="text">{ $bodyJson }</http:body>
      ) else (
      )
    }
  </http:request>
  return try {
    let $response := http:send-request($request)
    let $status := xs:integer($response[1]/@status)
    let $rawBody := $response[2]
    let $decoded := if (empty($rawBody)) then (
    ) else (
      try { util:base64-decode(string-join($rawBody)) } catch * { string-join($rawBody) }
    )
    let $json := if (exists($decoded) and string-length($decoded) gt 0) then
      try { parse-json($decoded) } catch * { () }
    else (
    )
    return map {"status": $status, "body": $json}
  } catch * {
    let $_ := util:log("error", "idmanager:send - " || $method || " " || $href || " failed: " || $err:description)
    return map {"status": 503, "body": map {"error": $err:description}}
  }
};

(:~
 : Reserve the next entry number. ?status 201 success (the number is in
 : ?body?id as a string), 503 service unreachable.
 :)
declare function idmanager:next-entry-n() as map(*) {
  local:send("POST", "/ids/dillmann-entries", map {})
};

(:~
 : Admin/seeding operation: set the entry counter.
 :)
declare function idmanager:reset-counter($value as xs:integer) as map(*) {
  local:send("POST", "/types/dillmann-entries/reset", map {"value": $value})
};

(:~
 : Current state of the types known to the service (200 on success).
 :)
declare function idmanager:list-types() as map(*) {
  local:send("GET", "/types", ())
};
