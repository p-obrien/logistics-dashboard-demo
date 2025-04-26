package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/p-obrien/logistics-dashboard-demo/user-service/internal/handler"
	"github.com/p-obrien/logistics-dashboard-demo/user-service/internal/repo"
	"github.com/p-obrien/logistics-dashboard-demo/user-service/internal/service"
)

func main() {
	dbUrl := os.Getenv("DATABASE_URL")
	if dbUrl == "" {
		log.Fatal("DATABASE_URL is not set")
	}

	dbpool, err := pgxpool.New(context.Background(), dbUrl)
	if err != nil {
		log.Fatalf("Failed to connect to DB: %v", err)
	}
	defer dbpool.Close()

	userRepo := repo.NewUserRepo(dbpool)
	userSvc := service.NewUserService(userRepo)
	userHandler := handler.NewUserHandler(userSvc)

	r := chi.NewRouter()
	r.Route("/users", func(r chi.Router) {
		r.Get("/{id}", userHandler.GetUser)
		r.Post("/", userHandler.CreateUser)
		r.Delete("/{id}", userHandler.DeleteUser)
	})

	log.Println("Starting server on :8080")
	http.ListenAndServe(":8080", r)
}
