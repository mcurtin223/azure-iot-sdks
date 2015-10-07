# node-e2e-tests

This node.js script generates a `Dockerfile` that can be used to build a docker image that is configured with all the right environment variables that the node integration test scripts expect. Here's the usage information for the script:

```
Usage: node app.js
		-c [iot hub connection string]
		-e [event hub compatible endpoint]
		-p [partition count]
		-d [device id]
		-k [device key]
		-s [shared access signature]

Options:
  -c, --connection-string  [required]
  -e, --event-hub-endpoint  [required]
  -p, --partition-count  [required]
  -d, --device-id  [required]
  -k, --device-key  [required]
  -s, --shared-access-signature  [required]
  -g, --consumer-group  [string] [default: "$Default"]
```

Once you've run the script, it'll generate a file called **`dockerfile-node-e2etests`**. You can use this file to build a docker image. From the root of the repo for example, you'd run the following command to build the image:

```
docker build -t my/iotnode -f tools/docker/node-e2e-tests/dockerfile-node-e2etests .
```

Once it's done you should have an image called *my/iotnode* which you can now use to run your Node integration tests.