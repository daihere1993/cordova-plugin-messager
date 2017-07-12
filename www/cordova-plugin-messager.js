var exec = require('cordova/exec');

module.exports = {
  // connect server
  connect: function (param, successFn, failureFn) {
    exec(successFn, failureFn, 'Messager', 'connect', [param]);
  },
  // receive message
  subscribe: function (param, successFn, failureFn) {
    exec(successFn, failureFn, 'Messager', 'subscribe', [param]);
  },
  // publish message
  publish: function (param, successFn, failureFn) {
    exec(successFn, failureFn, 'Messager', 'publish', [param]);
  }
}