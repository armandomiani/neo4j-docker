FROM openjdk:11-jdk-slim

ENV NEO4J_SHA256 623c807ec23ed5c5e8db665a36bcdcb03a11ca2179ce24b61b220ecac60ace90
ENV NEO4J_VERSION 4.0.1
ENV NEO4J_HOME  /var/lib/neo4j
ENV NEO4J_EDITION community
ENV TINI_VERSION v0.18.0
ENV TINI_SHA256 12d20136605531b09a2c2dac02ccee85e1b874eb322ef6baf7561cd93f93c855
ENV NEO4J_TARBALL neo4j.tar.gz

RUN addgroup --system neo4j && adduser --system --no-create-home --home "${NEO4J_HOME}" --ingroup neo4j neo4j

COPY neo4jlabs-plugins.json /neo4jlabs-plugins.json

RUN apt update \
    && apt install -y curl wget gosu jq \
    && curl -L --fail --silent --show-error "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini" > /sbin/tini \
    && echo "${TINI_SHA256}  /sbin/tini" | sha256sum -c --strict --quiet \
    && chmod +x /sbin/tini \
    && curl -o ${NEO4J_TARBALL} --fail --silent --show-error --location --remote-name https://dist.neo4j.org/neo4j-community-${NEO4J_VERSION}-unix.tar.gz \
    && echo "${NEO4J_SHA256}  ${NEO4J_TARBALL}" | sha256sum -c --strict --quiet \
    && tar --extract --file ${NEO4J_TARBALL} --directory /var/lib \
    && mv /var/lib/neo4j-* "${NEO4J_HOME}" \
    && rm ${NEO4J_TARBALL} \
    && mv "${NEO4J_HOME}"/data /data \
    && mv "${NEO4J_HOME}"/logs /logs \
    && chown -R neo4j:neo4j /data \
    && chmod -R 777 /data \
    && chown -R neo4j:neo4j /logs \
    && chmod -R 777 /logs \
    && chown -R neo4j:neo4j "${NEO4J_HOME}" \
    && chmod -R 777 "${NEO4J_HOME}" \
    && ln -s /data "${NEO4J_HOME}"/data \
    && ln -s /logs "${NEO4J_HOME}"/logs \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get -y purge --auto-remove curl

ENV PATH "${NEO4J_HOME}"/bin:$PATH

WORKDIR "${NEO4J_HOME}"

VOLUME /data /logs

COPY docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 7474 7473 7687

ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
CMD ["neo4j"]