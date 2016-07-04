DEB_DIR=debs

check: urlchecks sigchecks sumchecks

urlchecks: README.md
	@for url in `sed -n 's,.*\(http[^)]*\).*,\1,p' $<`; do if wget -q --spider $$url; then echo $$url OK; else echo $$url fail; exit 1; fi; done

sigchecks: README.md
	gpg --verify README.md.sig README.md

sumchecks: README-sumchecks offline-sumchecks

README-sumchecks: README.md
	@sed -n '/^<!--- sha256sum .* --->/{$!{ N; s/.*sha256sum \(.*\) --->[^`]*`\([a-f0-9]*\).*/\1 \2/p;}}' $< | while read FILE SUM; do echo -n $$FILE...; if [ "`sha256sum $$FILE`" != "$$SUM  $$FILE" ]; then echo WRONG; exit 1; else echo OK; fi; done

offline-sumchecks: offline
	@sed -n "s,^ *'\([^']*.deb\)':'\([^']*\)'.*,\1 \2,p" $< | while read FILE SUM; do if [ "`sha256sum $(DEB_DIR)/$$FILE`" != "$$SUM  $(DEB_DIR)/$$FILE" ]; then echo $$FILE wrong; exit 1; else echo $$FILE OK; fi; done

README.md.sig: README.md
	gpg -b README.md

