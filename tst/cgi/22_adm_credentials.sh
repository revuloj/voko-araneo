#!/bin/bash

stack=araneujotesto
araneo_id=$(docker ps --filter name=${stack}_araneo -q) 

cgi_user=araneo
cgi_pwd=$(docker exec ${araneo_id} cat /run/secrets/voko-araneo.cgi_password | head -n 1)

b64=$(echo -n "${cgi_user}:${cgi_pwd}" | base64)
echo -n "$b64"