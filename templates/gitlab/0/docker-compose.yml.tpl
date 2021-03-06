version: '2'
services:
  gitlab-server:
    labels:
      traefik.port: 80
      traefik.enable: true
      traefik.frontend.rule: "Host:${GIT_HOSTNAME}.${GIT_DOMAIN}"
      traefik.acme.domains: "${GIT_HOSTNAME}.${GIT_DOMAIN}"
      io.rancher.sidekicks: gitlab-data, gitlab-cronbkp
      io.rancher.scheduler.affinity:host_label: ${HOST_AFFINITY}
    hostname: "${GIT_HOSTNAME}.${GIT_DOMAIN}"
    image: gitlab/gitlab-ce:9.3.7-ce.0
    container_name: gitlab-server
    volumes_from:
      - gitlab-data

  gitlab-cronbkp:
    image: vipconsult/cron
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      DOCKER_API_VERSION: 1.23
      SMTP_SERVER: ${SMTP_SERVER}
      DOMAINNAME: ${GIT_DOMAIN}
      MAILTO: ${MAIL_TO}
      CRONTASK_1: "0 0 * * *  root docker exec -i `docker ps | grep gitlab-ce | awk '{print $$1}'` gitlab-rake gitlab:backup:create"

  gitlab-data:
    labels:
      io.rancher.container.start_once: 'true'
    entrypoint:
      - /bin/true
    hostname: gitdata
    image: gitlab/gitlab-ce:9.3.7-ce.0
    volumes:
      - "gitlab-etc:/etc/gitlab"
      - "gitlab-log:/var/log/gitlab"
      - "gitlab-opt:/var/opt/gitlab"

volumes:
  gitlab-etc:
    driver: ${VOLUME_DRIVER}
    {{- if eq .Values.EXTERNAL "true" }}
    external: true
    {{- end }}
  gitlab-log:
    driver: ${VOLUME_DRIVER}
    {{- if eq .Values.EXTERNAL "true" }}
    external: true
    {{- end }}
  gitlab-opt:
    driver: ${VOLUME_DRIVER}
    {{- if eq .Values.EXTERNAL "true" }}
    external: true
    {{- end }}
