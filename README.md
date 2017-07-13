# cordova-plugin-messager

This is an information tranfer cordova plugin base on MQTT.

# Feature

- Subscribe topic

# Install 

```Javascript
cordova plugin add cordova-plugin-messager or ionic plugin add cordova-plugin-messager
```

# Usage

## Subscribe topic

```Javascript
var params = {
  clientId: 'test', // just a unique string
  host: 'test.mosquitto.org:1883',
  username: 'admin', // if you hava
  password: 'password', // if you hava
  topic: 'daihere/test'
}
cordova.plugins.messager.subscribe(params, function (msg) {
  alert(msg);
}, function (error)  {
  console.log(error);
});
```

# Example

There is a test host ```test.mosquitto.org:1883```. 

First, you should install ```mosquitto```(In mac: ```brew install mosquitto```, another sys pleace Google)

Then, launch you app and execute ```mosquitto_pub -h test.mosquitto.org -p 1883 -t daihere/test -m tes3```  in you terminal that will publish a message ```test3```, ```daihere/test``` is you subscribe topic.

# LICENSE

[MIT LICENSE](http://opensource.org/licenses/MIT)

