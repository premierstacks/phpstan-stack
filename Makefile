# Default shell
SHELL := /bin/bash

# Default goal
.DEFAULT_GOAL := never

# Variables
MAKE_PHP_8_3_EXE ?= php8.3
MAKE_COMPOSER_2_EXE ?= /usr/local/bin/composer

MAKE_PHP ?= ${MAKE_PHP_8_3_EXE} -d zend.assertions=1
MAKE_COMPOSER ?= ${MAKE_PHP} ${MAKE_COMPOSER_2_EXE}

# Goals
.PHONY: audit
audit: audit_npm audit_composer

.PHONY: audit_composer
audit_composer: ./vendor/autoload.php ./composer.lock
	${MAKE_COMPOSER} audit
	${MAKE_COMPOSER} check-platform-reqs
	${MAKE_COMPOSER} validate --strict --no-check-all

.PHONY: audit_npm
audit_npm: ./node_modules ./package-lock.json
	npm audit --audit-level info --include prod --include dev --include peer --include optional

.PHONY: check
check: lint audit

.PHONY: clean
clean:
	rm -rf ./composer.lock
	rm -rf ./node_modules
	rm -rf ./package-lock.json
	rm -rf ./vendor

.PHONY: commit
commit: fix check

.PHONY: development
development: local

.PHONY: fix
fix: fix_eslint fix_prettier

.PHONY: fix_eslint
fix_eslint: ./node_modules/.bin/eslint ./eslint.config.js
	./node_modules/.bin/eslint --fix .

.PHONY: fix_prettier
fix_prettier: ./node_modules/.bin/prettier ./prettier.config.js
	./node_modules/.bin/prettier -w .

.PHONY: lint
lint: lint_eslint lint_prettier

.PHONY: lint_eslint
lint_eslint: ./node_modules/.bin/eslint ./eslint.config.js
	./node_modules/.bin/eslint .

.PHONY: lint_prettier
lint_prettier: ./node_modules/.bin/prettier ./prettier.config.js
	./node_modules/.bin/prettier -c .

.PHONY: local
local: ./vendor/autoload.php
	${MAKE_COMPOSER} dump-autoload -o --dev --strict-psr

.PHONY: production
production: staging

.PHONY: staging
staging: local
	${MAKE_COMPOSER} dump-autoload -a --no-dev --strict-psr

.PHONY: testing
testing: local

# Dependencies
 ./node_modules ./node_modules/.bin/eslint ./node_modules/.bin/prettier: ./package-lock.json
	npm install --install-links --include prod --include dev --include peer --include optional
	touch ./package-lock.json
	touch ./node_modules
	touch ./node_modules/.bin/*

./package-lock.json: ./package.json
	rm -rf ./node_modules
	rm -rf ./package-lock.json
	npm update --install-links --include prod --include dev --include peer --include optional
	touch ./package-lock.json

./vendor ./vendor/autoload.php: ./composer.lock
	${MAKE_COMPOSER} install
	touch ./composer.lock
	touch ./vendor/autoload.php
	touch ./vendor
	touch ./vendor/bin/*

./composer.lock: ./composer.json
	rm -rf ./vendor
	rm -rf ./composer.lock
	${MAKE_COMPOSER} update
	touch ./composer.lock
