package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
)

/*
w is the response writer
r is the request

Set: sets the header to the response writer
Encode: encodes the response writer to the response writer

map  [  string  ]  string
 |        │          │
 │        │          └── value type  (what you store)
 │        └───────────── key type    (how you look it up)
 └────────────────────── this is a hash table
*/



func health(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type","application/json")
	json.NewEncoder(w).Encode(map[string]string{
				                "status":"ok",
								})
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	http.HandleFunc("/health", health)
	fmt.Println("listening on:", port)
	var err error
	err = http.ListenAndServe(":"+port, nil)
	if err != nil {
		fmt.Println("server failed:", err)
	}
}