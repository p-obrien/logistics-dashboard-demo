package repo

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/p-obrien/logistics-dashboard-demo/user-service/internal/model"
)

type UserRepo interface {
	Get(ctx context.Context, id string) (*model.User, error)
	Create(ctx context.Context, user *model.User) error
	Delete(ctx context.Context, id string) error
}

type userRepo struct {
	db *pgxpool.Pool
}

func NewUserRepo(db *pgxpool.Pool) UserRepo {
	return &userRepo{db}
}

func (r *userRepo) Get(ctx context.Context, id string) (*model.User, error) {
	row := r.db.QueryRow(ctx, `SELECT id, email, name, created_at FROM users WHERE id=$1`, id)
	var u model.User
	err := row.Scan(&u.ID, &u.Email, &u.Name, &u.CreatedAt)
	if err != nil {
		return nil, err
	}
	return &u, nil
}

func (r *userRepo) Create(ctx context.Context, u *model.User) error {
	_, err := r.db.Exec(ctx, `
		INSERT INTO users (id, email, name, created_at)
		VALUES ($1, $2, $3, $4)`, u.ID, u.Email, u.Name, u.CreatedAt)
	return err
}

func (r *userRepo) Delete(ctx context.Context, id string) error {
	cmd, err := r.db.Exec(ctx, `DELETE FROM users WHERE id=$1`, id)
	if err != nil {
		return err
	}
	if cmd.RowsAffected() == 0 {
		return errors.New("not found")
	}
	return nil
}
