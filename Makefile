COMPOSE ?= docker compose -f docker-compose.dev.yml

.PHONY: dev dev-detach down shell console test imap logs db-migrate db-reset psql sim-email-once sim-email-stream

dev: ## Start dev stack (foreground)
	$(COMPOSE) up --build

dev-detach: ## Start dev stack in background
	$(COMPOSE) up -d --build

dev-prod-detach: ## Start dev stack but run Rails in production mode (uses dev compose & env)
	RAILS_ENV=production NODE_ENV=production RAILS_SERVE_STATIC_FILES=1 RAILS_LOG_TO_STDOUT=1 FORCE_SSL=false $(COMPOSE) up -d --build

down: ## Stop dev stack
	$(COMPOSE) down

shell: ## Open a shell in the web container
	$(COMPOSE) exec web bash

console: ## Open Rails console in the web container
	$(COMPOSE) exec web bin/rails console

test: ## Run RSpec in the web container
	$(COMPOSE) exec web bundle exec rspec

db-migrate: ## Run db:migrate
	$(COMPOSE) exec web bin/rails db:migrate

db-reset: ## Drop and prepare (create/migrate)
	$(COMPOSE) run --rm web bin/rails db:drop && bin/rails db:prepare

psql: ## Open psql against the dev DB
	COMPOSE_PROFILES=tools $(COMPOSE) run --rm psql

imap: ## Start stack with IMAP worker profile
	$(COMPOSE) --profile imap up --build

logs: ## Follow web logs
	$(COMPOSE) logs -f web

sim-email-once: ## Send a single simulated email (env: SENT_OFFSET_SECONDS, EXISTING_ALIAS_PROB, EXISTING_TOPIC_PROB)
	$(COMPOSE) exec web ruby script/simulate_email_once.rb

sim-email-stream: ## Start a continuous simulated email stream (env: MIN_INTERVAL_SECONDS, MAX_INTERVAL_SECONDS, EXISTING_ALIAS_PROB, EXISTING_TOPIC_PROB)
	$(COMPOSE) exec web ruby script/simulate_email_stream.rb
