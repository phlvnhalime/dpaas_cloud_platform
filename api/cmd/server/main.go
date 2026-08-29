package main

import (
	"encoding/json"
	"fmt"
	"net/http"
)

func health(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type","application/json")
	json.NewEncoder(w).Encode(map[string]string{
				   								"status":"ok",
									})
}

func main() {
	http.HandleFunc("/health", health)
	fmt.Println("listening on:8080")
	var err error
	err = http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal(err)
	}
}