AS = arm-none-eabi-as
CC = arm-none-eabi-gcc
CXX = arm-none-eabi-g++
CFLAGS = -mthumb -mcpu=cortex-m0plus -nostdlib -ggdb
CXXFLAGS = ${CFLAGS}
LD = arm-none-eabi-ld
BIN = arm-none-eabi-objcopy
LDFLAGS = -T linker.ld

BINOUT := ./bin
LIBOUT := ./lib

CSRC := $(wildcard blink/*.c)
CXXSRC := $(wildcard blink/*.cpp)
ASRC := $(wildcard blink/*.s)

SRCS := ${CXXSRC} ${CSRC} ${ASRC}
OBJS := ${CXXSRC:%.cpp=%.o} ${CSRC:%.c=%.o} ${ASRC:%.s=%.o}

BUILT = app.elf app.uf2 app.bin app.dis

toolchain: ${BINOUT}/elf2uf2

${BINOUT}/elf2uf2: elf2uf2/main.cpp
	@mkdir -p bin
	g++ -o $@ $<

what:
	@echo ${SRCS}
	@echo ${OBJS}

#app.bin : app.elf
#	arm-none-eabi-objcopy -O binary app.elf app.bin
#	arm-none-eabi-objdump -d app.elf >app.list

app.elf: toolchain $(OBJS) linker.ld
	$(LD) $(LDFLAGS) -o $@ $(OBJS)
	arm-none-eabi-objcopy -O binary app.elf app.bin
	arm-none-eabi-objdump -d app.elf >app.dis
	bin/elf2uf2 app.elf app.uf2

%.o : %.c
	$(CC) $(CFLAGS) -c -o $@ $^

%.o : %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $^

%.o : %.s
	$(AS) -g -o $@ $<

clean :
	rm -f */*.o src/*.dis $(BUILT) bin/* a.out

flash : app.uf2
	cp app.uf2 /media/$(USER)/RPI-RP2

#app.uf2 : app.elf app.bin
#	$(PICO_SDK_PATH)/build/elf2uf2/elf2uf2 app.elf app.uf2
