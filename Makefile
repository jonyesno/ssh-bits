install:
	mkdir -p ~/bin
	@chmod a+x *.sh *.rb
	for _b in *.sh *.rb ; do ln -nsf $(CURDIR)/$${_b} ~/bin/$${_b} ; done
	@echo
	@echo scripts symlinked into ~/bin - make sure PATH sees that
