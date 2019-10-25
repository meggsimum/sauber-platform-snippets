Lisa Scherf <br>
SoftwareAG, Darmstadt, Germany <br>
25.10.2019

# UM and JavaAPI
> This example shows how to start a Universal Messaging (UM) server in a docker container and publish events and subscribe to a channel called "HeartbeatChannel" using a Java container. <br>
> Universal Messaging 10.3 documentation: https://documentation.softwareag.com/onlinehelp/Rohan/num10-3/10-3_UM_webhelp/index.html
## Files
The folder contains:
* DockerfileSubscriber - Dockerfile to build an image with a java application that can be run to subscribe to the "HeartbeatChannel" 
* DockerfilePublisher - Dockerfile to build an image with a java application that can be run to publish an example event to the "HeartbeatChannel" 
* JavaPublisher.jar - java application to publish an event to a UM channel containing the needed libraries and java file
* JavaSubscriber.jar - java application to subscribe to a UM channel containing the needed libraries and java file

## Start the UM server
Open a terminal and navigate to this folder.
You can start up a universal messaging server in the background by running the following command.
You have to specify the port you want to use for UM.
```
$ docker run -d -p <port>:9000 --name um-server store/softwareag/universalmessaging-server:10.3
```

To check the logs of particular universal messaging server:
```
$ docker logs um-server
```

## Subscribe to the channel "HeartbeatChannel"
You first have to build the image by running the following command.
```
$docker build -f DockerfileSubscriber -t java-subscribe .
```

Then you can run the image with the following command. um_IP is the IP adress of the running UM server and port the port you chose for the UM server earlier, you can check this by running "docker inspect um-server".

```
$ docker run -it -e umserver=<um_IP>:<port> java-subscribe
```
You should see "Press any key to quit !" written in your terminal. If an event is published to the "HeartbeatChannel", you will see the event information printed out.
Open another window and follow the next steps to publish an event to the channel.

## Publish an event to the "HeartbeatChannel"
You first have to build the image by running the following command.
```
$ docker build -f DockerfilePublisher -t java-publish .
```

Then you can run the image with the following command. um_IP is the IP adress of the running UM server and port the port you chose for the UM server earlier, you can check this by running "docker inspect um-server".
```
$ docker run -it -e umserver=<um_IP>:<port> my-java-publish
```
An example event was send to the channel. You should see the following information printed out in your other terminal listening for events on this channel:

```
Event data : {"component":"no2","region-id":"Stuttgart","url":"https://hhiserver/realtime/stuttgart"}
Published on: Fri Oct 25 11:11:49 UTC 2019
Source: hhi
Category: realtime
```
