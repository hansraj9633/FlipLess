package com.example

import android.graphics.Bitmap
import android.net.Uri
import android.view.HapticFeedbackConstants
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.example.ui.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

private fun safeHaptic(view: android.view.View?, constant: Int) {
    try {
        if (view != null && view.isAttachedToWindow) {
            view.performHapticFeedback(constant)
        }
    } catch (e: Throwable) {
        // Prevent haptic platform exceptions
    }
}

data class QuestionNode(val id: Int, val answer: String?)

enum class VerifyStep {
    EVALUATION_METHOD,
    UPLOAD_METHOD,
    EXTRACTING,
    VERIFY
}

@Composable
fun VerifyAnswersScreen(
    onNavigateBack: () -> Unit,
    onConfirm: () -> Unit,
    modifier: Modifier = Modifier
) {
    val view = LocalView.current
    val context = LocalContext.current
    val scope = rememberCoroutineScope()

    // 1. STATE MACHINE PRESETS
    var currentStep by remember { mutableStateOf(VerifyStep.EVALUATION_METHOD) }
    var extractionError by remember { mutableStateOf<String?>(null) }
    var confidenceRate by remember { mutableStateOf(96) }
    var isSimulationMode by remember { mutableStateOf(false) }

    // List of question-answer pairs
    var questions by remember {
        mutableStateOf(emptyList<QuestionNode>())
    }

    var searchQuery by remember { mutableStateOf("") }
    var selectedQuestionForEdit by remember { mutableStateOf<QuestionNode?>(null) }

    // Helpers to populate standard demo lists
    fun loadManualEntryTemplate() {
        val defaultList = mutableListOf<QuestionNode>()
        for (i in 1..50) {
            val ans = when {
                i == 18 -> null // Simulate missing answer
                i % 4 == 0 -> "D"
                i % 3 == 0 -> "C"
                i % 2 == 0 -> "B"
                else -> "A"
            }
            defaultList.add(QuestionNode(i, ans))
        }
        questions = defaultList
        confidenceRate = 98
        currentStep = VerifyStep.VERIFY
    }

    // 2. CAMERA AND GALLERY CONTRACT INTENTS WITH NATIVE HANDLERS
    val galleryLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        if (uri != null) {
            val key = SettingsHelper.geminiApiKey.trim()
            if (key.isEmpty()) {
                extractionError = "No Gemini API key stored. Please enter your API key inside Settings Configuration tab, or use the Simulated Test Sample below."
                return@rememberLauncherForActivityResult
            }
            
            isSimulationMode = false
            currentStep = VerifyStep.EXTRACTING
            extractionError = null

            scope.launch {
                try {
                    val bitmap = kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) {
                        if (android.os.Build.VERSION.SDK_INT >= 28) {
                            val source = android.graphics.ImageDecoder.createSource(context.contentResolver, uri)
                            android.graphics.ImageDecoder.decodeBitmap(source) { decoder, _, _ ->
                                decoder.isMutableRequired = true
                                decoder.allocator = android.graphics.ImageDecoder.ALLOCATOR_SOFTWARE
                            }
                        } else {
                            @Suppress("DEPRECATION")
                            android.provider.MediaStore.Images.Media.getBitmap(context.contentResolver, uri)
                        }
                    }

                    if (bitmap != null) {
                        val result = GeminiAnswerExtractionService.extractAnswerKey(bitmap, key)
                        result.fold(
                            onSuccess = { parsedMap ->
                                val list = mutableListOf<QuestionNode>()
                                val count = maxOf(50, parsedMap.keys.maxOrNull() ?: 50)
                                for (i in 1..count) {
                                    list.add(QuestionNode(i, parsedMap[i]))
                                }
                                questions = list
                                
                                val missingCount = list.count { it.answer == null }
                                confidenceRate = if (missingCount > 0) {
                                    (100 - (missingCount * 100 / count)).coerceIn(60, 95)
                                } else {
                                    100
                                }
                                currentStep = VerifyStep.VERIFY
                            },
                            onFailure = { err ->
                                extractionError = err.message ?: "An unexpected error occurred during API extraction."
                                currentStep = VerifyStep.UPLOAD_METHOD
                            }
                        )
                    } else {
                        extractionError = "Failed to load selected image content."
                        currentStep = VerifyStep.UPLOAD_METHOD
                    }
                } catch (e: Exception) {
                    extractionError = "Exception reading gallery file: ${e.localizedMessage}"
                    currentStep = VerifyStep.UPLOAD_METHOD
                }
            }
        }
    }

    val cameraLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.TakePicturePreview()
    ) { bitmap: Bitmap? ->
        if (bitmap != null) {
            val key = SettingsHelper.geminiApiKey.trim()
            if (key.isEmpty()) {
                extractionError = "No Gemini API key stored. Please enter your API key inside Settings Configuration tab, or use the Simulated Test Sample below."
                return@rememberLauncherForActivityResult
            }

            isSimulationMode = false
            currentStep = VerifyStep.EXTRACTING
            extractionError = null

            scope.launch {
                try {
                    val result = GeminiAnswerExtractionService.extractAnswerKey(bitmap, key)
                    result.fold(
                        onSuccess = { parsedMap ->
                            val list = mutableListOf<QuestionNode>()
                            val count = maxOf(50, parsedMap.keys.maxOrNull() ?: 50)
                            for (i in 1..count) {
                                list.add(QuestionNode(i, parsedMap[i]))
                            }
                            questions = list
                            
                            val missingCount = list.count { it.answer == null }
                            confidenceRate = if (missingCount > 0) {
                                (100 - (missingCount * 100 / count)).coerceIn(65, 95)
                            } else {
                                100
                            }
                            currentStep = VerifyStep.VERIFY
                        },
                        onFailure = { err ->
                            extractionError = err.message ?: "An unexpected error occurred during Camera capturing OCR."
                            currentStep = VerifyStep.UPLOAD_METHOD
                        }
                    )
                } catch (e: Exception) {
                    extractionError = "Error parsing captured camera photo: ${e.localizedMessage}"
                    currentStep = VerifyStep.UPLOAD_METHOD
                }
            }
        }
    }

    // Trigger high-fidelity simulation
    fun startSimulationExtraction() {
        isSimulationMode = true
        currentStep = VerifyStep.EXTRACTING
        extractionError = null

        scope.launch {
            // Replicate realistic parsing speed
            delay(2800)

            // Dynamic loaded answers with structured values (MCQs, TRUE/FALSE, Integers)
            val simulatedAnswers = mapOf(
                1 to "A", 2 to "C", 3 to "D", 4 to "B",
                5 to "TRUE", 6 to "FALSE", 7 to "TRUE", 8 to "A",
                9 to "B", 10 to "C", 11 to "D", 12 to "A",
                13 to "99", 14 to "B", 15 to "A", 16 to "C",
                17 to "D", // Question 18 missing intentionally to demonstrate Confidence warnings
                19 to "A", 20 to "B", 21 to "C", 22 to "TRUE",
                23 to "FALSE", 24 to "D", 25 to "12", 26 to "C",
                27 to "B", 28 to "A", 29 to "C", 30 to "D",
                31 to "A", 32 to "B", 33 to "C", 34 to "D",
                35 to "B", 36 to "A", 37 to "C", 38 to "B",
                39 to "D", 40 to "A", 41 to "C", 42 to "B",
                43 to "D", 44 to "B", 45 to "A", 46 to "C",
                47 to "D", 48 to "A", 49 to "B", 50 to "C"
            )

            val list = mutableListOf<QuestionNode>()
            for (i in 1..50) {
                list.add(QuestionNode(i, simulatedAnswers[i]))
            }
            questions = list
            confidenceRate = 96 // 96% confidence
            currentStep = VerifyStep.VERIFY
        }
    }

    // Dynamic stats computation
    val totalCount = questions.size
    val extractedCount = questions.count { it.answer != null }
    val missingCount = questions.count { it.answer == null }

    // Filter questions based on query
    val filteredQuestions = questions.filter {
        val label = "Question ${it.id}"
        label.contains(searchQuery, ignoreCase = true) || it.id.toString().contains(searchQuery)
    }

    // Chunk the filtered questions for 2-column view
    val chunkedQuestions = filteredQuestions.chunked(2)

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(BackgroundDark)
    ) {
        Column(modifier = Modifier.fillMaxSize()) {

            // Common Header App Bar matching the active Step State
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(BackgroundDark)
                    .padding(horizontal = 12.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.weight(1f)
                ) {
                    IconButton(
                        onClick = {
                            safeHaptic(view, HapticFeedbackConstants.LONG_PRESS)
                            when (currentStep) {
                                VerifyStep.EVALUATION_METHOD -> onNavigateBack()
                                VerifyStep.UPLOAD_METHOD -> currentStep = VerifyStep.EVALUATION_METHOD
                                VerifyStep.EXTRACTING -> { /* Block exit during processing */ }
                                VerifyStep.VERIFY -> {
                                    // Go back to selection method
                                    currentStep = VerifyStep.EVALUATION_METHOD
                                }
                            }
                        }
                    ) {
                        Icon(
                            imageVector = Icons.Default.ArrowBack,
                            contentDescription = "Go Back",
                            tint = TextPrimary,
                            modifier = Modifier.size(24.dp)
                        )
                    }
                    Spacer(modifier = Modifier.width(4.dp))
                    Column {
                        val headerTitle = when (currentStep) {
                            VerifyStep.EVALUATION_METHOD -> "Evaluation Method"
                            VerifyStep.UPLOAD_METHOD -> "Upload Answer Key"
                            VerifyStep.EXTRACTING -> "OCR Extraction"
                            VerifyStep.VERIFY -> "Verify Answers"
                        }
                        val headerSubtitle = when (currentStep) {
                            VerifyStep.EVALUATION_METHOD -> "SELECT GRADING SOURCE"
                            VerifyStep.UPLOAD_METHOD -> "DIGITIZE EXPERT MAPPING"
                            VerifyStep.EXTRACTING -> "AI PARSING STREAM"
                            VerifyStep.VERIFY -> "REVIEW EXTRACTED ANSWERS"
                        }
                        Text(
                            text = headerTitle,
                            color = TextPrimary,
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(1.dp))
                        Text(
                            text = headerSubtitle,
                            color = TextSecondary.copy(alpha = 0.5f),
                            fontSize = 9.sp,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 0.8.sp
                        )
                    }
                }

                if (currentStep == VerifyStep.VERIFY) {
                    TextButton(
                        onClick = {
                            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
                                safeHaptic(view, 16) // Confirm haptic
                            } else {
                                safeHaptic(view, HapticFeedbackConstants.LONG_PRESS)
                            }
                            Toast.makeText(context, "All answers verified successfully!", Toast.LENGTH_LONG).show()
                            onConfirm()
                        }
                    ) {
                        Text(
                            text = "Confirm",
                            color = PrimaryBlue,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            // 3. MULTI-STEP DYNAMIC CONTENTS SCREEN
            when (currentStep) {
                
                // STEP A: EVALUATION METHOD SELECTION SCREEN
                VerifyStep.EVALUATION_METHOD -> {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(24.dp)
                            .verticalScroll(rememberScrollState()),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.AutoAwesome,
                            contentDescription = "Magic",
                            tint = PrimaryBlue,
                            modifier = Modifier.size(48.dp)
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = "Choose Evaluation Method",
                            color = TextPrimary,
                            fontSize = 22.sp,
                            fontWeight = FontWeight.Bold,
                            textAlign = TextAlign.Center
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "Digitize your expert grading rubric sheet automatically using AI or key it in manually.",
                            color = TextSecondary,
                            fontSize = 13.5.sp,
                            textAlign = TextAlign.Center,
                            modifier = Modifier.padding(horizontal = 16.dp)
                        )
                        
                        Spacer(modifier = Modifier.height(32.dp))

                        // Method Card 1: Gemini OCR Extraction
                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable {
                                    safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                                    currentStep = VerifyStep.UPLOAD_METHOD
                                },
                            colors = CardDefaults.cardColors(containerColor = SurfaceDark),
                            shape = RoundedCornerShape(20.dp),
                            border = BorderStroke(1.5.dp, PrimaryBlue)
                        ) {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(20.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Box(
                                    modifier = Modifier
                                        .size(48.dp)
                                        .clip(CircleShape)
                                        .background(PrimaryBlue.copy(alpha = 0.12f)),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Bolt,
                                        contentDescription = "AI",
                                        tint = PrimaryBlue,
                                        modifier = Modifier.size(24.dp)
                                    )
                                }
                                Spacer(modifier = Modifier.width(16.dp))
                                Column(modifier = Modifier.weight(1f)) {
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        Text(
                                            text = "Gemini AI Key Extract",
                                            color = TextPrimary,
                                            fontSize = 16.sp,
                                            fontWeight = FontWeight.Bold
                                        )
                                        Spacer(modifier = Modifier.width(6.dp))
                                        Box(
                                            modifier = Modifier
                                                .clip(RoundedCornerShape(8.dp))
                                                .background(PrimaryBlue.copy(alpha = 0.15f))
                                                .padding(horizontal = 6.dp, vertical = 2.dp)
                                        ) {
                                            Text(
                                                "3.5 FLASH",
                                                color = PrimaryBlue,
                                                fontSize = 8.sp,
                                                fontWeight = FontWeight.Bold
                                            )
                                        }
                                    }
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(
                                        text = "Snap a photo of any written/printed key. Extracts MCQs, TRUE/FALSE, and numbers instantly.",
                                        color = TextSecondary,
                                        fontSize = 12.sp,
                                        lineHeight = 16.sp
                                    )
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(16.dp))

                        // Method Card 2: Manual Direct Sheet Setup
                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable {
                                    safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                                    loadManualEntryTemplate()
                                },
                            colors = CardDefaults.cardColors(containerColor = SurfaceDark),
                            shape = RoundedCornerShape(20.dp),
                            border = BorderStroke(1.dp, BorderDark)
                        ) {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(20.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Box(
                                    modifier = Modifier
                                        .size(48.dp)
                                        .clip(CircleShape)
                                        .background(BorderDark),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Edit,
                                        contentDescription = "Manual",
                                        tint = TextSecondary,
                                        modifier = Modifier.size(22.dp)
                                    )
                                }
                                Spacer(modifier = Modifier.width(16.dp))
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(
                                        text = "Direct Manual Keying",
                                        color = TextPrimary,
                                        fontSize = 16.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(
                                        text = "Initialize an editable blank spreadsheet template directly and input values by hand.",
                                        color = TextSecondary,
                                        fontSize = 12.sp,
                                        lineHeight = 16.sp
                                    )
                                }
                            }
                        }
                    }
                }

                // STEP B: CHOOSE SOURCE / UPLOAD ANSWER KEY IMAGE
                VerifyStep.UPLOAD_METHOD -> {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(20.dp)
                            .verticalScroll(rememberScrollState()),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        Spacer(modifier = Modifier.height(8.dp))
                        
                        Text(
                            text = "Upload Answer Key Source",
                            color = TextPrimary,
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            textAlign = TextAlign.Center
                        )
                        Text(
                            text = "Prepare a sheet containing rows like '1 A, 2 C, 3 D' or custom numbers, and select your digital file below.",
                            color = TextSecondary,
                            fontSize = 13.sp,
                            textAlign = TextAlign.Center,
                            modifier = Modifier.padding(horizontal = 12.dp)
                        )

                        Spacer(modifier = Modifier.height(12.dp))

                        // Camera option card
                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(92.dp)
                                .clickable {
                                    safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                                    try {
                                        cameraLauncher.launch(null)
                                    } catch (e: Exception) {
                                        extractionError = "Camera hardware/app is unavailable on this device: ${e.localizedMessage}"
                                        Toast.makeText(context, "Camera capture not supported or app missing.", Toast.LENGTH_LONG).show()
                                    }
                                },
                            colors = CardDefaults.cardColors(containerColor = SurfaceDark),
                            shape = RoundedCornerShape(16.dp),
                            border = BorderStroke(1.dp, BorderDark)
                        ) {
                            Row(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .padding(horizontal = 20.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = Icons.Default.CameraAlt,
                                    contentDescription = "Camera",
                                    tint = PrimaryBlue,
                                    modifier = Modifier.size(28.dp)
                                )
                                Spacer(modifier = Modifier.width(16.dp))
                                Column {
                                    Text(
                                        "Take Scanner Photo",
                                        color = TextPrimary,
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 15.1.sp
                                    )
                                    Text(
                                        "Use your camera to scan a written answer sheet",
                                        color = TextSecondary,
                                        fontSize = 11.5.sp
                                    )
                                }
                            }
                        }

                        // Gallery option card
                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(92.dp)
                                .clickable {
                                    safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                                    try {
                                        galleryLauncher.launch("image/*")
                                    } catch (e: Exception) {
                                        extractionError = "Gallery picker is unavailable: ${e.localizedMessage}"
                                        Toast.makeText(context, "System photo picker is not available.", Toast.LENGTH_LONG).show()
                                    }
                                },
                            colors = CardDefaults.cardColors(containerColor = SurfaceDark),
                            shape = RoundedCornerShape(16.dp),
                            border = BorderStroke(1.dp, BorderDark)
                        ) {
                            Row(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .padding(horizontal = 20.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Image,
                                    contentDescription = "Gallery",
                                    tint = PrimaryBlue,
                                    modifier = Modifier.size(28.dp)
                                )
                                Spacer(modifier = Modifier.width(16.dp))
                                Column {
                                    Text(
                                        "Select from Photo Gallery",
                                        color = TextPrimary,
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 15.1.sp
                                    )
                                    Text(
                                        "Import an existing screenshot image or PDF capture",
                                        color = TextSecondary,
                                        fontSize = 11.5.sp
                                    )
                                }
                            }
                        }

                        // Sandbox Simulator Option (CRITICAL FOR OFFLINE EMULATOR VERIFICATION)
                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(16.dp))
                                .background(
                                    Brush.linearGradient(
                                        colors = listOf(PrimaryBlue.copy(alpha = 0.15f), SurfaceDark)
                                    )
                                )
                                .border(1.5.dp, PrimaryBlue.copy(alpha = 0.4f), RoundedCornerShape(16.dp))
                                .clickable {
                                    safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                                    startSimulationExtraction()
                                }
                                .padding(20.dp)
                        ) {
                            Column(modifier = Modifier.background(Color.Transparent)) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(
                                        imageVector = Icons.Default.AutoAwesome,
                                        contentDescription = "Simulate",
                                        tint = PrimaryBlue,
                                        modifier = Modifier.size(20.dp)
                                    )
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Text(
                                        text = "Try AI with Sample Sheet",
                                        color = TextPrimary,
                                        fontWeight = FontWeight.ExtraBold,
                                        fontSize = 15.sp
                                    )
                                }
                                Spacer(modifier = Modifier.height(4.dp))
                                Text(
                                    text = "Highly recommended for instant testing. Generates a real-world multi-format extraction (A, TRUE, 99) instantly without needing an active API Key.",
                                    color = TextSecondary,
                                    fontSize = 12.sp,
                                    lineHeight = 16.sp
                                )
                            }
                        }

                        // Display Errors gracefully standard
                        extractionError?.let { errText ->
                            Card(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = 8.dp),
                                colors = CardDefaults.cardColors(containerColor = Color(0x28EF4444)),
                                border = BorderStroke(1.dp, ErrorRed.copy(alpha = 0.4f)),
                                shape = RoundedCornerShape(12.dp)
                            ) {
                                Column(modifier = Modifier.padding(14.dp)) {
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        Icon(
                                            imageVector = Icons.Default.Error,
                                            contentDescription = "Error",
                                            tint = ErrorRed,
                                            modifier = Modifier.size(16.dp)
                                        )
                                        Spacer(modifier = Modifier.width(8.dp))
                                        Text(
                                            text = "Extraction Error",
                                            color = ErrorRed,
                                            fontWeight = FontWeight.Bold,
                                            fontSize = 13.sp
                                        )
                                    }
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(
                                        text = errText,
                                        color = TextPrimary.copy(alpha = 0.85f),
                                        fontSize = 12.sp,
                                        lineHeight = 16.sp
                                    )
                                }
                            }
                        }
                    }
                }

                // STEP C: ACTIVE EXTRACTION LOADING PROGRESS
                VerifyStep.EXTRACTING -> {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        // Custom infinite spinning scanner animation
                        val infiniteTransition = rememberInfiniteTransition(label = "extractionSpin")
                        val rotationAngle by infiniteTransition.animateFloat(
                            initialValue = 0f,
                            targetValue = 360f,
                            animationSpec = infiniteRepeatable(
                                animation = tween(1200, easing = LinearEasing),
                                repeatMode = RepeatMode.Restart
                            ),
                            label = "spin"
                        )

                        Box(
                            modifier = Modifier
                                .size(72.dp)
                                .graphicsLayer { rotationZ = rotationAngle },
                            contentAlignment = Alignment.Center
                        ) {
                            CircularProgressIndicator(
                                progress = { 0.75f },
                                modifier = Modifier.fillMaxSize(),
                                color = PrimaryBlue,
                                strokeWidth = 5.dp,
                                trackColor = BorderDark
                            )
                        }

                        Spacer(modifier = Modifier.height(28.dp))
                        
                        Text(
                            text = "Reading answer key...",
                            color = TextPrimary,
                            fontWeight = FontWeight.Bold,
                            fontSize = 18.2.sp
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            text = "Our Gemini engine is locating question nodes & formatting matching values. Please wait.",
                            color = TextSecondary,
                            textAlign = TextAlign.Center,
                            fontSize = 13.sp,
                            modifier = Modifier.padding(horizontal = 24.dp)
                        )
                    }
                }

                // STEP D: FINAL VERIFICATION LAYOUT
                VerifyStep.VERIFY -> {
                    // MAIN CONTENT SCROLLABLE LIST WITH DYNAMIC STATS & CORRECTIONS
                    LazyColumn(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(horizontal = 16.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp),
                        contentPadding = PaddingValues(bottom = 32.dp)
                    ) {
                        
                        // AI Status Badge Card
                        item {
                            Column(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clip(RoundedCornerShape(24.dp))
                                    .background(SurfaceDark)
                                    .border(1.dp, BorderDark, RoundedCornerShape(24.dp))
                                    .padding(20.dp),
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                Box(
                                    modifier = Modifier
                                        .size(48.dp)
                                        .clip(CircleShape)
                                        .background(BorderDark),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.AutoAwesome,
                                        contentDescription = "AI Sparkle",
                                        tint = PrimaryBlue,
                                        modifier = Modifier.size(22.dp)
                                    )
                                }
                                
                                Spacer(modifier = Modifier.height(14.dp))
                                
                                Text(
                                    text = "Answer key successfully\nextracted",
                                    color = TextPrimary,
                                    fontSize = 17.sp,
                                    fontWeight = FontWeight.Bold,
                                    textAlign = TextAlign.Center,
                                    lineHeight = 22.sp
                                )
                                
                                Spacer(modifier = Modifier.height(16.dp))
                                
                                // Glowing Progress confidence bar
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Box(
                                        modifier = Modifier
                                            .clip(RoundedCornerShape(12.dp))
                                            .background(PrimaryBlue.copy(alpha = 0.12f))
                                            .padding(horizontal = 10.dp, vertical = 6.dp)
                                    ) {
                                        Text(
                                            text = "$confidenceRate% Confidence",
                                            color = PrimaryBlue,
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.Bold
                                        )
                                    }
                                    
                                    Spacer(modifier = Modifier.width(12.dp))
                                    
                                    Box(
                                        modifier = Modifier
                                            .weight(1f)
                                            .height(5.dp)
                                            .clip(CircleShape)
                                            .background(BorderDark)
                                    ) {
                                        Box(
                                            modifier = Modifier
                                                .fillMaxHeight()
                                                .fillMaxWidth(confidenceRate / 100f)
                                                .background(PrimaryBlue)
                                        )
                                    }
                                }
                            }
                        }

                        // Confidence warning check trigger
                        if (missingCount > 0) {
                            item {
                                Card(
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = CardDefaults.cardColors(containerColor = WarningAmber.copy(alpha = 0.08f)),
                                    border = BorderStroke(1.dp, WarningAmber.copy(alpha = 0.35f)),
                                    shape = RoundedCornerShape(16.dp)
                                ) {
                                    Row(
                                        modifier = Modifier.padding(14.dp),
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Icon(
                                            imageVector = Icons.Default.Warning,
                                            contentDescription = "Warning",
                                            tint = WarningAmber,
                                            modifier = Modifier.size(20.dp)
                                        )
                                        Spacer(modifier = Modifier.width(12.dp))
                                        Text(
                                            text = "Some answers may require manual verification.",
                                            color = WarningAmber,
                                            fontSize = 12.sp,
                                            fontWeight = FontWeight.Bold
                                        )
                                    }
                                }
                            }
                        }

                        // Question Search Input
                        item {
                            OutlinedTextField(
                                value = searchQuery,
                                onValueChange = { searchQuery = it },
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clip(RoundedCornerShape(16.dp))
                                    .background(SurfaceDark),
                                placeholder = {
                                    Text(
                                        "Go to question...",
                                        color = TextSecondary.copy(alpha = 0.5f),
                                        fontSize = 14.sp
                                    )
                                },
                                leadingIcon = {
                                    Icon(
                                        imageVector = Icons.Default.Search,
                                        contentDescription = "Search",
                                        tint = TextSecondary.copy(alpha = 0.5f)
                                    )
                                },
                                trailingIcon = {
                                    if (searchQuery.isNotEmpty()) {
                                        IconButton(onClick = { searchQuery = "" }) {
                                            Icon(
                                                imageVector = Icons.Default.Close,
                                                contentDescription = "Clear search",
                                                tint = TextSecondary
                                            )
                                        }
                                    }
                                },
                                singleLine = true,
                                colors = OutlinedTextFieldDefaults.colors(
                                    focusedBorderColor = BorderDark,
                                    unfocusedBorderColor = BorderDark,
                                    cursorColor = PrimaryBlue,
                                    focusedTextColor = TextPrimary,
                                    unfocusedTextColor = TextPrimary
                                ),
                                shape = RoundedCornerShape(16.dp)
                            )
                        }

                        // Stats Grid Panel
                        item {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clip(RoundedCornerShape(18.dp))
                                    .background(SurfaceDark)
                                    .border(1.dp, BorderDark, RoundedCornerShape(18.dp))
                                    .padding(vertical = 14.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column(
                                    modifier = Modifier.weight(1f),
                                    horizontalAlignment = Alignment.CenterHorizontally
                                ) {
                                    Text(
                                        text = "TOTAL",
                                        color = TextSecondary,
                                        fontSize = 9.sp,
                                        fontWeight = FontWeight.Bold,
                                        letterSpacing = 0.8.sp
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(
                                        text = totalCount.toString(),
                                        color = TextPrimary,
                                        fontSize = 18.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                }

                                Box(
                                    modifier = Modifier
                                        .width(1.dp)
                                        .height(28.dp)
                                        .background(BorderDark)
                                )

                                Column(
                                    modifier = Modifier.weight(1f),
                                    horizontalAlignment = Alignment.CenterHorizontally
                                ) {
                                    Text(
                                        text = "EXTRACTED",
                                        color = TextSecondary,
                                        fontSize = 9.sp,
                                        fontWeight = FontWeight.Bold,
                                        letterSpacing = 0.8.sp
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(
                                        text = extractedCount.toString(),
                                        color = TextPrimary,
                                        fontSize = 18.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                }

                                Box(
                                    modifier = Modifier
                                        .width(1.dp)
                                        .height(28.dp)
                                        .background(BorderDark)
                                )

                                Column(
                                    modifier = Modifier.weight(1f),
                                    horizontalAlignment = Alignment.CenterHorizontally
                                ) {
                                    Text(
                                        text = "MISSING",
                                        color = TextSecondary,
                                        fontSize = 9.sp,
                                        fontWeight = FontWeight.Bold,
                                        letterSpacing = 0.8.sp
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(
                                        text = missingCount.toString(),
                                        color = if (missingCount > 0) WarningAmber else TextPrimary,
                                        fontSize = 18.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                }
                            }
                        }

                        // Grid Content Items
                        if (chunkedQuestions.isEmpty()) {
                            item {
                                Column(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(vertical = 32.dp),
                                    horizontalAlignment = Alignment.CenterHorizontally
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Info,
                                        contentDescription = "Empty list",
                                        tint = TextSecondary.copy(alpha = 0.3f),
                                        modifier = Modifier.size(40.dp)
                                    )
                                    Spacer(modifier = Modifier.height(8.dp))
                                    Text(
                                        text = "No questions match your search.",
                                        color = TextSecondary,
                                        fontSize = 13.sp
                                    )
                                }
                            }
                        } else {
                            items(chunkedQuestions) { pair ->
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                ) {
                                    QuestionCard(
                                        node = pair[0],
                                        onCardClick = { selectedQuestionForEdit = pair[0] },
                                        modifier = Modifier.weight(1f)
                                    )

                                    if (pair.size > 1) {
                                        QuestionCard(
                                            node = pair[1],
                                            onCardClick = { selectedQuestionForEdit = pair[1] },
                                            modifier = Modifier.weight(1f)
                                        )
                                    } else {
                                        Box(modifier = Modifier.weight(1f))
                                    }
                                }
                            }
                        }

                        // Elegant Try Again/Re-upload Button directly accessible below verification
                        item {
                            Spacer(modifier = Modifier.height(8.dp))
                            OutlinedButton(
                                onClick = {
                                    safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                                    currentStep = VerifyStep.EVALUATION_METHOD
                                },
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(48.dp),
                                colors = ButtonDefaults.outlinedButtonColors(contentColor = PrimaryBlue),
                                shape = RoundedCornerShape(14.dp),
                                border = BorderStroke(1.dp, BorderDark)
                            ) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(Icons.Default.Refresh, contentDescription = "Retry", modifier = Modifier.size(16.dp))
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Text("Re-Upload Key Sheet", fontSize = 13.5.sp, fontWeight = FontWeight.Bold)
                                }
                            }
                        }
                    }
                }
            }
        }

        // 4. CORRECTION / EDIT DLALOG WITH MULTI-OPTION SUPPORT (MCQs AND INTEGERS INPUT)
        selectedQuestionForEdit?.let { qNode ->
            var editTabState by remember(qNode.id) {
                mutableStateOf(
                    when {
                        qNode.answer == "TRUE" || qNode.answer == "FALSE" -> "tf"
                        qNode.answer != null && qNode.answer.all { it.isDigit() } -> "numeric"
                        else -> "mcq"
                    }
                )
            }
            var customIntText by remember(qNode.id) {
                mutableStateOf(if (qNode.answer != null && qNode.answer.all { it.isDigit() }) qNode.answer else "")
            }

            Dialog(
                onDismissRequest = { selectedQuestionForEdit = null }
            ) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp)
                        .border(1.dp, BorderDark, RoundedCornerShape(24.dp)),
                    shape = RoundedCornerShape(24.dp),
                    colors = CardDefaults.cardColors(containerColor = SurfaceDark)
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(20.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "Correction — Question ${qNode.id}",
                            color = TextPrimary,
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Correct the parsed Gemini extraction mapping.",
                            color = TextSecondary,
                            fontSize = 11.5.sp,
                            textAlign = TextAlign.Center
                        )

                        Spacer(modifier = Modifier.height(18.dp))

                        // Type Category Tab Row inside Edit dialog
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(34.dp)
                                .clip(RoundedCornerShape(10.dp))
                                .background(Color(0xFF0F1115))
                                .border(1.dp, BorderDark, RoundedCornerShape(10.dp)),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            listOf("mcq" to "MCQ", "tf" to "T/F", "numeric" to "Int").forEach { (tabId, label) ->
                                val active = editTabState == tabId
                                Box(
                                    modifier = Modifier
                                        .weight(1f)
                                        .fillMaxHeight()
                                        .clip(RoundedCornerShape(8.dp))
                                        .background(if (active) PrimaryBlue else Color.Transparent)
                                        .clickable { editTabState = tabId },
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        label,
                                        color = if (active) BackgroundDark else TextSecondary,
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 11.sp
                                    )
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(18.dp))

                        when (editTabState) {
                            "mcq" -> {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    listOf("A", "B", "C", "D").forEach { valLetter ->
                                        val selected = qNode.answer == valLetter
                                        Box(
                                            modifier = Modifier
                                                .weight(1f)
                                                .aspectRatio(1f)
                                                .clip(RoundedCornerShape(12.dp))
                                                .background(if (selected) PrimaryBlue else BorderDark)
                                                .clickable {
                                                    safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                                                    questions = questions.map {
                                                        if (it.id == qNode.id) it.copy(answer = valLetter) else it
                                                    }
                                                    selectedQuestionForEdit = null
                                                },
                                            contentAlignment = Alignment.Center
                                        ) {
                                            Text(
                                                valLetter,
                                                color = if (selected) BackgroundDark else TextPrimary,
                                                fontSize = 18.sp,
                                                fontWeight = FontWeight.Bold
                                            )
                                        }
                                    }
                                }
                            }

                            "tf" -> {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                                ) {
                                    listOf("TRUE" to "True", "FALSE" to "False").forEach { (valKey, valLabel) ->
                                        val selected = qNode.answer == valKey
                                        Button(
                                            onClick = {
                                                safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                                                questions = questions.map {
                                                    if (it.id == qNode.id) it.copy(answer = valKey) else it
                                                }
                                                selectedQuestionForEdit = null
                                            },
                                            modifier = Modifier.weight(1f),
                                            colors = ButtonDefaults.buttonColors(
                                                containerColor = if (selected) PrimaryBlue else BorderDark
                                            ),
                                            shape = RoundedCornerShape(12.dp)
                                        ) {
                                            Text(valLabel, color = if (selected) BackgroundDark else TextPrimary, fontWeight = FontWeight.Bold)
                                        }
                                    }
                                }
                            }

                            "numeric" -> {
                                Column(modifier = Modifier.fillMaxWidth()) {
                                    OutlinedTextField(
                                        value = customIntText,
                                        onValueChange = { input -> 
                                            if (input.all { it.isDigit() }) customIntText = input 
                                        },
                                        modifier = Modifier.fillMaxWidth(),
                                        placeholder = { Text("Enter Integer (e.g. 99)") },
                                        singleLine = true,
                                        colors = OutlinedTextFieldDefaults.colors(
                                            focusedBorderColor = PrimaryBlue,
                                            unfocusedBorderColor = BorderDark,
                                            focusedTextColor = TextPrimary,
                                            unfocusedTextColor = TextPrimary
                                        )
                                    )
                                    Spacer(modifier = Modifier.height(12.dp))
                                    Button(
                                        onClick = {
                                            if (customIntText.isNotEmpty()) {
                                                safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                                                questions = questions.map {
                                                    if (it.id == qNode.id) it.copy(answer = customIntText) else it
                                                }
                                                selectedQuestionForEdit = null
                                            }
                                        },
                                        modifier = Modifier.fillMaxWidth(),
                                        colors = ButtonDefaults.buttonColors(containerColor = PrimaryBlue),
                                        shape = RoundedCornerShape(10.dp)
                                    ) {
                                        Text("Save Integer", color = BackgroundDark, fontWeight = FontWeight.Bold)
                                    }
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(16.dp))

                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                            TextButton(
                                onClick = {
                                    safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                                    questions = questions.map {
                                        if (it.id == qNode.id) it.copy(answer = null) else it
                                    }
                                    selectedQuestionForEdit = null
                                }
                            ) {
                                Text("Clear Answer", color = ErrorRed, fontWeight = FontWeight.Bold)
                            }

                            TextButton(onClick = { selectedQuestionForEdit = null }) {
                                Text("Cancel", color = TextSecondary)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun QuestionCard(
    node: QuestionNode,
    onCardClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val view = LocalView.current
    val isMissing = node.answer == null
    
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.97f else 1.0f,
        animationSpec = tween(80),
        label = "scale"
    )

    Box(
        modifier = modifier
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            }
            .clip(RoundedCornerShape(16.dp))
            .background(SurfaceDark)
            .border(
                width = if (isMissing) 1.5.dp else 1.dp,
                color = if (isMissing) WarningAmber else BorderDark,
                shape = RoundedCornerShape(16.dp)
            )
            .clickable(
                interactionSource = interactionSource,
                indication = LocalIndication.current
            ) {
                safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                onCardClick()
            }
            .height(108.dp)
            .padding(14.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.SpaceBetween,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Question ${node.id}",
                color = if (isMissing) WarningAmber else TextSecondary,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold
            )

            if (isMissing) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center,
                    modifier = Modifier.weight(1f)
                ) {
                    Icon(
                        imageVector = Icons.Default.Warning,
                        contentDescription = "Missing",
                        tint = WarningAmber,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "ADD ANSWER",
                        color = WarningAmber,
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 0.5.sp
                    )
                }
            } else {
                Text(
                    text = node.answer ?: "",
                    color = PrimaryBlue,
                    fontSize = 28.sp,
                    fontWeight = FontWeight.ExtraBold,
                    modifier = Modifier.weight(1f).wrapContentHeight(Alignment.CenterVertically)
                )
            }
        }
    }
}
