POST http://localhost:8080/api/auth/signup
Content-Type: application/json

{
  "email": "hurl@example.test",
  "password": "correct-horse-battery-staple",
  "first_name": "Hurl",
  "last_name": "Tester"
}

HTTP 201
[Asserts]
jsonpath "$.email" == "hurl@example.test"
Set-Cookie: app_session
