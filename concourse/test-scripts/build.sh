#!/bin/bash
set -e
set -x

export ROOT_FOLDER=$( pwd )

M2_HOME="${HOME}/.m2"
M2_CACHE="${ROOT_FOLDER}/maven"

echo "Generating symbolic links for caches"

[[ -d "${M2_CACHE}" && ! -d "${M2_HOME}" ]] && ln -s "${M2_CACHE}" "${M2_HOME}"


cd spring-petclinic-testing-branch

# skipt the tests
#mvn clean install -DskipTests
mvn clean verify sonar:sonar sonar-quality-gate:check  -Dsonar.login=${login} -Dsonar.host.url=${url}