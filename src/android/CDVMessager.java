package daihere.cordova.plugin;

import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.CallbackContext;

import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.json.JSONException;
import org.json.JSONObject;

import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;

import java.util.HashMap;
import java.util.Map;


public class Messager extends CordovaPlugin {
    protected MqttClient client;

    protected void subscribe(CordovaArgs args, final CallbackContext callbackContext) {
        String hostHeader = "tcp://";
        String topic = "";
        String clientId = "";
        String host = "";
        String username = "";
        String password = "";
        final Map<String, Object> callbackContextMap = new HashMap<String, Object>();
        final JSONObject params;
        try {
            params = args.getJSONObject(0);
            topic = params.getString("topic");
            clientId = params.getString("clientId");
            host = hostHeader.concat(params.getString("host"));
            username = params.getString("username");
            password = params.getString("password");
            callbackContextMap.put(topic, callbackContext);
        } catch (JSONException e) {
            callbackContext.error("参数格式错误");
        }

        try {
            if (client == null) {
                client = new MqttClient(host, clientId, new MemoryPersistence());
                MqttConnectOptions options = new MqttConnectOptions();
                options.setUserName(username);
                options.setPassword(password.toCharArray());
                options.setCleanSession(true);
                options.setConnectionTimeout(10);
                options.setKeepAliveInterval(20);
                client.connect(options);
            } else if (client.isConnected()) {
                client.setCallback(new MqttCallback() {
                    @Override
                    public void connectionLost(Throwable cause) {
                        callbackContext.error("连接失败");
                    }

                    @Override
                    public void messageArrived(String s, MqttMessage mqttMessage) throws Exception {
                        CallbackContext callbackContext2 = (CallbackContext)callbackContextMap.get(s);
                        String msg = new String(mqttMessage.getPayload(), "UTF-8");
                        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, msg);
                        pluginResult.setKeepCallback(true);

                        callbackContext2.sendPluginResult(pluginResult);
                    }

                    @Override
                    public void deliveryComplete(IMqttDeliveryToken token) {
                        System.out.println("deliveryComplete-------" + token.isComplete());
                    }
                });
                client.subscribe(topic, 1);
            } else {
                callbackContext.error("未连接上消息服务器");
            }
        } catch (MqttException e) {
            e.printStackTrace();
        }

    }

    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("subscribeTopic")) {
            subscribe(args, callbackContext);
            return true;
        }

        return false;
    }
}
