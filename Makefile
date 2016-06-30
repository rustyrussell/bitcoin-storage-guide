DEB_DIR=debs

check: urlchecks sigchecks sumchecks

urlchecks: README.md
	for url in `sed -n 's,.*\(http[^)]*\).*,\1,p' $<`; do if wget -q --spider $$url; then echo $$url OK; else echo $$url fail; exit 1; fi; done

sigchecks: README.md README.md.gpg
	gpg --verify README.md.gpg

sumchecks: README-sumchecks offline-sumchecks

README-sumchecks: README.md
	sed -n 's,^[^`]*`\([a-f0-9]*\).*<!--- sha256sum \(.*\) --->.*,\1 \2,p' $< | while read SUM FILE; do if [ "`sha256sum $$FILE`" != "$$SUM  $$FILE" ]; then echo $$FILE wrong; exit 1; else echo $$FILE OK; fi; done

offline-sumchecks: offline
	sed -n "s,^ *'\([^']*.deb\)':'\([^']*\)'.*,\1 \2,p" $< | while read FILE SUM; do if [ "`sha256sum $(DEB_DIR)/$$FILE`" != "$$SUM  $(DEB_DIR)/$$FILE" ]; then echo $$FILE wrong; exit 1; else echo $$FILE OK; fi; done

README.md.gpg: README.md
	gpg -s README.md

