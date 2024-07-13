server {
    listen 80;
    server_name domain.ru;

    access_log /var/log/nginx/wcms.ru-access.log;
    error_log /var/log/nginx/wcms.ru-error.log error;

    root /var/www/wintercms;
    index index.php index.html index.htm;

    location /backend {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php8.1-fpm-wintercms.sock;
        fastcgi_index index.php;
        include fastcgi.conf;
    }

    location ~ ^/favicon\.ico { try_files $uri /index.php; }
    location ~ ^/sitemap\.xml { try_files $uri /index.php; }
    location ~ ^/robots\.txt { try_files $uri /index.php; }
    location ~ ^/humans\.txt { try_files $uri /index.php; }

    location ~ /\.(?!well-known).* { deny all; }

    location ~ ^/storage/app/uploads/public { try_files $uri 404; }
    location ~ ^/storage/app/media { try_files $uri 404; }
    location ~ ^/storage/app/resized { try_files $uri 404; }
    location ~ ^/storage/temp/public { try_files $uri 404; }

    location ~ ^/modules/.*/assets { try_files $uri 404; }
    location ~ ^/modules/.*/resources { try_files $uri 404; }
    location ~ ^/modules/.*/behaviors/.*/assets { try_files $uri 404; }
    location ~ ^/modules/.*/behaviors/.*/resources { try_files $uri 404; }
    location ~ ^/modules/.*/widgets/.*/assets { try_files $uri 404; }
    location ~ ^/modules/.*/widgets/.*/resources { try_files $uri 404; }
    location ~ ^/modules/.*/formwidgets/.*/assets { try_files $uri 404; }
    location ~ ^/modules/.*/formwidgets/.*/resources { try_files $uri 404; }
    location ~ ^/modules/.*/reportwidgets/.*/assets { try_files $uri 404; }
    location ~ ^/modules/.*/reportwidgets/.*/resources { try_files $uri 404; }

    location ~ ^/plugins/.*/.*/assets { try_files $uri 404; }
    location ~ ^/plugins/.*/.*/resources { try_files $uri 404; }
    location ~ ^/plugins/.*/.*/behaviors/.*/assets { try_files $uri 404; }
    location ~ ^/plugins/.*/.*/behaviors/.*/resources { try_files $uri 404; }
    location ~ ^/plugins/.*/.*/reportwidgets/.*/assets { try_files $uri 404; }
    location ~ ^/plugins/.*/.*/reportwidgets/.*/resources { try_files $uri 404; }
    location ~ ^/plugins/.*/.*/formwidgets/.*/assets { try_files $uri 404; }
    location ~ ^/plugins/.*/.*/formwidgets/.*/resources { try_files $uri 404; }
    location ~ ^/plugins/.*/.*/widgets/.*/assets { try_files $uri 404; }
    location ~ ^/plugins/.*/.*/widgets/.*/resources { try_files $uri 404; }

    location ~ ^/themes/.*/assets { try_files $uri 404; }
    location ~ ^/themes/.*/resources { try_files $uri 404; }

    location / {
        proxy_pass http://localhost:4187;
    }
}
