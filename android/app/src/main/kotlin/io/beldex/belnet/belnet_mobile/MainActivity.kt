package io.beldex.beldex_browser
import android.app.SearchManager
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.speech.RecognizerResultsIntent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


import android.util.Log


import android.content.pm.PackageManager
import android.content.ActivityNotFoundException

import java.net.URLDecoder
import java.nio.charset.StandardCharsets

class MainActivity: FlutterActivity() {
    private var url: String? = null
    private val CHANNEL = "com.beldex.beldex_browser.intent_data"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("KOTLIN oncreate ", intent.toUri(0));
        handleIntentData(intent)  // Process the intent data
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d("KOTLIN onNewIntent", intent.toUri(0));
        handleIntentData(intent)  // Handle intent if the app is already running
    }

    private fun handleIntentData(intent: Intent?) {
        intent?.let {
            val action = intent.action
            if (Intent.ACTION_VIEW == action) {
                val data: Uri? = intent.data
                Log.d("KOTLIN in ACTION_VIEW", data.toString());
                if (data != null) {
                    url = data.toString()
                    Log.d("KOTLIN is holding data", url.toString());
                }
            } 
            else if (Intent.ACTION_SEARCH == action || MediaStore.INTENT_ACTION_MEDIA_SEARCH == action
                    || Intent.ACTION_WEB_SEARCH == action) {
                url = intent.getStringExtra(SearchManager.QUERY)
                Log.d("KOTLIN else statement", url.toString());
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                if (call.method == "getIntentData") {
                    Log.d("KOTLIN","KOTLIN IN METHOD CHANNEL 0" + url.toString());
                    result.success(url)
                   // url = null  // Clear the URL after passing it to Flutter
                    Log.d("KOTLIN","KOTLIN IN METHOD CHANNEL 1" + url.toString());
                }else if (call.method == "handleIntentUrl") {
                val url = call.arguments<String?>() // Allow nullable type
                Log.d("KOTLIN","KOTLIN IN METHOD CHANNEL 4");
                url?.let {
                    handleIntentUrl(it) // Only proceed if URL is not null
                }
                Log.d("KOTLIN","KOTLIN IN METHOD CHANNEL 5");
                result.success(null)
            }
            }

        // Handle the intent data once the Flutter engine is ready
        // This ensures the data is passed even if the app is launched initially via an intent
        if (url != null) {
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("getIntentData", url)
        }
    }
 private fun handleIntentUrl(url: String) {

   try {
            // Parse the intent:// URL
            val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
           // val newUrl = url.replace("https://", "intent://")
            Log.d("KOTLIN","KOTLIN IN HANDLE METHOD 1" + url.toString());
            // Check if the app exists (i.e., the app to handle the intent is installed)
            val packageManager = packageManager
            val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        val fallbackUrlPattern = "S\\.browser_fallback_url=([^;]+)".toRegex()
           val matchResult = fallbackUrlPattern.find(url)
           val fallbackUrl1 = matchResult?.groups?.get(1)?.value

       
        val pp2 = extractPackageId(url)
     if(resolveInfo != null){
         if(fallbackUrl1 != null){
           val pp1 = extractPackageIdFromPlayStoreLink(fallbackUrl1)
            
           if(pp1 != null && isAppInstalled(pp1)){
            startActivity(intent)
           }else if((pp1 == null) && pp2 != null && isAppInstalled(pp2)){
            startActivity(intent)
           }
           else if(pp1 != null ){
             val urlFallback = Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=$pp1"))
                     startActivity(urlFallback)
           }
            Log.d("KOTLIN","FALLBACK URL LINK @@ 6777777---" + pp1);

         }

        else if(fallbackUrl1 == null ){
            if(pp2 != null && isAppInstalled(pp2)){
                startActivity(intent)
            }else if(pp2 == null){
             val ps = extractPackageIdFromPlayStoreLink(url)
             if(ps != null && isAppInstalled(ps)){
                startActivity(intent)
             }else{
              val urlFallback = Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=$ps"))
                     startActivity(urlFallback)
             }
            }else{
              startActivity(intent)
            }
        //     pp2 = 
        //      val isAvail = isAppInstalled(pp1)
        //    if(isAvail){
             
        //    }
         }
        //  if(pp2 != null){
        //    Log.d("KOTLIN","FALLBACK URL LINK @@ 6---" + pp2);
        //  }
          Log.d("KOTLIN","FALLBACK URL LINK @@ 1234566---" + "pp2" + pp2);
         // startActivity(intent)
     }
     else{
         
           
          // Log.d("KOTLIN","FALLBACK URL LINK MATCH---" + matchResult?.groups?.get(1)?.value);
          if(fallbackUrl1 != null){
            val eAppId = extractPackageIdFromPlayStoreLink(fallbackUrl1)
            Log.d("KOTLIN","FALLBACK URL LINK @@ 1---" + eAppId.toString());
            
            if(eAppId != null){
                 val isAppAvail = isAppInstalled(eAppId)
                 if(isAppAvail){
                     Log.d("KOTLIN","FALLBACK URL LINK @@ 22---" + isAppAvail.toString());
                    startActivity(intent)
                 }else{

                      val pId = extractPackageId(url)
                    //   Log.d("KOTLIN","FALLBACK URL LINK @@ 3344555---" + pId.toString());
                     if(pId != null){
                        val isVal = isAppInstalled(pId)
                         if(isVal){
                            Log.d("KOTLIN","FALLBACK URL LINK @@ 3344444---" + isVal.toString());
                    //         startActivity(intent)
                        }
                     }
                     else{
                       Log.d("KOTLIN","FALLBACK URL LINK @@ 3334---" + isAppAvail.toString());
                    val urlFallback = Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=$eAppId"))
                     startActivity(urlFallback)
                    }
                      
                 }
            }
          }else{
            val eAppId = extractPackageIdFromPlayStoreLink(url)
            if(eAppId != null && fallbackUrl1 == null){
                val isAppAvail = isAppInstalled(eAppId)
                 if(isAppAvail){
                     Log.d("KOTLIN","FALLBACK URL LINK @@ 22---" + isAppAvail.toString());
                    startActivity(intent)
                 }else{
                       Log.d("KOTLIN","FALLBACK URL LINK @@ 33---" + isAppAvail.toString());
                    val urlFallback = Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=$eAppId"))
                     startActivity(urlFallback)
                 }
            }else{

            }
          }
     }
            
        } catch (e: ActivityNotFoundException) {
            e.printStackTrace()
        } catch (e: Exception) {
            e.printStackTrace()
        }

    }


    private fun extractPackageIdFromPlayStoreLink(link: String): String? {
        // Decode the URL to handle encoded characters
        val decodedLink = URLDecoder.decode(link, StandardCharsets.UTF_8.toString())
        val uri = Uri.parse(decodedLink)
        return uri.getQueryParameter("id")
    }

     private fun isAppInstalled(packageId: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageId, PackageManager.GET_ACTIVITIES)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

      private fun extractPackageId(link: String): String? {
        val regex = Regex("package=([^;]+)")
        val matchResult = regex.find(link)
        return matchResult?.groups?.get(1)?.value
    }
}

