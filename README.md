# Kafka: a love story

A romantic story about Apache Kafka. You need some technical skills to 
follow along as you read.

## Prerequisites

You need to have Docker Compose and the Kafka CLI tools installed.
I did this on a Mac, Windows support is not guaranteed.

## Chapter 1: Looking for love online

Mikko is a 43 years old programmer from Finland. Today he has a plan!

He opens up a terminal and fires up Apache Kafka (and Zookeeper) from
a very simple Docker Compose file.

    docker-compose --file docker-compose-helloworld.yml up --detach

List topics. No topics yet. That's about to change!
    
    kafka-topics --bootstrap-server localhost:9092 --list

Let's create a topic called **treffipalsta**! That is Finnish for a dating site.

    kafka-topics --bootstrap-server localhost:9092 --topic treffipalsta --create

Mikko wants to find a girlfriend. Or at least somebody to chat with.

    kafka-topics --bootstrap-server localhost:9092 --list

Yes, now the topic is there! Mikko writes a message to the topic.

    echo "Onx tääl ketää porilaisii? t: Mikko-43" | kafka-console-producer --bootstrap-server localhost:9092 --topic treffipalsta

The message means "are there any people from Pori around?"

What happens next? Can Mikko find love this way? Or at least a chat buddy?

## Chapter 2: Silent and deadly hacker action

Jenni is a hacker, also from Finland. Tonight she has hacked Mikko's home network,
just for fun and to see if there is anything interesting.

She notices that there is a Docker image running on Mikko's laptop, and
the image contains Kafka and Zookeeper. What is he hiding in there?

    kafka-topics --bootstrap-server localhost:9092 --list

Treffipalsta! This is something really weird.

    kafka-console-consumer --bootstrap-server localhost:9092 --topic treffipalsta --from-beginning

Jenni sees Mikko's message. WHAT? An old guy looking for company on a Kafka broker?

Jenni presses `Ctrl+C` to stop the consumer and writes back to Mikko:

    echo "Oletko sä jotenkin VÄHÄN outo tyyppi? t: Jenni (en kerro ikääni). PS: En ole porilainen." | kafka-console-producer --bootstrap-server localhost:9092 --topic treffipalsta

Jenni laughs out aloud at her witty response, and logs out of Mikko's laptop.

## Chapter 3: Build an impenetrable fortress

Later that night, Mikko checks if anybody has answered his message.

    kafka-console-consumer --bootstrap-server localhost:9092 --topic treffipalsta --from-beginning

A reply! But how? Impossible! How can anybody get into my secure home network?
Help! Mikko starts to panic. He turns down the broker with a swift command.

    docker-compose --file docker-compose-helloworld.yml down

Calm down Mikko, calm down, Mikko mutters to himself. Use your unbelievable
technical skills to protect the Kafka broker!

A username and a password? Nah, too easy for a determined hacker. This needs
industrial-strength measures: SSL certificate authentication!

Mikko updates his Docker Compose configuration a bit, and launches his new,
more secure Kafka broker.

    docker-compose --file docker-compose-ssl-login.yml up

To be continued...