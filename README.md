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

## Chapter 3: Building an impenetrable fortress

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

    openssl req -newkey rsa:2048 -sha256 -passout pass:mustikkapiirakka -keyout ssl/mikko-ca.key -out ssl/mikko-ca.csr -subj "/CN=mikkomulperi.fi" -reqexts ext -batch -config <(printf "\ndistinguished_name=req_distinguished_name\n\n[req_distinguished_name]\nC=FI\nST=Uusimaa\nL=Helsinki\nO=Mikon paja\nOU=Sertifikaattiosasto\n\n[ext]\nbasicConstraints=critical,CA:TRUE,pathlen:0")

Mikko checks that everything went fine and the key is a valid RSA key.

    openssl rsa -check -in ssl/mikko-ca.key -passin pass:mustikkapiirakka

Because Mikko is a careful boy, he verifies the CSR too. 

    openssl req -text -noout -verify -in ssl/mikko-ca.csr

Everything looks good. Time to sign a self-signed certificate.

    openssl x509 -req -in ssl/mikko-ca.csr -sha256 -days 3650 -passin pass:mustikkapiirakka -signkey ssl/mikko-ca.key -out ssl/mikko-ca.crt -extensions ext -extfile <(printf "\n[ext]\nbasicConstraints=critical,CA:TRUE,pathlen:0")

Bwahahaa, all looking good! Mikko is a careful boy.

    openssl x509 -in ssl/mikko-ca.crt -text -noout

Then generate a key for the Kafka broker.

    openssl genrsa -aes128 -passout pass:eppunormaali -out ssl/kafka-broker.key 2048

Verify. Verify everything, Mikko! Your hacker honor is in danger here.

    openssl rsa -check -in ssl/kafka-broker.key -passin pass:eppunormaali

Generate CSR... this is getting exciting now.

    openssl req -new -sha256 -key ssl/kafka-broker.key -passin pass:eppunormaali -out ssl/kafka-broker.req -subj "/CN=kafka-broker.mikkomulperi.fi" -reqexts san -config <(printf "\ndistinguished_name=req_distinguished_name\n\n[req_distinguished_name]\nC=FI\nST=Uusimaa\nL=Helsinki\nO=Mikon paja\nOU=Sertifikaattiosasto\n\n[san]\nsubjectAltName=DNS:kafka-broker.mikkomulperi.fi\nextendedKeyUsage=clientAuth,serverAuth\n")

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

Mikko trashes the old Docker containers lying around. No need for them anymore! See what a shell scripting wizard Mikko is, by the way!

    docker ps -a | tail -n +2 | awk '{print $1}' | xargs docker rm -f

Now Mikko has to get in himself... so he needs a client certificate that the
broker trusts.

So he generates another key.

    openssl req -newkey rsa:2048 -sha256 -passout pass:vainmikontiedossa -keyout ssl/kafka-client.key -out ssl/kafka-client.csr -subj "/CN=kafka-client.mikkomulperi.fi" -reqexts ext -batch -config <(printf "\ndistinguished_name=req_distinguished_name\n\n[req_distinguished_name]\nC=FI\nST=Uusimaa\nL=Helsinki\nO=Mikon paja\nOU=Sertifikaattiosasto\n\n[ext]\nextendedKeyUsage=clientAuth,serverAuth\n")

Mikko checks that everything went fine and the key is a valid RSA key.

    openssl rsa -check -in ssl/kafka-client.key -passin pass:vainmikontiedossa

Because Mikko is a careful boy, he verifies the CSR too. 

    openssl req -text -noout -verify -in ssl/kafka-client.csr

And signs it with his devious self-made CA certificate. For 10 years.

    openssl x509 -req -in ssl/kafka-client.csr -sha256 -days 3650 -passin pass:mustikkapiirakka -signkey ssl/mikko-ca.key -out ssl/kafka-client.crt

TODO or is this better? 

    openssl x509 -req -in ssl/kafka-client.csr -sha256 -days 3650 -passin pass:mustikkapiirakka -CA ssl/mikko-ca.crt -CAkey ssl/mikko-ca.key -out ssl/kafka-client.crt

A careful boy get the worm:

    openssl x509 -in ssl/kafka-client.crt -text -noout

