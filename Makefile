FLAGS=-DHXCPP_M64

all: haxelib
	haxe -x test.TestBonjour -lib hxbonjour
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
