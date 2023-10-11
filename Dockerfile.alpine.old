#FROM node:lts-alpine3.9
FROM node:alpine3.18
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
RUN mkdir -p /opt/ericom
COPY ztedge-client ztedge-client.js utils.js package.json package-lock.json ericomshield.crt ericomshield-new.crt /opt/ericom/
RUN chmod +x /opt/ericom/ztedge-client
RUN apk update && apk upgrade
RUN apk --no-cache add ca-certificates wget
RUN apk add --update dpkg wireguard-tools wireguard-go linux-headers at curl iproute2 iptables openssh openssl
RUN apk add --update nodejs-current npm
RUN ln -s /opt/ericom/ztedge-client /usr/local/bin/ztedge-client
RUN cd /opt/ericom && npm install --omit=dev
COPY wg-quick /usr/bin/wg-quick
RUN chmod +x /usr/bin/wg-quick
ENTRYPOINT ["/entrypoint.sh"]
CMD ["myTenant", "newConnector", "authKey", "apiKey", "tenantId"]
EXPOSE 51821
EXPOSE 51820/udp
