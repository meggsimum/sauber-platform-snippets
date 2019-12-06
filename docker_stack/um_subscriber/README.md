# UM Subscriber TODO

UM Subscriber expects UM Server's IP and port as umport='server:port' string. 

The IP of the UM Server cannot be predicted with docker stack deploy (see https://github.com/moby/moby/issues/31860).

Right now, the docker compose file has to be edited after deployment to the correct UM Server IP.

SubscriberEdited expects 2 envs: umserver and umport, then concats both strings. 

However, it still does not resolve the UM Server's container name to its IP.