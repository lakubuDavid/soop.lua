package middlewares

import (
	"net/http"
	"sync"
)

var cache = struct{ sync.RWMutex; values map[string][]byte }{values: make(map[string][]byte)}

// Invalidate removes cached partials by prefix. Replace this starter cache
// with a shared cache when running multiple dashboard instances.
func Invalidate(prefix string) {
	cache.Lock(); defer cache.Unlock()
	for key := range cache.values { if len(key) >= len(prefix) && key[:len(prefix)] == prefix { delete(cache.values, key) } }
}

func Noop(next http.Handler) http.Handler { return next }
