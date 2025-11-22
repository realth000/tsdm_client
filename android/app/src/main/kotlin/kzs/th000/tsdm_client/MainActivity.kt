package kzs.th000.tsdm_client

import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class MainActivity: FlutterActivity() {
    companion object {
        const val MAIN_CHANNEL = "kzs.th000.tsdm_client/mainChannel"
        const val EXIT_APP = "exitApp"

        const val HTTP_CHANNEL = "kzs.th000.tsdm_client/httpChannel"
        const val HTTP_GET = "get"
        const val HTTP_POST_FORM = "postForm"
        const val HTTP_POST_MULTIPART = "postMultipart"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MAIN_CHANNEL)
            .setMethodCallHandler{ call, result -> handleMainChannelCall(call, result) }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HTTP_CHANNEL)
            .setMethodCallHandler{ call, result -> handleHttpChannelCall(call, result) }
    }

    private fun handleMainChannelCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == EXIT_APP) {
            moveTaskToBack(true)
            result.success(true)
        } else {
            result.notImplemented()
        }
    }

    private fun handleHttpChannelCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            HTTP_GET -> {
                val url = call.argument<String>("url")!!
                val headers = call.argument<HashMap<String, String>>("headers")!!
                CoroutineScope(Dispatchers.IO + SupervisorJob()).launch {
                    try {
                        val resp = HttpClient.get(url, headers)
                        val statusCode = resp.code
                        val headers = HashMap(resp.headers.toMultimap())
                        val body = resp.body.bytes()
                        val isRedirect = resp.isRedirect
                        result.success(buildResponse(statusCode, headers, body, isRedirect))
                    } catch (e: Exception) {
                        Log.e("KT_HTTP_ERROR", "failed to get: ${e.message ?: "unknown error"}")
                        result.error("KT_HTTP_ERROR", "failed to perform http GET",e.message ?: "unknown error")
                    }
                }
            }
            HTTP_POST_FORM -> {
                val url = call.argument<String>("url")!!
                val headers = call.argument<HashMap<String, String>>("headers")!!
                val body = call.argument<HashMap<String, String>>("body")!!
                CoroutineScope(Dispatchers.IO + SupervisorJob()).launch {
                    try {
                        val resp = HttpClient.postForm(url, headers, body)
                        val statusCode = resp.code
                        val headers = HashMap(resp.headers.toMultimap())
                        val body = resp.body.bytes()
                        val isRedirect = resp.isRedirect
                        result.success(buildResponse(statusCode, headers, body, isRedirect))
                    } catch (e: Exception) {
                        Log.e("KT_HTTP_ERROR", "failed to post form: ${e.message ?: "unknown error"}")
                        result.error("KT_HTTP_ERROR", "failed to perform http POST form",e.message ?: "unknown error")
                    }
                }
            }
            HTTP_POST_MULTIPART -> {
                val url = call.argument<String>("url")!!
                val headers = call.argument<HashMap<String, String>>("headers")!!
                val body = call.argument<HashMap<String, String>>("body")!!
                CoroutineScope(Dispatchers.IO + SupervisorJob()).launch {
                    try {
                        val resp = HttpClient.postMultipart(url, headers, body)
                        val statusCode = resp.code
                        val headers = HashMap(resp.headers.toMultimap())
                        val body = resp.body.bytes()
                        val isRedirect = resp.isRedirect
                        result.success(buildResponse(statusCode, headers, body, isRedirect))
                    } catch (e: Exception) {
                        Log.e("KT_HTTP_ERROR", "failed to post multipart: ${e.message ?: "unknown error"}")
                        result.error("KT_HTTP_ERROR", "failed to perform http POST multipart",e.message ?: "unknown error")
                    }
                }

            }
            else -> {
                result.notImplemented()
            }
        }
    }
}
