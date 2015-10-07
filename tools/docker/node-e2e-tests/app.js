'use strict';

var fs = require('fs');
var util = require('util');
var _ = require('lodash');
var argv = require('yargs')
	.usage('Usage: node app.js -c [iot hub connection string] -e [event hub compatible endpoint] -p [partition count] -d [device id] -k [device key]')
	.demand(['c', 'e', 'p', 'd', 'k', 's'])
	.alias('c', 'connection-string')
	.alias('e', 'event-hub-endpoint')
	.alias('s', 'shared-access-signature')
	.option('p', {
		alias: 'partition-count',
		demand: true
	})
	.alias('d', 'device-id')
	.alias('k', 'device-key')
	.option('g', {
		alias: 'consumer-group',
		demand: false,
		default: "$Default",
		type: 'string'
	})
	.argv;

function main() {
	// we need the following passed in as params:
	//	[1] IoT Hub connection string
	//	[2] Event Hub compatible endpoint
	//	[3] Partition count
	//	[4] IoT Hub device ID
	//	[5] IoT Hub device key
	
	// extract the params we need
	var components = parseConnectionString(argv.connectionString);
	var hubName = components.HostName.split('.')[0];
	var hubSuffix = components.HostName.substr(hubName.length + 1);
	
	// fill up the environment variables map
	var envMap = {
		"IOTHUB_CONNECTION_STRING": argv.connectionString,
		"IOTHUB_NAME": hubName,
		"IOTHUB_EVENTHUB_LISTEN_NAME": hubName,
		"IOTHUB_SUFFIX": hubSuffix,
		"IOTHUB_POLICY_NAME": components.SharedAccessKeyName,
		"IOTHUB_POLICY_KEY": components.SharedAccessKey,
		"IOTHUB_EVENTHUB_ACCESS_KEY": components.SharedAccessKey,
		"IOTHUB_EVENTHUB_CONNECTION_STRING": util.format('%s;SharedAccessKeyName=%s;SharedAccessKey=%s',
			argv.eventHubEndpoint, components.SharedAccessKeyName, components.SharedAccessKey),
		"IOTHUB_EVENTHUB_CONSUMER_GROUP": argv.consumerGroup,
		"IOTHUB_PARTITION_COUNT": parseInt(argv.partitionCount),
		"IOTHUB_DEVICE_ID": argv.deviceId,
		"IOTHUB_DEVICE_KEY": argv.deviceKey,
		"IOTHUB_SHARED_ACCESS_SIGNATURE": argv.sharedAccessSignature
	};
	
	// write docker file
	writeDockerfile(envMap);
}

function parseConnectionString(connectionString) {
	// split on ';'
	var tokens = connectionString.split(';');
	var components = {};
	tokens.forEach(function(token) {
		var kv = token.split('=');
		components[kv[0]] = kv[1];
	});
	
	return components;
}

function writeDockerfile(envMap) {
	// glob dockerfile-node-e2etests-template
	fs.readFile('dockerfile-node-e2etests-template', 'utf-8', function(err, data) {
		if(err) {
			console.err('Reading dockerfile-node-e2etests-template failed - ', err);
			return;
		}
		
		// transform env map into env var declarations as docker expects
		var lines = _.transform(envMap, function(result, val, key) {
			result.push(util.format("ENV %s %s", key, val));
		}, []);
		
		// build the final string
		var env = lines.join('\n');
		
		// write the env vars into the file
		data = data.replace('<<ENV_VARS>>', env);
		fs.writeFileSync('dockerfile-node-e2etests', data);
		
		console.log('Generated docker file here: dockerfile-node-e2etests');
	});
}

main();
