# cordova-plugin-messager

This is an information tranfer cordova plugin base on MQTT.

# Feature

- Subscribe topic

# Example

wait

# Install 

```Javascript
cordova plugin add cordova-plugin-messager or ionic plugin add cordova-plugin-messager
```

# Usage

## Subscribe topic

```Javascript
var params = {
  clientId: 'test', // just a unique string
  host: 'test.mosquitto.org:8883',
  username: 'admin',
  password: 'password',
  topic: 'login'
}
cordova.plugins.messager.subscribe(params, function (msg) {
  alert(msg);
}, function (error)  {
  console.log(error);
});
```

# LICENSE

[MIT LICENSE](http://opensource.org/licenses/MIT)

