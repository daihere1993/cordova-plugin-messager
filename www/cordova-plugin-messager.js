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