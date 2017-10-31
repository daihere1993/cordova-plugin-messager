# cordova-plugin-messager

This is an information tranfer cordova plugin base on MQTT.

# Feature

- Subscribe topic

# Install 

```Javascript
cordova plugin add cordova-plugin-messager or ionic plugin add cordova-plugin-messager
```

# Usage

```Javascript
var messager = new CDVMessager({
  clientId: 'clientId', // required
  host: 'Your server host', // required
  port: 'Your server port', // required
  username: 'Your server username', // optional
  password: 'Your server password' // optional
});

// subscribe topic
var topic = 'test/topic';
messager.subscribe(topic);
// listen the 'receivedMqttMsg_<topic>' event
messager.on('receivedMqttMsg_' + topic, function (msg) {
  alert(msg);
});
// cancelSubscribe topic
messager.cancelSubscribe(topic);
```

# Example

## init and subscribe topice

```Javascript
var messager = new CDVMessager({
  clientId: 'test',
  host: 'test.mosquitto.org',
  port: '1883'
});

var topic = 'nt/test1';
messager.subscribe(topic);
messager.on('receivedMqttMsg_' + topic, function (msg) {
  alert(msg);
});
```

## publish message in terminal

1. First, you need install ```mosquitto```.
2. Launch you app.
3. Execute ```mosquitto_pub -h test.mosquitto.org -p 1883 -t nt/test1 -m tes1``` in the terminal, that will publish a message.
4. Will alert a message ```test1```.

# LICENSE

[MIT LICENSE](http://opensource.org/licenses/MIT)

