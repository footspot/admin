package com.example.fs_sa

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.PersistableBundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app/secure_clipboard")
            .setMethodCallHandler { call, result ->
                if (call.method == "copySensitive") {
                    val text = call.argument<String>("text") ?: ""
                    val cm = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                    val clip = ClipData.newPlainText("secret", text)
                    // * EXTRA_IS_SENSITIVE hides the value in the Android 13+ clipboard preview.
                    clip.description.extras = PersistableBundle().apply {
                        putBoolean("android.content.extra.IS_SENSITIVE", true)
                    }
                    cm.setPrimaryClip(clip)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
