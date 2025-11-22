package kzs.th000.tsdm_client

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.FormBody
import okhttp3.Headers
import okhttp3.MultipartBody
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import java.net.ProxySelector

object HttpClient {
    private val client by lazy {
        OkHttpClient.Builder().proxySelector(ProxySelector.getDefault()).build()
    }

    suspend fun get(url: String, headers: HashMap<String, String>): Response {
        val request = Request.Builder()
            .url(url)
            .headers(Headers.headersOf(*headers.toList().flatMap { listOf(it.first, it.second) }.toTypedArray()))
            .get()
            .build()

        return withContext(Dispatchers.IO) {
            try {
                client.newCall(request).execute()
            } catch (e: Exception) {
                throw e
            }
        }
    }

    suspend fun postForm(
        url: String,
        headers: HashMap<String, String>,
        body: HashMap<String, String>,
    ): Response {
        val formBody = FormBody.Builder().apply {
            body.forEach { (key, value) -> add(key, value) }
        }.build()

        val request = Request.Builder()
            .url(url)
            .headers(Headers.headersOf(*headers.toList().flatMap { listOf(it.first, it.second) }.toTypedArray()))
            .post(formBody)
            .build()

        return withContext(Dispatchers.IO) {
            try {
                client.newCall(request).execute()
            } catch (e: Exception) {
                throw e
            }
        }
    }

    suspend fun postMultipart(
        url: String,
        headers: Map<String, String> = emptyMap(),
        body: Map<String, String> = emptyMap(),
    ): Response {
        val multipartBody = MultipartBody.Builder()
            .setType(MultipartBody.FORM)
            .apply {
                body.forEach { (key, value) -> addFormDataPart(key, value) }
            }
            .build()

        val request = Request.Builder()
            .url(url)
            .headers(Headers.headersOf(*headers.toList().flatMap { listOf(it.first, it.second) }.toTypedArray()))
            .post(multipartBody)
            .build()

        return withContext(Dispatchers.IO) {
            try {
                client.newCall(request).execute()
            } catch (e: Exception) {
                throw e
            }
        }
    }
}

fun buildResponse(
    statusCode: Int,
    headers: HashMap<String, List<String>>,
    body: ByteArray,
    isRedirect: Boolean,
) : HashMap<String, Any>{
    return hashMapOf(
        Pair("statusCode", statusCode),
        Pair("headers", headers),
        Pair("body", body),
        Pair("isRedirect", isRedirect),
    )
}
