#!/bin/bash

function build() {
    docker build -t neo4j-docker .
}

function run() {
# -e 'NEO4JLABS_PLUGINS=["graphql"]' \
    docker run \
        --publish=7474:7474 --publish=7687:7687 \
        --publish=2004:2004 \
        -e "NEO4J_AUTH=neo4j/admin123" \
        -e "NEO4J_dbms_security_auth__enabled=true" \
        --name "neo4j" \
        --volume=$HOME/neo4j/data:/data \
        --volume=$HOME/neo4j/logs:/logs \
        neo4j-docker
}

function run_tests() {
    docker exec -ti neo4j -- cypher-shell -u neo4j -p admin123 -d neo4j --format plain 'MATCH (ee:Person) WHERE ee.name = "Armando" RETURN ee.name;'
    docker exec -ti neo4j -- cypher-shell -u neo4j -p admin123 -d neo4j --format plain 'CREATE(ee:Person { name: "Armando", from: "Poland", age: 35})'
}

function clean() {
    docker rm -f `docker ps -aq`
    echo "All containers have been removed."
}

function attach() {
    docker exec -ti neo4j bash
}
