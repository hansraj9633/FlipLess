package com.example

import android.graphics.Bitmap
import android.util.Base64
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.util.concurrent.TimeUnit

object GeminiAnswerExtractionService {
    private const val TAG = "GeminiExtraction"
    
    // OkHttpClient with 60-second timeouts to support Gemini requests safely
    private val client = OkHttpClient.Builder()
        .connectTimeout(60, TimeUnit.SECONDS)
        .readTimeout(60, TimeUnit.SECONDS)
        .writeTimeout(60, TimeUnit.SECONDS)
        .build()

    /**
     * Compresses and downscales the bitmap to avoid excessive payload sizes and API billing metrics
     */
    fun toSoftwareBitmap(bitmap: Bitmap): Bitmap {
        val isHardware = android.os.Build.VERSION.SDK_INT >= 26 && bitmap.config == Bitmap.Config.HARDWARE
        if (isHardware) {
            val copied = try {
                bitmap.copy(Bitmap.Config.ARGB_8888, false)
            } catch (e: Throwable) {
                Log.e(TAG, "Bitmap.copy failed, using Canvas fallback", e)
                null
            }
            if (copied != null) {
                return copied
            }
            
            // Canvas drawing fallback (highly robust on all Android versions)
            try {
                val softwareBitmap = Bitmap.createBitmap(bitmap.width, bitmap.height, Bitmap.Config.ARGB_8888)
                val canvas = android.graphics.Canvas(softwareBitmap)
                val paint = android.graphics.Paint()
                canvas.drawBitmap(bitmap, 0f, 0f, paint)
                return softwareBitmap
            } catch (e: Exception) {
                Log.e(TAG, "Canvas drawing fallback failed: ${e.localizedMessage}")
            }
        }
        return bitmap
    }

    fun compressBitmap(bitmap: Bitmap): Bitmap {
        val softwareBitmap = toSoftwareBitmap(bitmap)
        val maxDim = 800f
        val width = softwareBitmap.width
        val height = softwareBitmap.height
        if (width <= maxDim && height <= maxDim) return softwareBitmap
        
        val ratio = width.toFloat() / height.toFloat()
        val newWidth: Int
        val newHeight: Int
        if (width > height) {
            newWidth = maxDim.toInt()
            newHeight = (maxDim / ratio).toInt()
        } else {
            newHeight = maxDim.toInt()
            newWidth = (maxDim * ratio).toInt()
        }
        return Bitmap.createScaledBitmap(softwareBitmap, newWidth, newHeight, true)
    }

