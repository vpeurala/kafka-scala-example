# kafka-scala-example

Helpful examples for using Apache Kafka with Scala.

# Prerequisites

You need to have the Kafka CLI installed.

## Getting started

Kick up the servers:

    docker-compose --file docker-compose-helloworld.yml up --detach

List topics.
    
    kafka-topics --bootstrap-server localhost:9092 --list

You don't see any topics. Create one.

    kafka-topics --bootstrap-server localhost:9092 --topic treffipalsta --create

Look again. Now we have a single topic called 'treffipalsta'.
    
    kafka-topics --bootstrap-server localhost:9092 --list

Say something to that topic:

    echo "Onx tääl ketää porilaisii? t: Miisa-87" | kafka-console-producer --bootstrap-server localhost:9092 --topic treffipalsta

Check that it is really there:

    kafka-console-consumer --bootstrap-server localhost:9092 --topic treffipalsta --from-beginning

There it is! You can press Ctrl+C to stop consuming.

Let's turn down our mighty cluster for the night.

    docker-compose --file docker-compose-helloworld.yml down

