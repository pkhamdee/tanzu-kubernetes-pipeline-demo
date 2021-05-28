#! /bin/bash

cd spring-petclinic-testing-branch

# run only Integration Tests
mvn failsafe:integration-test

exit 0