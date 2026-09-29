BREW := /opt/homebrew/bin/brew

## swiftgen: Trigger code generation from assets with swiftgen tool
bootstrap:
	mint install SwiftGen/SwiftGen

swiftgen:
	mint run swiftgen
	
	@for d in $(SWIFTGEN_CONFIGS); do ( mint run swiftgen --config $$d ); done
	@for d in $(shell find Modules -name "swiftgen.yml"); do ( mint run swiftgen --config $$d ); done

$(BREW):
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | ruby

.PHONY: swiftgen
