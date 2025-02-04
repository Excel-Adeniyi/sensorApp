package com.example.usb
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(){
    private val METHOD_CHANNEL_NAME = "com.example.usb/method"
    private val PRESSURE_CHANNEL_NAME = "com.example.usb/pressure"

    private var methodChannel: MethodChannel? = null
    private var pressureChannel: EventChannel? = null
    private  lateinit var  sensorManager: SensorManager
    private var pressureStreamHandler: StreamHandler? = null
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        setupChannels(this, flutterEngine.dartExecutor.binaryMessenger)
    }

     override fun onDestroy() {
        teardownChannels()
        super.onDestroy()
    }

    private fun setupChannels(context: Context, messenger: BinaryMessenger){
            sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
            methodChannel = MethodChannel(messenger, METHOD_CHANNEL_NAME)

            methodChannel!!.setMethodCallHandler{
                call, result ->
                if (call.method == "availableUsb"){
                   var accessoryList = sensorManager.getSensorList(Sensor.TYPE_PRESSURE)
                   if(accessoryList != null && accessoryList.isNotEmpty()){
                       result.success(true)
                   }else {
                       result.success(false)
                   }
                }else{
                    result.notImplemented()
                }
            }

            pressureChannel = EventChannel(messenger, PRESSURE_CHANNEL_NAME)
            pressureStreamHandler = StreamHandler(sensorManager!!, Sensor.TYPE_PRESSURE)
            pressureChannel!!.setStreamHandler(pressureStreamHandler)
    }

    private fun teardownChannels() {

        methodChannel!!.setMethodCallHandler(null)
        pressureChannel!!.setStreamHandler(null)
    }
}