Produce the chain:

    cat ssl/kafka-client.crt ssl/mikko-ca.crt > ssl/client-chain.pem

Turn it into PKCS12 format: NOOOO!!!

    openssl pkcs12 -export -in ssl/kafka-client.crt -inkey ssl/kafka-client.key -passin pass:vainmikontiedossa -chain ssl/client-chain.pem -CAfile ssl/mikko-ca.crt -name kafka-client -out ssl/kafka-client.p12 -passout pass:vainmikontiedossa

Actually this way:

    openssl pkcs12 -export -out ssl/kafka-client.p12 -inkey ssl/kafka-client.key -in ssl/kafka-client.crt -certfile ssl/mikko-ca.crt -passin pass:vainmikontiedossa -passout pass:vainmikontiedossa

And from that, into a Java keystore:

    keytool -importkeystore -srckeystore ssl/kafka-client.p12 -srcstorepass vainmikontiedossa -srcstoretype pkcs12 -destkeystore ssl/kafka-client.keystore.jks -deststorepass vainmikontiedossa -deststoretype pkcs12

Verify that it contains an entry with no warnings:

    keytool -list -keystore ssl/kafka-broker.keystore.jks -storepass eppunormaali

Then create a TRUSTSTORE! BWAHAA!

    keytool -import -keystore ssl/kafka-client.truststore.jks -alias mikko-ca -file ssl/mikko-ca.crt -storepass vainmikontiedossa -noprompt

Mikko updates his Docker Compose configuration a bit, and launches his new,
more secure Kafka broker.

    docker-compose --file docker-compose-ssl-login.yml up --detach

Then Mikko tries to write a message to his dating site:

    KAFKA_OPTS='-Djavax.net.debug=all' JAVA_OPTS='-Xmx4g javax.net.debug=all' kafka-console-producer --bootstrap-server localhost:9092 --topic inbound --producer.config client-ssl.properties

Doesn't work... has to debug the connection with openssl.

    openssl s_client -connect localhost:9092

Hmm, it complains about a self signed certificate.

    openssl s_client -connect localhost:9092 -CAfile ssl/mikko-ca.crt -cert ssl/kafka-client.crt -key ssl/kafka-client.key

That one works, so there is something wrong when giving kafka-console-producer the certificate to use.

    KAFKA_OPTS='-Djavax.net.debug=all' JAVA_OPTS='-Xmx4g javax.net.debug=all' kafka-console-producer --bootstrap-server kafka-broker.mikkomulperi.fi:9092 --topic inbound --producer.config client-ssl.properties

Okay, a quick /etc/hosts trick never hurt anyone. Emojis here.

    sudo vim /etc/hosts # ... and add kafka-broker.mikkomulperi.fi there, pointing to localhost.

And now the reply to the mysterious stranger.

    echo "Mitä ihmettä täällä tapahtuu? Kuka sä olet?" | kafka-console-producer --bootstrap-server kafka-broker.mikkomulperi.fi:9092 --topic treffipalsta --producer.config client-ssl.properties

Some time later...

## Chapter 4. Jenni's revenge

Jenni comes back from her Krav Maga class and notices that there is a blinking red light on her dashboard.
Something has happened in a computer she has taken over. She always installs monitoring software.

It has something to do with Mikko's Kafka broker. Jenni logs in as root to Mikko's laptop, and tries to read the messages:

    kafka-console-consumer --bootstrap-server kafka-broker.mikkomulperi.fi:9092 --topic treffipalsta

Aha, it's somehow protected now. Let's see.

5 seconds later Jenni finds Mikko's new `docker-compose-ssl-login.yml` file.

Another 5 seconds later Jenni finds all Mikko's carefully constructed SSL certificates, private keys and other stuff under `ssl/` directory.

What kind of fool is this?

    kafka-console-consumer --bootstrap-server kafka-broker.mikkomulperi.fi:9092 --topic treffipalsta --consumer.config client-ssl.properties --from-beginning

> Mitä ihmettä täällä tapahtuu? Kuka sä olet?

Jenni laughs and takes a sip of coffee.

    echo "I'm your worst nightmare. ;)" | kafka-console-producer --bootstrap-server kafka-broker.mikkomulperi.fi:9092 --topic treffipalsta --producer.config client-ssl.properties

