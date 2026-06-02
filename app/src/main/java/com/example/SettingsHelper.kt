package com.example

import android.content.Context
import android.content.SharedPreferences
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue

object SettingsHelper {
    private const val PREFS_NAME = "flip_less_settings"
    private lateinit var prefs: SharedPreferences

    // Reactive state variables for Compose
    var studentName by mutableStateOf("Hans")
        private set

    var themeMode by mutableStateOf("Dark") // "System", "Dark", "Light"
        private set

    var soundEffectsEnabled by mutableStateOf(true)
        private set

    var hapticFeedbackEnabled by mutableStateOf(true)
        private set

    var animationsEnabled by mutableStateOf(true)
        private set

    var defaultTimer by mutableStateOf("120 min")
        private set

    var autoSaveDrafts by mutableStateOf(true)
        private set

    var showProgressPercentage by mutableStateOf(true)
        private set

    var geminiApiKey by mutableStateOf("")
        private set

    // Analytics / Progress states
    var sessionsCompleted by mutableStateOf(125)
        private set
    var questionsSolved by mutableStateOf(3421)
        private set
    var studyTimeHours by mutableStateOf(72)
        private set
    var averageAccuracy by mutableStateOf(75)
        private set
    var storageUsedMb by mutableStateOf(84)
        private set

    fun init(context: Context) {
        prefs = context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        
        // Load settings from SharedPreferences with clean defaults
        studentName = prefs.getString("studentName", "Hans") ?: "Hans"
        themeMode = prefs.getString("themeMode", "Dark") ?: "Dark"
        soundEffectsEnabled = prefs.getBoolean("soundEffects", true)
        hapticFeedbackEnabled = prefs.getBoolean("hapticFeedback", true)
        animationsEnabled = prefs.getBoolean("animations", true)
        defaultTimer = prefs.getString("defaultTimer", "120 min") ?: "120 min"
        autoSaveDrafts = prefs.getBoolean("autoSaveDrafts", true)
        showProgressPercentage = prefs.getBoolean("showProgressPercentage", true)
        geminiApiKey = prefs.getString("geminiApiKey", "") ?: ""
        
        sessionsCompleted = prefs.getInt("sessionsCompleted", 125)
        questionsSolved = prefs.getInt("questionsSolved", 3421)
        studyTimeHours = prefs.getInt("studyTime", 72)
        averageAccuracy = prefs.getInt("accuracy", 75)
        storageUsedMb = prefs.getInt("storageUsed", 84)
    }

    fun updateStudentName(name: String) {
        studentName = name
        prefs.edit().putString("studentName", name).apply()
    }

    fun updateThemeMode(mode: String) {
        themeMode = mode
        prefs.edit().putString("themeMode", mode).apply()
    }

    fun updateSoundEffectsEnabled(enabled: Boolean) {
        soundEffectsEnabled = enabled
        prefs.edit().putBoolean("soundEffects", enabled).apply()
    }

    fun updateHapticFeedbackEnabled(enabled: Boolean) {
        hapticFeedbackEnabled = enabled
        prefs.edit().putBoolean("hapticFeedback", enabled).apply()
    }

    fun updateAnimationsEnabled(enabled: Boolean) {
        animationsEnabled = enabled
        prefs.edit().putBoolean("animations", enabled).apply()
    }

    fun updateDefaultTimer(timer: String) {
        defaultTimer = timer
        prefs.edit().putString("defaultTimer", timer).apply()
    }

    fun updateAutoSaveDrafts(enabled: Boolean) {
        autoSaveDrafts = enabled
        prefs.edit().putBoolean("autoSaveDrafts", enabled).apply()
    }

    fun updateShowProgressPercentage(enabled: Boolean) {
        showProgressPercentage = enabled
        prefs.edit().putBoolean("showProgressPercentage", enabled).apply()
    }

    fun updateGeminiApiKey(key: String) {
        geminiApiKey = key
        prefs.edit().putString("geminiApiKey", key).apply()
    }

    fun clearHistory() {
        sessionsCompleted = 0
        prefs.edit().putInt("sessionsCompleted", 0).apply()
    }

    fun clearAnalytics() {
        averageAccuracy = 0
        studyTimeHours = 0
        prefs.edit().putInt("accuracy", 0).apply()
        prefs.edit().putInt("studyTime", 0).apply()
    }

    fun clearAllData() {
        studentName = "Hans"
        themeMode = "System"
        soundEffectsEnabled = true
        hapticFeedbackEnabled = true
        animationsEnabled = true
        defaultTimer = "120 min"
        autoSaveDrafts = true
        showProgressPercentage = true
        geminiApiKey = ""
        sessionsCompleted = 0
        questionsSolved = 0
        studyTimeHours = 0
        averageAccuracy = 0
        storageUsedMb = 0

        prefs.edit().clear().apply()
    }
}
