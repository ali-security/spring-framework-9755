#!/bin/bash
set -ex

apt update
apt install -y maven

git clone --depth 1 --branch v0.0.9 https://github.com/spring-attic/propdeps-plugin.git /tmp/propdeps-plugin

# Replace propdeps-plugin's build.gradle: the original references jfrog.bintray.com (dead)
# and depends on org.jfrog.buildinfo:build-info-extractor:2.6.0 which isn't on
# plugins.gradle.org. The replacement uses Maven Central and drops the JFrog dependency.
cat > /tmp/propdeps-plugin/build.gradle <<'PROPDEPS_GRADLE'
plugins {
        id "java-gradle-plugin"
}

apply plugin: 'groovy'
apply plugin: 'eclipse'
apply plugin: 'idea'
apply plugin: 'maven'

repositories {
        mavenLocal()
        mavenCentral()
}

group = 'io.spring.gradle'

dependencies {
        compile gradleApi()
        compile localGroovy()
        testCompile 'junit:junit:4.12'
        testCompile 'org.mockito:mockito-core:2.5.4'
        testCompile 'org.assertj:assertj-core:3.5.2'
        testCompile 'org.apache.commons:commons-io:1.3.2'
        testCompile('org.spockframework:spock-core:1.0-groovy-2.4') {
                exclude module: 'groovy-all'
        }
}
PROPDEPS_GRADLE

cd /tmp/propdeps-plugin
./gradlew install -x test

curl https://maven.repository.redhat.com/ga/com/ibm/websphere/uow/6.0.2.17/uow-6.0.2.17.jar -o /tmp/uow-6.0.2.17.jar && \
mvn install:install-file -Dfile=/tmp/uow-6.0.2.17.jar -DgroupId=com.ibm.websphere -DartifactId=uow -Dversion=6.0.2.17 -Dpackaging=jar -Dhttps.protocols=TLSv1.2
