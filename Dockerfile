FROM ubuntu:focal
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
RUN apt-get update && apt-get upgrade -y
RUN apt-get install dpkg wireguard wireguard-tools at curl libc6 libc-bin iproute2 iptables -y
RUN curl -fsSL https://deb.nodesource.com/setup_18.x -o /nodesetup.sh
RUN chmod +x /nodesetup.sh && /nodesetup.sh
RUN apt-get install -y nodejs
RUN curl -fsSL  https://www.ericom.com/ZTEdge/downloads/Clients3.9/Linux/ztedge-client.deb -o /tmp/ztedge-client.deb
RUN dpkg -i /tmp/ztedge-client.deb
RUN rm -f /tmp/ztedge-client.deb
ENTRYPOINT ["/entrypoint.sh"]
CMD ["myTenant", "newConnector", "authKey"]
