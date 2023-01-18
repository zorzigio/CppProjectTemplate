BUILD_DIR = build
JOBS = -j4

all: clean

install_min:
	sudo apt-get install gcc g++ cmake make doxygen

install_tests: install_min
	sudo apt-get install gcovr lcov

install: install_min install_tests
	sudo apt-get install git llvm pkg-config curl zip unzip tar python3-dev clang-format clang-tidy cppcheck iwyu

install_pip:
	pip install jinja2 Pygments cmake-format pre-commit

install_doc: install_min
	sudo apt-get install doxygen graphviz
	pip install jinja2 Pygments

clean:
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)

lint:
	cmake -H. -B$(BUILD_DIR) -DENABLE_CLANG_TIDY=ON
	cmake --build $(BUILD_DIR) --target main_clangtidy $(JOBS)

format:
	cmake -H. -B$(BUILD_DIR)  -DENABLE_CLANG_FORMAT=ON -DENABLE_CMAKE_FORMAT=ON
	cmake --build $(BUILD_DIR) --target run_clang_format --target run_cmake_format --config Debug $(JOBS)

.PHONY: build
build:
	cmake -H. -B$(BUILD_DIR) -DCMAKE_BUILD_TYPE=Release
	cmake --build $(BUILD_DIR) --config Release --target main $(JOBS)

coverage:
	cmake -H. -B$(BUILD_DIR) -DCMAKE_BUILD_TYPE=Debug -DENABLE_COVERAGE=On
	cmake --build $(BUILD_DIR) --config Debug --target coverage $(JOBS)

.PHONY: docs
docs:
	cmake -H. -B$(BUILD_DIR) -G "Unix Makefiles" -DCMAKE_BUILD_TYPE="Debug" -DENABLE_DOCS=ON
	cmake --build $(BUILD_DIR) --config Debug --target docs $(JOBS)

.PHONY: tests
tests:
	cmake -H. -B$(BUILD_DIR) -G "Unix Makefiles" -DCMAKE_BUILD_TYPE="Debug"
	cmake --build $(BUILD_DIR) --config Debug --target unit_tests $(JOBS)
	./$(BUILD_DIR)/tests/unit_tests
