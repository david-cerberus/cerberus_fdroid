package com.dsvdevelopment.cerberus

import android.app.assist.AssistStructure
import android.os.CancellationSignal
import android.service.autofill.AutofillService
import android.service.autofill.FillCallback
import android.service.autofill.FillRequest
import android.service.autofill.FillResponse
import android.service.autofill.SaveCallback
import android.service.autofill.SaveRequest
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import android.service.autofill.Dataset
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import android.view.View
import android.text.InputType

class CerberusAutofillService : AutofillService() {
    private val TAG = "CerberusAutofill"
    private val CHANNEL = "com.cerberus.autofill/channel"
    private var flutterEngine: FlutterEngine? = null

    override fun onCreate() {
        super.onCreate()
        flutterEngine = FlutterEngine(this)
        flutterEngine?.dartExecutor?.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        flutterEngine?.destroy()
        flutterEngine = null
    }

    override fun onFillRequest(
        request: FillRequest,
        cancellationSignal: CancellationSignal,
        callback: FillCallback
    ) {
        val structure: AssistStructure = request.fillContexts.last().structure
        val packageName = structure.activityComponent.packageName

        Log.d(TAG, "Solicitud de Autofill recibida para el paquete: $packageName")

        if (packageName == applicationContext.packageName) {
            callback.onSuccess(null)
            return
        }

        val fields = mutableMapOf<String, AssistStructure.ViewNode>()
        var extractedWebDomain: String? = null

        val windowNode = structure.getWindowNodeAt(0)
        if (windowNode != null) {
            extractedWebDomain = traverseStructure(windowNode.rootViewNode, fields)
        }

        val userNode = fields["username"]
        val passNode = fields["password"]

        if (userNode == null && passNode == null) {
            Log.d(TAG, "No se encontraron campos compatibles para autocompletar.")
            callback.onSuccess(null)
            return
        }

        val methodChannel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
        val arguments = mapOf(
            "packageName" to packageName,
            "webDomain" to (extractedWebDomain ?: "")
        )

        methodChannel.invokeMethod("getCredentialsForPackage", arguments, object : MethodChannel.Result {
            override fun success(result: Any?) {
                try {
                    val jsonResult = result as String
                    val credentialsArray = JSONArray(jsonResult)
                    
                    if (credentialsArray.length() == 0) {
                        callback.onSuccess(null)
                        return
                    }

                    Log.d(TAG, "Credenciales recibidas desde Flutter: $jsonResult")
                    
                    val responseBuilder = FillResponse.Builder()

                    for (i in 0 until credentialsArray.length()) {
                        val cred: JSONObject = credentialsArray.getJSONObject(i)
                        val title = cred.optString("title", "Cerberus")
                        val username = cred.optString("username", "")
                        val password = cred.optString("password", "")

                        val presentation = RemoteViews(packageName, R.layout.autofill_presentation)
                        presentation.setTextViewText(R.id.title, title)
                        presentation.setTextViewText(R.id.username, username)

                        val datasetBuilder = Dataset.Builder(presentation)

                        if (userNode != null && userNode.autofillId != null) {
                            datasetBuilder.setValue(userNode.autofillId!!, AutofillValue.forText(username))
                        }
                        if (passNode != null && passNode.autofillId != null) {
                            datasetBuilder.setValue(passNode.autofillId!!, AutofillValue.forText(password))
                        }

                        responseBuilder.addDataset(datasetBuilder.build())
                    }

                    callback.onSuccess(responseBuilder.build())

                } catch (e: Exception) {
                    Log.e(TAG, "Error procesando JSON de credenciales", e)
                    callback.onFailure(e.message)
                }
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e(TAG, "Error desde Flutter: $errorMessage")
                callback.onFailure(errorMessage)
            }

            override fun notImplemented() {
                Log.e(TAG, "Método no implementado en Flutter")
                callback.onSuccess(null)
            }
        })
    }

    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        callback.onSuccess()
    }

    private fun traverseStructure(
        node: AssistStructure.ViewNode,
        fields: MutableMap<String, AssistStructure.ViewNode>
    ): String? {
        var foundWebDomain: String? = node.webDomain

        // 1. Check Autofill Hints
        val hints = node.autofillHints
        if (hints != null) {
            val hintsList = hints.toList()
            if (hintsList.contains(View.AUTOFILL_HINT_USERNAME) || hintsList.contains(View.AUTOFILL_HINT_EMAIL_ADDRESS)) {
                fields["username"] = node
            } else if (hintsList.contains(View.AUTOFILL_HINT_PASSWORD)) {
                fields["password"] = node
            }
        }

        // 2. Check HTML Info (for WebViews like Chrome)
        val htmlInfo = node.htmlInfo
        if (htmlInfo != null) {
            val tag = htmlInfo.tag?.lowercase()
            if (tag == "input") {
                val attributes = htmlInfo.attributes
                var typeAttr = ""
                var nameAttr = ""
                var idAttr = ""
                var autocompleteAttr = ""

                if (attributes != null) {
                    for (pair in attributes) {
                        when (pair.first?.lowercase()) {
                            "type" -> typeAttr = pair.second?.lowercase() ?: ""
                            "name" -> nameAttr = pair.second?.lowercase() ?: ""
                            "id" -> idAttr = pair.second?.lowercase() ?: ""
                            "autocomplete" -> autocompleteAttr = pair.second?.lowercase() ?: ""
                        }
                    }
                }

                if (typeAttr == "password" || autocompleteAttr.contains("password")) {
                    fields["password"] = node
                } else if (typeAttr == "email" || typeAttr == "text" || autocompleteAttr.contains("username") || autocompleteAttr.contains("email")) {
                    if (nameAttr.contains("user") || nameAttr.contains("email") || nameAttr.contains("login") ||
                        idAttr.contains("user") || idAttr.contains("email") || idAttr.contains("login") ||
                        typeAttr == "email" || autocompleteAttr.contains("username") || autocompleteAttr.contains("email")) {
                        fields["username"] = node
                    }
                }
            }
        }

        // 3. Fallback Heuristics for Native Views
        if (!fields.containsKey("username") || !fields.containsKey("password")) {
            val viewId = node.idEntry?.lowercase()
            val type = node.inputType
            
            if (fields["username"] == null) {
                if (viewId != null && (viewId.contains("username") || viewId.contains("email") || viewId.contains("user"))) {
                    fields["username"] = node
                } else if (type == InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS || type == InputType.TYPE_TEXT_VARIATION_WEB_EMAIL_ADDRESS) {
                    fields["username"] = node
                }
            }
            if (fields["password"] == null) {
                if (type == InputType.TYPE_TEXT_VARIATION_PASSWORD || 
                    type == InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD || 
                    type == InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD || 
                    type == 129 || type == 225) {
                    fields["password"] = node
                }
            }
        }

        // Traverse children recursively
        for (i in 0 until node.childCount) {
            val childDomain = traverseStructure(node.getChildAt(i), fields)
            if (foundWebDomain == null && childDomain != null) {
                foundWebDomain = childDomain
            }
        }

        return foundWebDomain
    }
}
