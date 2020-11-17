FROM pihole/pihole:latest
MAINTAINER Carles Barreda <cbm@carlesbarreda.cat>

RUN useradd -r -d /etc/dnscrypt-proxy -s /usr/sbin/nologin dnscrypt-proxy \
	&& wget -O /dnscrypt-proxy-linux_arm64-2.0.44.tar.gz https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.0.44/dnscrypt-proxy-linux_arm64-2.0.44.tar.gz \
	&& tar xzvf /dnscrypt-proxy-linux_arm64-2.0.44.tar.gz -C / \
	&& cp /linux-arm64/example-dnscrypt-proxy.toml /linux-arm64/dnscrypt-proxy.toml \
	&& sed -i -e "39s/:53'/:5300'/" -e "52s/^# user_name.*$/user_name = 'dnscrypt-proxy'/" -e "73s/false/true/" -e "213s/'9.9.9.9:53', '8.8.8.8:53'/'1.1.1.2:53', '1.0.0.2:53'/" -e "239s/'9.9.9.9:53'/'1.1.1.2:53'/" /linux-arm64/dnscrypt-proxy.toml \
	&& chown -R dnscrypt-proxy:dnscrypt-proxy /linux-arm64 \
	&& mv /linux-arm64/dnscrypt-proxy /usr/bin \
	&& mv /linux-arm64 /usr/share/dnscrypt-proxy \
	#&& chown root:root /usr/bin/dnscrypt-proxy \
	#&& chown -R dnscrypt-proxy:dnscrypt-proxy /usr/share/dnscrypt-proxy \
	&& cp -r /usr/share/dnscrypt-proxy /etc \
	&& mkdir -p /etc/services.d/dnscrypt-proxy \

	&& echo '#!/usr/bin/with-contenv bash' > /etc/cont-init.d/30-start.sh \
	&& echo 'set -e' >> /etc/cont-init.d/30-start.sh \
	&& echo 's6-echo "Initializing dnscrypt-proxy"' >> /etc/cont-init.d/30-start.sh \
	&& echo '[[ ! -d /etc/dnscrypt-proxy ]] && mkdir /etc/dnscrypt-proxy' >> /etc/cont-init.d/30-start.sh \
	&& echo -n '[[ ! -f /etc/dnscrypt-proxy/dnscrypt-proxy.toml ]]' >> /etc/cont-init.d/30-start.sh \
	&& echo ' && cp /usr/share/dnscrypt-proxy/* /etc/dnscrypt-proxy/' >> /etc/cont-init.d/30-start.sh \
	&& echo 'chown -R dnscrypt-proxy:dnscrypt-proxy /etc/dnscrypt-proxy' >> /etc/cont-init.d/30-start.sh \
	&& chmod 755 /etc/cont-init.d/30-start.sh \

	&& echo '#!/usr/bin/with-contenv bash' > /etc/services.d/dnscrypt-proxy/finish \
	&& echo 's6-echo "Stopping lighttpd"' >> /etc/services.d/dnscrypt-proxy/finish \
	&& echo 'killall -9 dnscrypt-proxy' >> /etc/services.d/dnscrypt-proxy/finish \
	&& chmod 755 /etc/services.d/dnscrypt-proxy/finish \

	&& echo '#!/usr/bin/with-contenv bash' > /etc/services.d/dnscrypt-proxy/run \
	&& echo 's6-echo "Starting dnscrypt-proxy"' >> /etc/services.d/dnscrypt-proxy/run \
	#&& echo '[[ ! -d /etc/dnscrypt-proxy ]] && mkdir /etc/dnscrypt-proxy' >> /etc/services.d/dnscrypt-proxy/run \
	#&& echo -n '[[ ! -f /etc/dnscrypt-proxy/dnscrypt-proxy.toml ]]' >> /etc/services.d/dnscrypt-proxy/run \
	#&& echo ' && cp /usr/share/dnscrypt-proxy/* /etc/dnscrypt-proxy/' >> /etc/services.d/dnscrypt-proxy/run \
	#&& echo 'chown -R dnscrypt-proxy:dnscrypt-proxy /etc/dnscrypt-proxy' >> /etc/services.d/dnscrypt-proxy/run \
	&& echo 'dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml' >> /etc/services.d/dnscrypt-proxy/run \
	&& chmod 755 /etc/services.d/dnscrypt-proxy/run

EXPOSE 5300/tcp
EXPOSE 5300/udp

VOLUME /etc/dnscrypt-proxy
