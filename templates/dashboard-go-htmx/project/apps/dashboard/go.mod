module @@MODULE@@/apps/dashboard

go 1.26.5

require (
	github.com/a-h/templ v0.3.1020
	github.com/go-chi/chi/v5 v5.3.1
	@@MODULE@@/packages/shared v0.0.0
)

replace @@MODULE@@/packages/shared => ../../packages/shared
