var exec = require('cordova/exec');

module.exports = {
  // receive message
  subscribe: function (param, successFn, failureFn) {
    exec(successFn, failureFn, 'Messager', 'subscribe', [param]);
  },
  // publish message
  publish: function (param, successFn, failureFn) {
    exec(successFn, failureFn, 'Messager', 'publish', [param]);
  }
}

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