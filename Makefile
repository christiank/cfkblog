.PHONY: \
	migrations dbshell dev-server-start server-start server-restart update

DB=./db/cfkblog.sqlite3
DEPLOYDIR=/home/christian/blog/blog
OPSDIR=/home/christian/blog-ops

public/css/blog.css: stylesheets/blog.scss
	mkdir -p public/css
	sass $(.ALLSRC) $(.TARGET)

migrations:
	sequel -E -m ./migrations sqlite://$(DB)

dbshell:
	sequel -r ./models/post sqlite://$(DB)

update: migrations public/css/blog.css

dev-server-start: update
	rackup

server-start: update
	thin -c $(DEPLOYDIR) -d -u christian -g users -R config.ru \
		-P $(OPSDIR)/thin.pid -l $(OPSDIR)/thin.log \
		start

server-restart: update
	thin -c $(DEPLOYDIR) -d -u christian -g users -R config.ru \
		-P $(OPSDIR)/thin.pid -l $(OPSDIR)/thin.log \
		restart
