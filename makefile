PROG = firmware

PROJECT_ROOT_PATH = $(realpath $(CURDIR)/../..)
DOCKER ?= docker run --rm -v $(PROJECT_ROOT_PATH):$(PROJECT_ROOT_PATH) -w $(CURDIR) mdashnet/armgcc

CFLAGS = 	-std=gnu99 -DCPU_MK65FN2M0VMI18 -DLWIP_TIMEVAL_PRIVATE=0 -DCPU_MK65FN2M0VMI18_cm4 -DUSE_RTOS=1 -DPRINTF_ADVANCED_ENABLE=1 -DTWR_K65F180M -DTOWER -DSERIAL_PORT_TYPE_UART=1 -DFSL_RTOS_FREE_RTOS -DSDK_DEBUGCONSOLE=0 -DCR_INTEGER_PRINTF -DPRINTF_FLOAT_ENABLE=0 -D__MCUXPRESSO -D__USE_CMSIS -DDEBUG -D__NEWLIB__ -DMG_ARCH=MG_ARCH_FREERTOS_LWIP -Os -fno-common -g3 -Wall -c  -ffunction-sections  -fdata-sections  -ffreestanding  -fno-builtin -fmerge-constants -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -fstack-usage

LINKFLAGS =	-nostdlib -Xlinker --gc-sections -Xlinker --sort-section=alignment -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -T twrk65f180m_lwip_tcpecho_freertos_Debug.ld

SOURCES = $(shell find $(CURDIR) -type f -name '*.c' -not -path "*/doc/*")
OBJECTS = $(SOURCES:%.c=build/%.o)

INCLUDES = $(addprefix -I, $(shell find $(CURDIR) -type d -not -name 'build'))

build: $(PROG).bin

$(PROG).bin: $(PROG).axf
	@$(DOCKER) arm-none-eabi-size $<
	@$(DOCKER) arm-none-eabi-objcopy -v -O binary $< $@

$(PROG).axf: $(OBJECTS)
	$(info LD $@)
	@$(DOCKER) arm-none-eabi-gcc $(LINKFLAGS) -L"./ld" $(OBJECTS) -o $@

build/%.o: %.c
	@mkdir -p $(dir $@)
	$(info CC $<)
	@$(DOCKER) arm-none-eabi-gcc $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -rf build/ firmware.axf firmware.bin