// Package main implements SimpleTimeService: an HTTP server that returns JSON with
// the current timestamp and the caller's IP address.
package main

import (
	"encoding/json"
	"log"
	"net"
	"net/http"
	"strings"
	"time"
)

const listenAddr = ":8080"

type response struct {
	Timestamp string `json:"timestamp"`
	IP        string `json:"ip"`
}

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", handleRoot)

	srv := &http.Server{
		Addr:              listenAddr,
		Handler:           logRequest(mux),
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       10 * time.Second,
		WriteTimeout:      10 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	log.Printf("SimpleTimeService listening on %s", listenAddr)
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatal(err)
	}
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" || r.Method != http.MethodGet {
		http.NotFound(w, r)
		return
	}

	w.Header().Set("Content-Type", "application/json; charset=utf-8")

	out := response{
		Timestamp: time.Now().UTC().Format(time.RFC3339Nano),
		IP:        clientIP(r),
	}

	if err := json.NewEncoder(w).Encode(out); err != nil {
		log.Printf("encode response: %v", err)
	}
}

// clientIP returns the visitor address, preferring proxy headers when present
// (e.g. behind Ingress or a load balancer) and falling back to RemoteAddr.
func clientIP(r *http.Request) string {
	if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
		parts := strings.Split(xff, ",")
		return strings.TrimSpace(parts[0])
	}
	if xri := r.Header.Get("X-Real-Ip"); xri != "" {
		return strings.TrimSpace(xri)
	}
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	return host
}

func logRequest(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("%s %s", r.Method, r.URL.Path)
		next.ServeHTTP(w, r)
	})
}
