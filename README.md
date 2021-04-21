# cc-restproxy-observed

Setting up Confluent REST Proxy connected to Confluent Cloud, plus using the Metrics API and JMX to monitor usage.

This is a blend of the Observability demo from https://github.com/confluentinc/examples/tree/6.1.1-post/ccloud-observability 
and the cp-all-in-one setup https://github.com/confluentinc/cp-all-in-one/tree/6.1.1-post/cp-all-in-one-cloud

You'll need the Confluent Cloud CLI: https://docs.confluent.io/ccloud-cli/current/install.html

````
curl -L https://cnfl.io/ccloud-cli | sh -s 
export PATH=./bin:$PATH
````

To get started, login and then create a cloud API key (for access to the Metrics API):
````
ccloud login --save
./create_cloud_key.sh
````
and export these variables (as output by the script):
````
export METRICS_API_KEY=<<the key>>
export METRICS_API_SECRET=<<the secret>>
````

Pick a cloud cluster that you want to produce to, you'll need the internal id:
````
ccloud environment list  -o json
ccloud environment use <<your environment id>>
ccloud kafka cluster list -o json
export CLUSTER_ID=<<your cluster id>>
ccloud kafka cluster use $CLUSTER_ID
````

Now create a service account, you can set the name if you want (otherwise a default is used) and an API key for it to use on the cluster
````
export SERVICE_NAME=<<a service name>>
./create_service_account.sh
````
and again export the variables (as output by the script):
````
export API_KEY_SA=<<the key>>
export API_SECRET_SA=<<the secret>>
export SASL_JAAS_CONFIG==<<the config>>
export BOOTSTRAP_SERVERS=<<the url>>
````

You also need to supply a list of cloud clusters to monitor.
````
export CLOUD_CLUSTER=<<comma separated list of lkc-XXX>>
````

Now start the monitoring components and the REST proxy
````
docker-compose up -d
````

You can send data to the REST Proxy as follows:
````
curl -X POST localhost:8082/topics/rp_test_bin1 \
      -H "Content-Type: application/vnd.kafka.binary.v2+json" \
      -H "Accept: application/vnd.kafka.v2+json" \
      --data '{"records":[{"value":"S2Fma2E="}]}'
````
See https://docs.confluent.io/platform/current/tutorials/cp-demo/docs/on-prem.html#standalone-crest for more examples.