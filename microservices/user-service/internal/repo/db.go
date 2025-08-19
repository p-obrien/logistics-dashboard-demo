package repo

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

func NewDBPool(ctx context.Context, dbUrl string) (*pgxpool.Pool, error) {
	return pgxpool.New(ctx, dbUrl)
}
