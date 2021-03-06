
GCCPARAMS = -m32
ASPARAMS  = --32
LDPARAMS  = -melf_i386

objects = loader.o kernel.o

%.o: %.cpp
	gcc $(GCCPARAMS) -o $@ -c $<

%.o: %.s	
	as $(ASPARAMS) -o $@ $<

mykernel.bin: linker.ld $(objects)
	ld $(LDPARAMS) -T $< -o $@ $(objects)

NexusOS1.0.iso: mykernel.bin
	mkdir iso
	mkdir iso/boot
	mkdir iso/boot/grub
	cp $< iso/boot/
	echo 'set timeout=0' >> iso/boot/grub/grub.cfg
	echo 'set default=0' >> iso/boot/grub/grub.cfg
	echo '' >> iso/boot/grub/grub.cfg
	echo 'menuentry "NexusOS 1.0" {' >> iso/boot/grub/grub.cfg
	echo '	multiboot /boot/mykernel.bin' >> iso/boot/grub/grub.cfg
	echo '	boot' >> iso/boot/grub/grub.cfg
	echo '}' >> iso/boot/grub/grub.cfg
	grub-mkrescue --output=$@ iso
	rm -rf iso

run: NexusOS1.0.iso
	(killall VirtualBox && sleep 1) || true
	VirtualBox --startvm "NexusOS CD" &


install: mykernel.bin
	sudo cp $< /boot/nexuskernel.bin