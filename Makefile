# 32 bits without debug information
FLAGS=
# 32 bits with debug information
#FLAGS=-Ddebug
# 64 bits without debug information
#FLAGS=-DHXCPP_M64
# 64 bits with debug information
#FLAGS=-Ddebug -DHXCPP_M64

all: haxelib
	haxe -x test.Main -lib hxbonjour
#	cd bin && neko Main.n

.PHONY: lib
lib:
	haxelib run hxcpp build.xml ${FLAGS}

.PHONY: haxelib
haxelib: lib
	haxelib dev hxbonjour .

.PHONY: clean
clean:
	rm -rf bin
	rm -rf ndll
	rm -rf obj
	rm -f hxbonjour.zip
	rm -f TestBonjour.n
