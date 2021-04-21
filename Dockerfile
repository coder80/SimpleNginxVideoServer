FROM ubuntu:20.04

LABEL maintainer="coder80@gmail.com"
LABEL version="0.1"
LABEL description="Nginx with vod module"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt-get install --no-install-recommends -y \
      wget ca-certificates make gcc g++ pkg-config git curl

RUN apt install build-essential mc -y
RUN apt-get install liblz-dev libpcre3 libpcre++-dev libssl-dev zlib1g-dev libxslt1-dev libgd-dev libgeoip-dev uuid-dev x264 ffmpeg -y

RUN mkdir nginx nginx-vod-module

ARG NGINX_VERSION=1.19.5
ARG VOD_MODULE_VERSION=1.27

RUN curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -C /nginx --strip 1 -xz
RUN curl -sL https://github.com/kaltura/nginx-vod-module/archive/${VOD_MODULE_VERSION}.tar.gz | tar -C /nginx-vod-module --strip 1 -xz

WORKDIR /nginx
RUN ./configure --prefix=/usr/local/nginx \
	--add-module=../nginx-vod-module \
	--with-http_ssl_module \
	--with-file-aio \
	--with-threads \
	--with-cc-opt="-O3"
RUN make
RUN make install
RUN rm -rf /usr/local/nginx/html /usr/local/nginx/conf/*.default
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
RUN mkdir /opt/static
RUN mkdir /opt/static/videos
RUN mkdir /opt/static/play
COPY hls.html /opt/static/play/hls.html
COPY dash.html /opt/static/play/dash.html
RUN ffmpeg -f lavfi -i testsrc=duration=10:size=1280x720:rate=30 -vcodec libx264 -pix_fmt yuv420p -b:v 2M -f mp4 /opt/static/videos/testsrc.mp4
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]
