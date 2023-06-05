# zte-connector
Ericom ZTEdge Connector in a docker container
zte-client has been integrated into docker environment to allow for easy deployments in Cradlepoint routers. 

*Notes: Not all Cradlepoint models support docker containers. Please refer to specific router documentation to determine if it is compatible with the current project.

The **zte-client** can be used as a client or as a connector. Cradlepoint routers use connector mode.

To pull the container:

```bash
docker pull sstarzh/zte-connector:alpine.latest
```

Running in the connector mode:

```bash
docker run -ti --cap-add=NET_ADMIN --sysctl="net.ipv4.ip_forward=1" sstarzh/zte-connector:alpine.latest <tenant name> <connector name> <key> --connector [--debug]
```

Running in the client mode:

```bash
docker run -ti --cap-add=NET_ADMIN --sysctl="net.ipv4.ip_forward=1" sstarzh/zte-connector:alpine.latest <tenant name> <user> <password> [--debug]
```
## Deploying in Cradlepoint router

## Health check

**ztedge-client** supports HTTP health checks. The following parameters are configurable:
    --health-check-port <port>              health check port (0 for none) (default: 0)
    --health-check-path <path>              health check path (default: "/health")
    --health-check-timeout <sec>            how long the connection should be down (sec) for health check failure (default: 60)

By default container exposes port 51821/tcp and uses `/health` path. 