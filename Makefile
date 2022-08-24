all: check

check:
	./scripts/test

watch:
	./scripts/test --watch
