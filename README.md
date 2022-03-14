# concourse-arm-worker

```
./build.sh
```

Will build the concourse resources in the resource-types directory, gzip them and put them in the
right path. Will then build the main docker file which builds concourse.

While this does not cross-compile, it can be run on arm machines with docker.

