# Automatically generate PDF from READMEs

BUILD_FOLDER ?= build

PDFs = healthcare-ci-pipelines.pdf

TARGETS = $(PDFs:%=$(BUILD_FOLDER)/%)

all: $(TARGETS)

# Step 0: Create build folder
$(BUILD_FOLDER):
	mkdir -p $(BUILD_FOLDER)

# Step 1: Convert mermaid graphs into pngs and generate README-out.md
README-out.md: README.md
	docker run \
		-u $(shell id -u):$(shell id -g) \
		-v $(shell pwd):/data \
		-w /data/ \
		minlag/mermaid-cli \
		-i README.md -o README-out.md --outputFormat png \
		--scale 10

# Step 2: Generate PDFs from README-out.md using pandoc
$(BUILD_FOLDER)/%.pdf: $(BUILD_FOLDER) README-out.md
	docker run \
		-u $(shell id -u):$(shell id -g) \
		-w /data/ \
		-v $(shell pwd):/data \
		ghcr.io/ethan42/pandoctex \
		pandoc README-out.md -f gfm -s \
		-H ./docs/preamble.tex \
		--pdf-engine=pdflatex \
		-o "$(BUILD_FOLDER)/$*.pdf" \
		-V fontsize=12pt \
		-V colorlinks=true -V linkcolor=darkgray -V urlcolor=blue -V toccolor=gray

.PHONY: clean
clean:
	rm -rf $(BUILD_FOLDER) README-out.md