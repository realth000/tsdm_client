package kzs.th000.tsdm_client

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    companion object {
        const val MAIN_CHANNEL = "kzs.th000.tsdm_client/mainChannel"
        const val EXIT_APP = "exitApp"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MAIN_CHANNEL)
            .setMethodCallHandler{ call, result -> handleMainChannelCall(call, result) }
    }

    private fun handleMainChannelCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == EXIT_APP) {
            moveTaskToBack(true)
            result.success(true)
        } else {
            result.notImplemented()
        }
    }
}
