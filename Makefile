CC=gcc

BUILD_DIR=./build
SRC_DIR=./src
TEST_DIR=./test

TEST_FILES=$(SRC_DIR)/**.m $(TEST_DIR)/**.m
TEST_OUT=$(BUILD_DIR)/test.out

INCLUDES=-I$(SRC_DIR)
FRAMEWORKS=-framework Foundation

CFLAGS=$(FRAMEWORKS) $(INCLUDES)

.PHONY: test

clean:
	rm -rf $(BUILD_DIR)

test:
	mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $(TEST_FILES) -o $(TEST_OUT)
	$(TEST_OUT)
