BUILD_DIR = build

ifeq '$(findstring ;,$(PATH))' ';'
  CONAN_FLAGS = -s compiler='Visual Studio' -s compiler.version=16 -s cppstd=17 --build missing
else
  CONAN_FLAGS = -s cppstd=17 --build missing
endif

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
	sudo apt-get install doxygen
	pip install jinja2 Pygments

setup:
	pip install conan --user
	conan user

clean:
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)

prepare_conan: clean
	cd $(BUILD_DIR) && conan install .. $(CONAN_FLAGS)

lint:
	cmake -H. -B$(BUILD_DIR) -DENABLE_CLANG_TIDY=ON
	cmake --build $(BUILD_DIR) --target main_clangtidy -j4

format:
	cmake -H. -B$(BUILD_DIR)  -DENABLE_CLANG_FORMAT=ON -DENABLE_CMAKE_FORMAT=ON
	cmake --build $(BUILD_DIR) --target run_clang_format --target run_cmake_format --config Debug -j4

.PHONY: build
build:
	cmake -H. -B$(BUILD_DIR) -DCMAKE_BUILD_TYPE=Debug
	cmake --build $(BUILD_DIR) --config Debug -j4

coverage:
	cmake -H. -B$(BUILD_DIR) -DCMAKE_BUILD_TYPE=Debug -DENABLE_COVERAGE=On
	cmake --build $(BUILD_DIR) --config Debug --target coverage -j4
