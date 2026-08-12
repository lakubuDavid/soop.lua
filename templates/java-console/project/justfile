@default:
    just --list
build-run:
    mvn package
    mvn exec:java -Dexec.mainClass="com.{name}.app.App"
run:
    mvn exec:java -Dexec.mainClass="com.{name}.app.App"
build:
    mvn package
clean:
    mvn clean
