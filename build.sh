#/bin/bash 


mkdir ./tmp
cp /Users/tty/.ssh/id_rsa.pub ./tmp/id_rsa.pub


docker build -f containers/primary/docker/Dockerfile .
