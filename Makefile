all: haxelib
	haxe -x TestBonjour -lib hxbonjour
#	cd bin && neko Main.n

.PHONY: lib
lib:
	haxelib run hxcpp build.xml ${FLAGS}

.PHONY: haxelib
haxelib: lib
	rm -f hxbonjour.zip
	zip -r hxbonjour src hxbonjour include ndll build.xml haxelib.json
	haxelib local hxbonjour.zip

.PHONY: clean
clean:
	rm -rf bin
	rm -rf ndll
	rm -rf obj
	rm -f hxbonjour.zip
	rm -f TestBonjour.n
