var exec = require('cordova/exec');

module.exports = {
  // receive message
  subscribe: function (param, successFn, failureFn) {
    exec(successFn, failureFn, 'Messager', 'subscribe', [param]);
    return function (successCallback, failCallback) {
      exec(successCallback, failCallback, 'Messager', 'disconnect', []);
    };
  },
  // publish message
  publish: function (param, successFn, failureFn) {
    exec(successFn, failureFn, 'Messager', 'publish', [param]);
    return function (successCallback, failCallback) {
      exec(successCallback, failCallback, 'Messager', 'disconnect', []);
    };
  }
}