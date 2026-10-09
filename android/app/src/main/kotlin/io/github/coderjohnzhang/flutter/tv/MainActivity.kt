package io.github.coderjohnzhang.flutter.tv

import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.Uri
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

/**
 * Host side of the `tv_launcher/platform` channel.
 *
 * The launcher reads logical targets, never platform names, so this side is the
 * only one that knows how Android resolves a target. A Linux TV build implements
 * the same channel against its own framework, which is why the Dart side needs no
 * platform-specific code at all.
 *
 * Every method degrades to a safe answer when it cannot do what was asked, so the
 * launcher keeps running on a platform that implements only part of the channel.
 */
class MainActivity : FlutterActivity() {

    private companion object {
        const val TAG = "TvLauncher"
        const val CHANNEL = "tv_launcher/platform"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "launchApp" -> {
                        launchApp(call.argument("action"), call.argument("extra"))
                        result.success(null)
                    }

                    "launchTarget" -> result.success(launchTarget(call.arguments))

                    "isNetworkAvailable" -> result.success(isNetworkAvailable())

                    "getCurrentLanguageCode" ->
                        result.success(Locale.getDefault().language)

                    "storageDirectory" -> result.success(storageDirectory())

                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Starts [action], first as an application id and then as an intent action.
     * A target that cannot be resolved is logged and ignored.
     */
    private fun launchApp(action: String?, extra: String?) {
        if (action.isNullOrEmpty()) {
            Log.w(TAG, "launchApp called without an action")
            return
        }
        val intent = resolveAction(action)
        if (intent == null) {
            logUnresolved(action)
            return
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (!extra.isNullOrEmpty()) {
            intent.putExtra(Intent.EXTRA_TEXT, extra)
        }
        startActivity(intent)
    }

    /**
     * Opens the target a layout tile describes.
     *
     * The launcher does not interpret a target, so whatever the layout service
     * filled in arrives here and is resolved in order of decreasing ambiguity: an
     * explicit component is exact, a URI is the platform's own contract, and a
     * logical action name is a name the platform has to guess at.
     *
     * Returns whether anything was started, so the caller can fall back.
     */
    private fun launchTarget(arguments: Any?): Boolean {
        val target = arguments as? Map<*, *> ?: return false

        val packageName = target["package_name"] as? String
        val activityName = target["activity_name"] as? String
        val uri = target["uri"] as? String
        val action = target["action"] as? String

        val intent = when {
            !packageName.isNullOrEmpty() && !activityName.isNullOrEmpty() ->
                Intent().setClassName(packageName, activityName)

            !packageName.isNullOrEmpty() ->
                packageManager.getLaunchIntentForPackage(packageName)

            !uri.isNullOrEmpty() -> Intent(Intent.ACTION_VIEW, Uri.parse(uri))

            !action.isNullOrEmpty() -> resolveAction(action)

            else -> null
        }

        if (intent == null) {
            logUnresolved(arguments.toString())
            return false
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
        return true
    }

    /**
     * Tries [action] as an application id, then as an intent action.
     *
     * A remote names its targets, not Android, so both readings are attempted
     * before giving up.
     */
    private fun resolveAction(action: String): Intent? =
        packageManager.getLaunchIntentForPackage(action)
            ?: Intent(action).takeIf { it.resolveActivity(packageManager) != null }

    private fun logUnresolved(target: String) {
        Log.w(TAG, "no activity found for '$target'")
    }

    /**
     * Where the launcher may keep its own files.
     *
     * The app's private directory: it survives a restart and no other app can
     * read it, which is what a record of what the viewer watched needs.
     */
    private fun storageDirectory(): String = filesDir.absolutePath

    private fun isNetworkAvailable(): Boolean {
        val manager = getSystemService(CONNECTIVITY_SERVICE) as? ConnectivityManager
            ?: return false
        val active = manager.activeNetwork ?: return false
        val capabilities = manager.getNetworkCapabilities(active) ?: return false
        return capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
    }
}
