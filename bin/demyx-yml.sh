#!/bin/bash
# Demyx
# https://demyx.sh

# Scan for open ports starting with 2222
while true; do
DEMYX_YML_SFTP_OPEN_PORT="$(netstat -tuplen 2>/dev/null | grep :${DEMYX_SSH:-2222} || true)"
    if [[ -z "$DEMYX_YML_SFTP_OPEN_PORT" ]]; then
        break
    else
        DEMYX_SSH="$((DEMYX_SSH+1))"
    fi
done

# Check for stack .env
DEMYX_YML_GET_STACK_ENV="$([[ -f /demyx/app/stack/.env ]] && cat /demyx/app/stack/.env)"

if [[ -n "$DEMYX_YML_GET_STACK_ENV" ]]; then
  DEMYX_YML_DOMAIN="$(echo "$DEMYX_YML_GET_STACK_ENV" | grep DEMYX_STACK_SERVER_API | awk -F '[=]' '{print $2}')"
  DEMYX_YML_AUTH="$(echo "$DEMYX_YML_GET_STACK_ENV" | grep DEMYX_STACK_AUTH | awk -F '[=]' '{print $2}')"

  # Only generate labels when DEMYX_YML_DOMAIN is not false
  if [[ "$DEMYX_YML_DOMAIN" != false ]]; then
      DEMYX_YML_LABELS="labels:
    - \"traefik.enable=true\"
    - \"traefik.http.routers.demyx.rule=Host(\`\${DEMYX_YML_DOMAIN}\`)\"
    - \"traefik.http.routers.demyx.entrypoints=https\"
    - \"traefik.http.routers.demyx.tls.certresolver=demyx\"
    - \"traefik.http.routers.demyx.service=demyx\"
    - \"traefik.http.services.demyx.loadbalancer.server.port=8080\"
    - \"traefik.http.routers.demyx.middlewares=demyx-auth\"
    - \"traefik.http.middlewares.demyx-auth.basicauth.users=\${DEMYX_YML_AUTH}\""

      # Generate /demyx/.env
      echo "# AUTO GENERATED
      DEMYX_YML_DOMAIN="$DEMYX_YML_DOMAIN"
      DEMYX_YML_AUTH="$DEMYX_YML_AUTH"
      " | sed "s|      ||g" > /demyx/.env
  fi
fi

# Check for CentOS/Fedora/RHEL strings in the kernel
DEMYX_YML_UNAME="$(uname -a)"
if [[ -n "$(echo "$DEMYX_YML_UNAME" | grep -i centos || true)" || -n "$(echo "$DEMYX_YML_UNAME" | grep -i fedora || true)" || -n "$(echo "$DEMYX_YML_UNAME" | grep -i rhel || true)" ]]; then
    DEMYX_YML_PRIVILEGED="privileged: true"
fi

# Generate /demyx/docker-compose.yml
echo "# AUTO GENERATED
version: \"2.4\"
services:
  socket:
    image: demyx/docker-socket-proxy
    cpus: ${DEMYX_CPU:-.5}
    mem_limit: ${DEMYX_MEM:-512m}
    container_name: demyx_socket
    restart: unless-stopped
    networks:
      - demyx_socket
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - CONTAINERS=1
      - EXEC=1
      - IMAGES=1
      - INFO=1
      - NETWORKS=1
      - POST=1
      - VOLUMES=1
    labels:
      - com.ouroboros.enable=false
    $DEMYX_YML_PRIVILEGED
  demyx:
    image: demyx/demyx
    cpus: ${DEMYX_CPU:-.5}
    mem_limit: ${DEMYX_MEM:-512m}
    container_name: demyx
    restart: unless-stopped
    hostname: $DEMYX_HOST
    depends_on: 
      - socket
    networks:
      - demyx
      - demyx_socket
    volumes:
      - demyx:/demyx
      - demyx_user:/home/demyx
      - demyx_log:/var/log/demyx
    environment:
      - DOCKER_HOST=tcp://demyx_socket:2375
      - DEMYX_BRANCH="$DEMYX_BRANCH"
      - DEMYX_MODE="$DEMYX_MODE"
      - DEMYX_HOST="$DEMYX_HOST"
      - DEMYX_SSH="$DEMYX_SSH"
      - TZ=America/Los_Angeles
    ports:
      - ${DEMYX_SSH}:2222
    $DEMYX_YML_LABELS
volumes:
  demyx:
    name: demyx
  demyx_log:
    name: demyx_log
  demyx_user:
    name: demyx_user
networks:
  demyx:
    name: demyx
  demyx_socket:
    name: demyx_socket
" > /demyx/docker-compose.yml
