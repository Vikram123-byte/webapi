XSLTPROC=xsltproc
XSLTPROCFLAGS=--nodtdattr
XSLTSTYLESHEET=specgen.xsl
CVS2CL=cvs2cl
CVS2CLFLAGS=-r
CURL=curl
CURLFLAGS=-s

VNU=http://validator.nu
VNUFLAGS=-F level=error -F out=gnu -F parser=xmldtd -F schema=http://svn.versiondude.net/whattf/validator/trunk/schema/xhtml10/xhtml-strict.rnc -F laxtype=yes

CHECKLINK=checklink
CHECKLINKFLAGS=-q -b

TEE=tee
TEEFLAGS=-a

GREP=egrep
GREPFLAGS=

CUT=cut
CUTFLAGS=

WGET=wget
WGETFLAGS=--spider -nv

all: FileUpload.html

check: CHECKLOG

c: all ChangeLog

ChangeLog: FileUpload.html
	$(CVS2CL) $(CVS2CLFLAGS)

%.html: %.xhtml $(XSLTSTYLESHEET)
	$(XSLTPROC) $(XSLTPROCFLAGS) $(XSLTSTYLESHEET) $< > $@

CHECKLOG: FileUpload.html
	echo "checking $(realpath $<)" >> $@
	echo "Performing validation..." >> $@
	$(CURL) $(CURLFLAGS) $(VNUFLAGS) -F doc=@$< $(VNU) && echo "Document is valid." >> $@
	$(CHECKLINK) $(CHECKLINKFLAGS) $< | $(TEE) $(TEEFLAGS) $@
	for file in $$($(GREP) $(GREPFLAGS) "^http" $@ | $(CUT) $(CUTFLAGS) -f1); do \
	  ($(WGET) $(WGETFLAGS) "$$file" 2>&1 && echo "File exists: $$file") \
	  | $(TEE) $(TEEFLAGS) $@; \
	done

clean:
	$(RM) CHECKLOG
