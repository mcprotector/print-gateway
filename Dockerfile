FROM nginx:alpine

ENV CUPS_HOST=localhost
ENV CUPS_PORT=631

RUN apk add --no-cache fcgiwrap bash curl jq inotify-tools findutils

RUN echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf

RUN mkdir -p /scripts /tmp/uploads
RUN chmod 777 /var/run /tmp/uploads
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY watcher.sh print.sh task.sh /scripts
COPY cleanup.sh run.sh retry.sh /
RUN chmod +x /scripts/task.sh /scripts/watcher.sh /scripts/print.sh  /run.sh /cleanup.sh /retry.sh

RUN echo "0 3 * * * /cleanup.sh" >> /etc/crontabs/root
RUN echo "* * * * * /retry.sh" >> /etc/crontabs/root

EXPOSE 8502

CMD ["/run.sh"]