    private fun Bitmap.toBase64(): String {
        val softwareBitmap = toSoftwareBitmap(this)
        val outputStream = ByteArrayOutputStream()
        softwareBitmap.compress(Bitmap.CompressFormat.JPEG, 80, outputStream)
        return Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP)
    }

    /**
     * Sends the base64-encoded image to Gemini 3.5 Flash with detailed instruction sets,
     * parses, validates, and cleans the returned response format.
     */
    suspend fun extractAnswerKey(
        bitmap: Bitmap,
        apiKey: String
    ): Result<Map<Int, String>> = withContext(Dispatchers.IO) {
        if (apiKey.trim().isEmpty()) {
            return@withContext Result.failure(Exception("Gemini API Key is empty. Please enter your API key in settings."))
        }

        try {
            val compressed = compressBitmap(bitmap)
            val base64Data = compressed.toBase64()

            val systemInstruction = """
                You are a highly precise academic answer-key extraction engine.
                Your sole task is to extract question-answer pairs visible in the provided image.
                Identify each question number and its corresponding correct answer value.
                
                Strict Answer Formatting:
                - If the answer is an MCQ option (e.g. A, B, C, D), format it exactly as a single capital letter.
                - If the answer is True/False, format it exactly as true "TRUE" or false "FALSE" in all capitals.
                - If the answer is a numeric integer value (e.g. 1, 25, 999), format it exactly as an integer value.
                
                Output Constraint:
                - You MUST return ONLY a fully compliant JSON object structure.
                - Keys must be strings containing only the question numbers (e.g. "1", "2", "3").
                - Values must be strings containing the extracted answer values (e.g., "A", "C", "TRUE", "25").
                - Never include any Markdown code fences (such as ```json or ```).
                - Never include any conversational filler, explanations, prefaces, or debug footnotes.
                - Return purely the raw JSON object string.
            """.trimIndent()

            val prompt = "Analyze this image and extract all question-answer pairs into the requested raw JSON format."

            // Build request object adhering to standard Gemini payload specs
            val requestJson = JSONObject().apply {
                val contentsArray = org.json.JSONArray().apply {
                    put(JSONObject().apply {
                        put("parts", org.json.JSONArray().apply {
                            put(JSONObject().apply {
                                put("text", prompt)
                            })
                            put(JSONObject().apply {
                                put("inlineData", JSONObject().apply {
                                    put("mimeType", "image/jpeg")
                                    put("data", base64Data)
                                })
                            })
                        })
                    })
                }
                put("contents", contentsArray)

                put("systemInstruction", JSONObject().apply {
                    put("parts", org.json.JSONArray().apply {
                        put(JSONObject().apply {
                            put("text", systemInstruction)
                        })
                    })
                })

                put("generationConfig", JSONObject().apply {
                    put("responseMimeType", "application/json")
                    put("temperature", 0.1)
                })
            }

            val mediaType = "application/json; charset=utf-8".toMediaType()
            val body = requestJson.toString().toRequestBody(mediaType)
            val url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent?key=$apiKey"

            val request = Request.Builder()
                .url(url)
                .post(body)
                .build()

            val response = client.newCall(request).execute()
            if (!response.isSuccessful) {
                val code = response.code
                val errBody = response.body?.string() ?: ""
                Log.e(TAG, "API call failed (code $code): $errBody")
                return@withContext when (code) {
                    400, 403 -> Result.failure(Exception("Unauthorized or Invalid API key. Please check your Gemini configuration under settings."))
                    429 -> Result.failure(Exception("Gemini API rate limit exceeded. Please try again shortly."))
                    else -> Result.failure(Exception("Gemini service unavailable (code $code): $errBody"))
                }
            }

            val rawResponseStr = response.body?.string() ?: ""
            Log.d(TAG, "Raw response output: $rawResponseStr")

            val responseObj = JSONObject(rawResponseStr)
            val candidates = responseObj.optJSONArray("candidates")
            if (candidates == null || candidates.length() == 0) {
                return@withContext Result.failure(Exception("Empty extraction result. The model failed to process candidates."))
            }

            val parts = candidates.getJSONObject(0)
                .optJSONObject("content")
                ?.optJSONArray("parts")

            if (parts == null || parts.length() == 0) {
                return@withContext Result.failure(Exception("The response contains no parseable content block parts."))
            }

            var textResponse = parts.getJSONObject(0).optString("text", "").trim()
            if (textResponse.isEmpty()) {
                return@withContext Result.failure(Exception("Extracted answer-sheet JSON is empty."))
            }

            textResponse = cleanJsonResponse(textResponse)

            val answersMap = parseAnswerMap(textResponse)
            if (answersMap.isEmpty()) {
                return@withContext Result.failure(Exception("No valid question-answer keys were found inside the returned JSON payload."))
            }

            return@withContext Result.success(answersMap)

        } catch (e: org.json.JSONException) {
            Log.e(TAG, "JSON error", e)
            return@withContext Result.failure(Exception("Parsing error: Gemini returned an invalid JSON schema. Ensure your answer key list is legible."))
        } catch (e: java.io.IOException) {
            Log.e(TAG, "Network IO error", e)
            return@withContext Result.failure(Exception("Network error: Please confirm your internet connectivity and try again."))
        } catch (e: Exception) {
            Log.e(TAG, "System exception", e)
            return@withContext Result.failure(Exception("Error processing Gemini extraction: ${e.localizedMessage}"))
        }
    }

    private fun cleanJsonResponse(raw: String): String {
        var clean = raw.trim()
        if (clean.startsWith("```json")) {
            clean = clean.removePrefix("```json")
        } else if (clean.startsWith("```")) {
            clean = clean.removePrefix("```")
        }
        if (clean.endsWith("```")) {
            clean = clean.removeSuffix("```")
        }
        return clean.trim()
    }

    private fun parseAnswerMap(jsonStr: String): Map<Int, String> {
        val result = mutableMapOf<Int, String>()
        val obj = JSONObject(jsonStr)
        val keys = obj.keys()
        while (keys.hasNext()) {
            val keyStr = keys.next()
            val questionNum = keyStr.toIntOrNull()
            if (questionNum != null) {
                var answerVal = obj.get(keyStr).toString().trim().uppercase()
                // Standardize True / False abbreviations
                if (answerVal == "T") answerVal = "TRUE"
                if (answerVal == "F") answerVal = "FALSE"
                
                // Allow valid answer structures (MCQ letter, TRUE/FALSE, integer string)
                if (isValidAnswerFormat(answerVal)) {
                    result[questionNum] = answerVal
                }
            }
        }
        return result
    }

    fun isValidAnswerFormat(ans: String): Boolean {
        if (ans.isEmpty()) return false
        if (ans == "TRUE" || ans == "FALSE") return true
        if (ans.length == 1 && ans[0] in 'A'..'D') return true
        if (ans.all { it.isDigit() }) return true
        return false
    }
}
