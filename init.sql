CREATE EXTENSION IF NOT EXISTS citext;
CREATE TABLE IF NOT EXISTS "social_users" (
    "id" BIGSERIAL NOT NULL PRIMARY KEY,
    "email" VARCHAR UNIQUE NOT NULL,
    "name" VARCHAR NOT NULL,
    "logs" INT DEFAULT 1,
    "user_token" VARCHAR,
    "inserted_at" TIMESTAMP(0) NOT NULL,
    "updated_at" TIMESTAMP(0)
);
CREATE UNIQUE INDEX "social_users_id" ON "social_users" ("email");
CREATE TABLE IF NOT EXISTS "counter" (
    "id" INT DEFAULT 1,
    "count" INT,
    "inserted_at" TIMESTAMP(0) NOT NULL,
    "updated_at" TIMESTAMP(0)
);
CREATE TABLE IF NOT EXISTS "users" (
    "id" BIGSERIAL NOT NULL PRIMARY KEY,
    "email" VARCHAR NOT NULL,
    "hashed_password" VARCHAR NOT NULL,
    "confirmed_at" TIMESTAMP(0),
    "inserted_at" TIMESTAMP NOT NULL,
    "updated_at" TIMESTAMP
);
CREATE UNIQUE INDEX "users_email_index" ON "users" ("email");
CREATE TABLE IF NOT EXISTS "users_tokens" (
    "id" BIGSERIAL PRIMARY KEY,
    "user_id" bigint NOT NULL,
    CONSTRAINT "users_tokens_user_id_fkey " FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE,
    "token" bytea NOT NULL,
    "context" varchar(255) NOT NULL,
    "sent_to" varchar(255),
    "inserted_at" timestamp(0) NOT NULL
);
CREATE UNIQUE INDEX "users_tokens_users_id_index" ON "users_tokens" ("user_id");
CREATE UNIQUE INDEX "users_tokens_context_token_index" ON "users_tokens" ("context", "token");