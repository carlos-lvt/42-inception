FROM debian:bookworm

# Install PHP-FPM and required extensions
	# php8.2-fpm: runs PHP so the website works
	# php8.2-cli: lets PHP run from the command line (needed for wp-cli)
	# php8.2-mysql: lets PHP talk to the database
	# php8.2-curl: lets PHP download stuff from the internet
	# php8.2-gd: lets PHP work with images (resize)
	# php8.2-intl: shows dates/numbers correctly per language
	# php8.2-mbstring: supports special characters and other languages
	# php8.2-soap: lets PHP talk to some external services
	# php8.2-xml: lets PHP read XML files
	# php8.2-zip: lets PHP open/create zip files (plugins, themes)
	# wget: tool to download files
	# mariadb-client: provides mysqladmin, used to check the DB is ready
	# wp-cli: command-line tool to manage WordPress (install, config, users)
RUN apt-get update && apt-get install -y \
	php8.2-fpm \
	php8.2-cli \
	php8.2-mysql \
	php8.2-curl \
	php8.2-gd \
	php8.2-intl \
	php8.2-mbstring \
	php8.2-soap \
	php8.2-xml \
	php8.2-zip \
	wget \
	curl \
	mariadb-client \
	&& ln -s /usr/sbin/php-fpm8.2 /usr/local/bin/php-fpm \
	&& curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp \
	&& rm -rf /var/lib/apt/lists/*

# WordPress directory. Now, eveything will be done here
WORKDIR	/var/www/html

COPY	conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY	tools/setup_wordpress.sh /usr/local/bin/setup_wordpress.sh
RUN 	chmod +x /usr/local/bin/setup_wordpress.sh

EXPOSE 	9000

ENTRYPOINT ["/usr/local/bin/setup_wordpress.sh"]