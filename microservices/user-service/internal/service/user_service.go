package service

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/p-obrien/logistics-dashboard-demo/user-service/internal/model"
	"github.com/p-obrien/logistics-dashboard-demo/user-service/internal/repo"
)

type UserService interface {
	GetUser(ctx context.Context, id string) (*model.User, error)
	CreateUser(ctx context.Context, email, name string) (*model.User, error)
	DeleteUser(ctx context.Context, id string) error
}

type userService struct {
	repo repo.UserRepo
}

func NewUserService(r repo.UserRepo) UserService {
	return &userService{r}
}

func (s *userService) GetUser(ctx context.Context, id string) (*model.User, error) {
	return s.repo.Get(ctx, id)
}

func (s *userService) CreateUser(ctx context.Context, email, name string) (*model.User, error) {
	u := &model.User{
		ID:        uuid.NewString(),
		Email:     email,
		Name:      name,
		CreatedAt: time.Now().UTC(),
	}
	if err := s.repo.Create(ctx, u); err != nil {
		return nil, err
	}
	return u, nil
}

func (s *userService) DeleteUser(ctx context.Context, id string) error {
	return s.repo.Delete(ctx, id)
}
