var exec = require('cordova/exec');

module.exports = {
  // receive message
  subscribe: function (param, successFn, failureFn) {
    exec(successFn, failureFn, 'subscribe', [param]);
  },
  // publish message
  publish: function (param, successFn, failureFn) {
    exec(successFn, failureFn, 'publish', [param]);
  }
}