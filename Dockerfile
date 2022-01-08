FROM php:7.4-fpm

# Copy composer.lock and composer.json
COPY app/composer.* /var/www/

# Set working directory
WORKDIR /var/www/

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl 

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql exif pcntl

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www 
RUN useradd -u 1000 www -s /bin/bash -g www

# Copy existing application directory contents
COPY . /var/www/

WORKDIR /var/www/app/

RUN chmod +x artisan

# import your packages and create the vendor folder
RUN composer install

# Copy existing application directory permissions
COPY --chown=www:www . /var/www/

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
