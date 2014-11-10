CC=gcc
BUILD_DIR=./build
SRC_DIR=./src
TEST_OUT=$(BUILD_DIR)/test.out
FRAMEWORKS=-framework Foundation
CFLAGS=$(FRAMEWORKS)

.PHONY: test

clean:
	rm -rf $(BUILD_DIR)

test:
	mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -I$(SRC_DIR) $(SRC_DIR)/**.m test/**.m -o $(TEST_OUT)
	$(TEST_OUT)
