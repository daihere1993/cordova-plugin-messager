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

/**
 * Created by daihere on 15/08/2017.
 */

public class CDVMessager extends CordovaPlugin {

    private MqttClient client;
    private CallbackContext currentCallbackContext;

    private void init(CordovaArgs args, final  CallbackContext callbackContext) {
        currentCallbackContext = callbackContext;
        String hostHeader = "tcp://",
                clientId = "",
                host = "",
                port = "",
                username = "",
                password = "";
        final JSONObject params;
        try {
            params = args.getJSONObject(0);
            if (!params.isNull("clientId")) {
                clientId = params.getString("clientId");
            }
            if (!params.isNull("port")) {
                port = params.getString("port");
            }
            host = hostHeader + params.getString("host") + ":" + port;
            if (!params.isNull("username")) {
                username = params.getString("username");
            }
            if (!params.isNull("password")) {
                password = params.getString("password");
            }
        } catch (JSONException e) {
            callbackContext.error("Parameter error!");
        }

        try {
            client = new MqttClient(host, clientId, new MemoryPersistence());
            MqttConnectOptions options = new MqttConnectOptions();
            if (!username.trim().equals("")) {
                options.setUserName(username);
            }
            options.setPassword(password.toCharArray());
            options.setCleanSession(true);
            options.setConnectionTimeout(1);
            options.setKeepAliveInterval(20);

            client.setCallback(new MqttCallback() {
                @Override
                public void connectionLost(Throwable cause) {
                    // 连接丢失后，一般在这里面进行重连
                    System.out.println("connectionLost----------");
                }

                @Override
                public void messageArrived(final String s, MqttMessage mqttMessage) throws Exception {
                    final String msg = new String(mqttMessage.getPayload(), "UTF-8");
                    HashMap<String, String> result = new HashMap<String, String>(){{
                        put("type", s);
                        put("value", msg);
                    }};
                    successWithCallbackContext(currentCallbackContext, new JSONObject(result), true);
                }

                @Override
                public void deliveryComplete(IMqttDeliveryToken token) {
                    //publish后会执行到这里
                    System.out.println("deliveryComplete-------" + token.isComplete());
                }
            });
            connect(options);
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    private void subscribe(CordovaArgs args, CallbackContext callbackContext) {
        String topic = "";
        try {
            topic = args.getString(0);
        } catch (JSONException e) {
            currentCallbackContext.error("Parameter error!");
        }

        if (client != null) {
            try {
                client.subscribe(topic, 1);
                System.out.println("Subscribe topic: " + topic + " success!");
            } catch (MqttException e) {
                e.printStackTrace();
            }
        }
    }

    private void successWithCallbackContext(CallbackContext callbackContext, String withMessage, Boolean keepCallback ) {
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, withMessage);
        pluginResult.setKeepCallback(keepCallback);
        callbackContext.sendPluginResult(pluginResult);
    }

    private void successWithCallbackContext(CallbackContext callbackContext, JSONObject withObject, Boolean keepCallback) {
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, withObject);
        pluginResult.setKeepCallback(keepCallback);
        callbackContext.sendPluginResult(pluginResult);
    }

    @Override
    public boolean execute(String action, final CordovaArgs args, final CallbackContext callbackContext) throws JSONException {
        if (action.equals("subscribe")) {
            subscribe(args, callbackContext);
            return true;
        } else if (action.equals("init")) {
            init(args, callbackContext);
            return true;
        }

        return false;
    }

    private void connect(final  MqttConnectOptions options) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    client.connect(options);
                    System.out.println("Connect mqtt server success!");
                    HashMap<String, String> result = new HashMap<String, String>(){{
                        put("type", "connectedMqttServer");
                        put("value", "");
                    }};
                    successWithCallbackContext(currentCallbackContext, new JSONObject(result), true);
                } catch (Exception e) {
                    currentCallbackContext.error("Fail to connect mqtt server!");
                }
            }
        }).start();
    }
}