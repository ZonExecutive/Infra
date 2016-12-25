proxy_cache_path /var/cache/nginx/gcmap levels=1:2 keys_zone=gcmap:10m inactive=24h;

server {
	listen 80;
	listen [::]:80;

	server_name gcmap.zonexecutive.com;

	location / {
		proxy_cache gcmap;
		proxy_cache_valid 200 302 5m;
		proxy_cache_valid 301 1h;
		proxy_cache_valid 404 1m;

		proxy_method GET;
		proxy_pass_request_body off;
		proxy_pass http://www.gcmap.com/;

		add_header X-Cache-Status $upstream_cache_status;

		proxy_ignore_headers Cache-Control;

		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	}
}
