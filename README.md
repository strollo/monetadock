
# Installation

```bash
git clone https://github.com/strollo/monetadock
docker build monetadock -t monetadock
```

# Running with persistence

By design Docker container are not meant to be stateful, so all modifications on database
will not be persisted on next restart of container.

The easy solution is to instantiate a Docker container with a persistent data volume to
keep database data.

### Creating a volume
```bash 
docker volume create monetadb
``` 

### Instantiating container

```bash 
docker run -p 222:22 -p 443:8043 -p 8080:80 -v monetadb:/var/lib/mysql monetadock
``` 

For further details read:
- [A quick introduction to docker persistence](http://www.ethernetresearch.com/docker/docker-tutorial-persistent-storage-volumes-and-stateful-containers/)
- [The official Docker guide on Volumes](https://docs.docker.com/storage/volumes/)

# Connect

> Open the browers at: [http://localhost:8080/moneta/](http://localhost:8080/moneta/)
> Connect with admin/admin credentials... create your projects and users.

Done!