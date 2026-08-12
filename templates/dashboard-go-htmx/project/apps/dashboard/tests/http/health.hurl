GET http://localhost:8080/healthz
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"
