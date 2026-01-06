# ==============================
# COMP2300 Windows Makefile
# ==============================

# Toolchain location
COMP2300 := C:/Users/Matt_/.comp2300

ARM_PREFIX := $(COMP2300)/arm-none-eabi/bin/arm-none-eabi-

CC      := $(ARM_PREFIX)gcc
LD      := $(ARM_PREFIX)ld
OBJCOPY := $(ARM_PREFIX)objcopy
OPENOCD := $(COMP2300)/openocd/bin/openocd

# ==============================
# Sources (RELATIVE PATHS ONLY)
# ==============================

SRCS := \
	src/main.S \
	$(wildcard src/*.c) \
	$(wildcard lib/*.c) \
	$(wildcard lib/*.S)

OBJS := $(SRCS:.c=.o)
OBJS := $(OBJS:.S=.o)

# ==============================
# Flags
# ==============================

CFLAGS  := -nostdlib -nostartfiles -mcpu=cortex-m4 -mthumb -Wall -Werror -g
LDFLAGS := -nostdlib -T lib/link.ld --print-memory-usage

TARGET := program.elf

# ==============================
# Build rules
# ==============================

all: $(TARGET)

$(TARGET): $(OBJS)
	"$(LD)" $(LDFLAGS) $^ -o $@

%.o: %.c
	"$(CC)" $(CFLAGS) -c $< -o $@

%.o: %.S
	"$(CC)" $(CFLAGS) -c $< -o $@

# ==============================
# Upload
# ==============================

.PHONY: upload
upload: $(TARGET)
	"$(OBJCOPY)" -O binary $(TARGET) program.bin
	"$(OPENOCD)" -f interface/cmsis-dap.cfg -f target/nrf52.cfg -c "program $(TARGET) verify reset exit"

# ==============================
# Clean
# ==============================

.PHONY: clean
clean:
	del /Q /F $(OBJS) $(TARGET) program.bin 2>nul || exit 0
