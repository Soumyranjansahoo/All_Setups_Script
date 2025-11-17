#!/bin/bash
sudo amazon-linux-extras enable corretto8
sudo yum install java-1.8.0-amazon-corretto -y
java -version
