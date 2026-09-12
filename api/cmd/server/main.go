package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"
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

type Instance struct {
	ID string `json:"id"`
	Status string `json:"status"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	DeletedAt time.Time `json:"deleted_at"`
}

type InstanceResponse struct {
	Instances []Instance `json:"instances"`
}

var instances []Instance

func getInstances(w http.ResponseWriter, r *http.Request) {

	w.Header().Set("Content-Type","application/json")
	if instances == nil {
		json.NewEncoder(w).Encode(InstanceResponse{Instances: []Instance{}})
		return
	}
	json.NewEncoder(w).Encode(InstanceResponse{Instances: instances})
}

func createInstance(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	var inst Instance
	err := json.NewDecoder(r.Body).Decode(&inst)
	if err != nil {
		http.Error(w, "invalid JSON", http.StatusBadRequest)
		return
	}
	if inst.ID == "" {
		http.Error(w, "id is required", http.StatusBadRequest)
		return
	}
	if inst.Status == "" {
		inst.Status = "pending"
	}
	inst.CreatedAt = time.Now()
	inst.UpdatedAt = time.Now()

	instances = append(instances, inst)

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(inst)
}

func deleteInstance(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")

	kept := []Instance{}
	found := false
	for _, inst := range instances {
		if inst.ID == id {
			found = true
			continue
		}
		kept = append(kept, inst)
	}
	if !found {
		http.Error(w, "not found", http.StatusNotFound)
		return
	}
	instances = kept
	w.WriteHeader(http.StatusNoContent)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	http.HandleFunc("/health", health)
	http.HandleFunc("GET /instances", getInstances)
	http.HandleFunc("POST /instances", createInstance)
	http.HandleFunc("DELETE /instances/{id}", deleteInstance)
	fmt.Println("listening on:", port)
	var err error
	err = http.ListenAndServe(":"+port, nil)
	if err != nil {
		fmt.Println("server failed:", err)
	}
}