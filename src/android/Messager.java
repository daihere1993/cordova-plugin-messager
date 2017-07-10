package daihere.cordova.plugin;

import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.CallbackContext;

import org.eclipse.paho.client.mqttv3.IMqttMessageListener;
import org.eclipse.paho.client.mqttv3.util.Strings;
import org.json.JSONException;
import org.json.JSONObject;

import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;


public class Messager extends CordovaPlugin {
    protected void subscribe(CordovaArgs args, final CallbackContext callbackContext) {
        String topic = "my/topic";
        String clientId = "TEXT-CLIENT-ID";
        String host = "test.mosquitto.org";
        MemoryPersistence persistence = new MemoryPersistence();

        try {
            MqttClient mqttAndroidClient = new MqttClient(host, clientId, persistence);
            MqttConnectOptions connOpts = new MqttConnectOptions();
            mqttAndroidClient.connect(connOpts);
            mqttAndroidClient.subscribe(topic, new IMqttMessageListener() {
                @Override
                public void messageArrived(String s, MqttMessage mqttMessage) throws Exception {
                    System.out.println(s);
                }
            });
        } catch (MqttException me) {
            System.out.println("reason "+me.getReasonCode());
            System.out.println("msg "+me.getMessage());
            System.out.println("loc "+me.getLocalizedMessage());
            System.out.println("cause "+me.getCause());
            System.out.println("excep "+me);
            me.printStackTrace();
        }
    }

    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("subscribe")) {
            subscribe(args, callbackContext);
            return true;
        }

        return false;
    }
}
