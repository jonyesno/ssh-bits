install:
	mkdir -p ~/bin
	@chmod a+x *.sh *.rb playsound
	cp -v *.sh *.rb ~/bin/
	cp -v *.wav ~/etc
	cp -v playsound ~/bin
	@echo
	@echo scripts install in ~/bin - make sure PATH sees that
