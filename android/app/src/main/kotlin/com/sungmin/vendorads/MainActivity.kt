package com.sungmin.vendorads

import android.content.pm.PackageManager
import android.content.pm.Signature
import android.util.Base64
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "kakao_key_hash"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getKeyHash" -> {
                    val keyHash = getKeyHash()
                    if (keyHash != null) {
                        result.success(keyHash)
                    } else {
                        result.error("UNAVAILABLE", "키해시를 가져올 수 없습니다.", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getKeyHash(): String? {
        try {
            val packageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
            val signatures = packageInfo.signatures
            if (signatures != null && signatures.isNotEmpty()) {
                for (signature: Signature in signatures) {
                    val md = MessageDigest.getInstance("SHA")
                    md.update(signature.toByteArray())
                    val keyHash = Base64.encodeToString(md.digest(), Base64.DEFAULT)
                    Log.d("KeyHash", "키해시: $keyHash")
                    return keyHash.trim()
                }
            }
        } catch (e: PackageManager.NameNotFoundException) {
            Log.e("KeyHash", "패키지를 찾을 수 없습니다: ${e.message}")
        } catch (e: NoSuchAlgorithmException) {
            Log.e("KeyHash", "SHA 알고리즘을 찾을 수 없습니다: ${e.message}")
        }
        return null
    }
}