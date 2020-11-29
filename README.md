# Kafka: a love story

A romantic story about Apache Kafka. You need some technical skills to 
follow along as you read.

## Prerequisites

You need to have Docker Compose, OpenSSL and the Kafka CLI tools installed.
I did this on a Mac, Windows support is not guaranteed.

Then open a terminal and `cd` to the root of your local clone of this
repository to follow along!

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

Mikko decides to create his own certificate authority (CA) to sign his certs.
A good name would be "Mikon sertifikaattivirasto", it sounds official. Short
version of it can be "mikko-ca". First Mikko makes a certificate request.

    openssl req -newkey rsa:2048 -sha1 -passout pass:mustikkapiirakka -keyout ssl/mikko-ca.key -out ssl/mikko-ca.csr -subj "/CN=Mikon sertifikaattivirasto" -reqexts ext -batch -config <(printf "\ndistinguished_name=req_distinguished_name\n\n[req_distinguished_name]\nC=FI\nST=Uusimaa\nL=Helsinki\nO=Mikon paja\nOU=Sertifikaattiosasto\n\n[ext]\nbasicConstraints=CA:TRUE,pathlen:0")

Mikko checks that everything went fine and the key is a valid RSA key.

    openssl rsa -check -in ssl/mikko-ca.key -passin pass:mustikkapiirakka

Because Mikko is a careful boy, he verifies the CSR too. 

    openssl req -text -noout -verify -in ssl/mikko-ca.csr

Everything looks good. Time to sign a self-signed certificate.

    openssl x509 -req -in ssl/mikko-ca.csr -sha256 -days 3650 -passin pass:mustikkapiirakka -signkey ssl/mikko-ca.key -out ssl/mikko-ca.crt -extensions ext -extfile <(printf "\n[ext]\nbasicConstraints=CA:TRUE,pathlen:0")

Bwahahaa, all looking good! Mikko is a careful boy.

    openssl x509 -in ssl/mikko-ca.crt -text -noout

Then generate a key for the Kafka broker.

    openssl genrsa -aes256 -passout pass:eppunormaali -out ssl/kafka-broker.key 2048

Verify.

    openssl rsa -check -in ssl/kafka-broker.key -passin pass:eppunormaali

Generate CSR... this is getting exciting now.

    openssl req -new -sha256 -key ssl/kafka-broker.key -passin pass:eppunormaali -out ssl/kafka-broker.req -subj "/CN=kafka-broker" -reqexts san -config <(printf "\ndistinguished_name=req_distinguished_name\n\n[req_distinguished_name]\nC=FI\nST=Uusimaa\nL=Helsinki\nO=Mikon paja\nOU=Sertifikaattiosasto\n\n[san]\nsubjectAltName=DNS:kafka-broker\nextendedKeyUsage=serverAuth,clientAuth")

Still verify.

    openssl req -in ssl/kafka-broker.req -text -noout

And then the money shot: sign the certificate request for kafka-broker with your
own CA root cert!

    openssl x509 -req -sha256 -CA ssl/mikko-ca.crt -CAkey ssl/mikko-ca.key -passin pass:mustikkapiirakka -in ssl/kafka-broker.req -out ssl/kafka-broker.crt -days 3650 -CAcreateserial

...and verify.

    openssl x509 -in ssl/kafka-broker.crt -text -noout

Turn it into PKCS12 format:

    openssl pkcs12 -export -in ssl/kafka-broker.crt -inkey ssl/kafka-broker.key -passin pass:eppunormaali -chain -CAfile ssl/mikko-ca.crt -name kafka-broker -out ssl/kafka-broker.p12 -passout pass:eppunormaali

And from that, into a Java keystore:

    keytool -importkeystore -srckeystore ssl/kafka-broker.p12 -srcstorepass eppunormaali -srcstoretype pkcs12 -destkeystore ssl/kafka-broker.keystore.jks -deststorepass eppunormaali -deststoretype pkcs12

Verify that it contains an entry with no warnings:

    keytool -list -keystore ssl/kafka-broker.keystore.jks -storepass eppunormaali

Then create a TRUSTSTORE! BWAHAA!

    keytool -import -keystore ssl/kafka-broker.truststore.jks -alias mikko-ca -file ssl/mikko-ca.crt -storepass eppunormaali -noprompt 



Muhahahaa! The hackers will never get past this protection.




Mikko updates his Docker Compose configuration a bit, and launches his new,
more secure Kafka broker.

    docker-compose --file docker-compose-ssl-login.yml up
