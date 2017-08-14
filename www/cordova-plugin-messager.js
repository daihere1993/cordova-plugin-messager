var exec = require('cordova/exec');

function _creatClass (Constructor, protoProps) {
  function defineProperties (target, props) {
    for (var i = 0; i < props.length; i++) {
      var descriptor = props[i];
      Object.defineProperty(target, descriptor.key, descriptor);
    }
  }

  if (protoProps) {
    defineProperties(Constructor.prototype, protoProps);
  }
}

var CDVMessager = (function CDVMessager () {

  function CDVMessager (options) {
    var _this = this;
    this.handlers = {};
    var successCallback = function (result) {
      if (!result || !result.type || !_this.handlers[result.type]) {
        return;
      }
      _this.handlers[result.type](result.value);
    }
    
    var failCallback = function (error) {
      if (!_this.handlers.error) {
        return;
      }
      _this.handlers.error(error);
    }

    // 连接mqtt服务器，注册远程消息推送
    exec(successCallback, failCallback, 'CDVMessager', 'init', [options]);

    return this;
  }

  _creatClass(CDVMessager, [{
    key: 'subscribe',
    value: function (topic) {
      exec(null, null, 'CDVMessager', 'subscribe', [topic]);
    }
  }, {
    key: 'cancelSubscribe',
    value: function (topic, successCallback, failCallback) {
      exec(successCallback, failCallback, 'CDVMessager', 'cancelSubscribe', [topic]);
    }
  }, {
    key: 'on',
    value: function (type, callback) {
      this.handlers[type] = callback;
    }
    /*
    * type:
    *   receivedMqttMsg_topic
    *   receivedNotification
    *   registedNotification
    *   error
    */
  }]);

  return CDVMessager;
})();

module.exports = CDVMessager;