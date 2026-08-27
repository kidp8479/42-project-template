# Auto-detect the compose CLI: prefer the Docker Compose v2 plugin, fall
# back to podman-compose on machines that only have that (e.g. a school
# Podman setup). Override explicitly if needed, e.g. `make COMPOSE=podman-compose up`.
COMPOSE := $(shell docker compose version >/dev/null 2>&1 && echo "docker compose" || echo "podman-compose")

.PHONY: help install hooks-install up down ps logs format format-check lint lint-check test build

help:
	@echo "Available targets:"
	@echo "  install         - install dependencies, set up git hooks"
	@echo "  up              - docker/podman compose up -d"
	@echo "  down            - docker/podman compose down"
	@echo "  ps              - docker/podman compose ps"
	@echo "  logs            - docker/podman compose logs -f"
	@echo "  format          - format code (writes)"
	@echo "  format-check    - check formatting, no writes (pre-commit hook + CI)"
	@echo "  lint            - lint code (--fix)"
	@echo "  lint-check      - lint without auto-fixing (pre-commit hook + CI)"
	@echo "  test            - run tests"
	@echo "  build            - production build"

install: hooks-install
	# TODO: install project dependencies, e.g.:
	# cd backend && npm install
	# cd frontend && npm install

hooks-install:
	git config core.hooksPath .githooks

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

format:
	# TODO: e.g. cd backend && npm run format

format-check:
	# TODO: e.g. cd backend && npm run format:check

lint:
	# TODO: e.g. cd backend && npm run lint

lint-check:
	# TODO: e.g. cd backend && npm run lint:check

test:
	# TODO: e.g. cd backend && npm run test

build:
	# TODO: e.g. cd backend && npm run build
