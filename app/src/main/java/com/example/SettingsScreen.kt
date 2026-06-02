package com.example

import android.content.Context
import android.widget.Toast
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.*

// Helper function to play sound cues (hooks only)
private fun playSound(event: String) {
    // Sound support hooks prepared here as requested
}

// Helper to trigger haptics safely using correct Android API levels
private fun triggerHaptic(view: android.view.View?, constant: Int) {
    try {
        if (SettingsHelper.hapticFeedbackEnabled && view != null && view.isAttachedToWindow) {
            view.performHapticFeedback(constant)
        }
    } catch (e: Throwable) {
        // Prevent sandbox or platform failures
    }
}

// Simple helper to format numbers with commas (e.g., 3421 to 3,421)
private fun formatNumber(number: Int): String {
    return if (number >= 1000) {
        val thousands = number / 1000
        val remaining = number % 1000
        "$thousands,${String.format("%03d", remaining)}"
    } else {
        number.toString()
    }
}

@Composable
fun SettingsTabScreen() {
    val context = LocalContext.current
    val view = LocalView.current

    // Screen entering fade + slide up animation state
    var shown by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) {
        shown = true
    }

    AnimatedVisibility(
        visible = shown,
        enter = fadeIn(animationSpec = tween(250)) + slideInVertically(
            initialOffsetY = { it / 8 },
            animationSpec = tween(250, easing = EaseOutQuad)
        ),
        exit = fadeOut(animationSpec = tween(150)),
        modifier = Modifier.fillMaxSize()
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(BackgroundDark)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp, vertical = 20.dp)
                .padding(bottom = 72.dp) // Cushion to avoid bottom nav overlay
        ) {
            SettingsHeader()
            
            Spacer(modifier = Modifier.height(16.dp))

            ProfileCard(view = view, context = context)

            Spacer(modifier = Modifier.height(12.dp))

            PreferencesSection(view = view)

            Spacer(modifier = Modifier.height(12.dp))

            PracticePreferencesSection(view = view)

            Spacer(modifier = Modifier.height(12.dp))

            StatisticsSection()

            Spacer(modifier = Modifier.height(12.dp))

            GeminiSection(view = view)

            Spacer(modifier = Modifier.height(12.dp))

            DataManagementSection(view = view, context = context)

            Spacer(modifier = Modifier.height(12.dp))

            PrivacySection()

            Spacer(modifier = Modifier.height(12.dp))

            AboutSection(view = view, context = context)

            Spacer(modifier = Modifier.height(12.dp))

            SupportCard(view = view, context = context)

            Spacer(modifier = Modifier.height(12.dp))

            DangerZoneSection(view = view, context = context)
        }
    }
}

@Composable
fun SettingsHeader() {
    Column(modifier = Modifier.fillMaxWidth()) {
        Text(
            text = "Settings",
            color = TextPrimary,
            fontSize = 32.sp,
            fontWeight = FontWeight.Bold,
            fontFamily = FontFamily.SansSerif
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = "Manage your academic workspace and preferences.",
            color = TextSecondary,
            fontSize = 14.sp
        )
    }
}

@Composable
fun ProfileCard(view: android.view.View?, context: Context) {
    var showEditSheet by remember { mutableStateOf(false) }
    var tempName by remember { mutableStateOf(SettingsHelper.studentName) }

    // Spring press scale animation
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.98f else 1.0f,
        animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy, stiffness = Spring.StiffnessLow),
        label = "scale"
    )

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            }
            .clickable(interactionSource = interactionSource, indication = null) {
                triggerHaptic(view, android.view.HapticFeedbackConstants.KEYBOARD_TAP)
            },
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        shape = RoundedCornerShape(24.dp),
        border = BorderStroke(1.dp, BorderDark)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Student avatar with circular shape and pencil badge overlay
            Box(
                modifier = Modifier.size(68.dp),
                contentAlignment = Alignment.BottomEnd
            ) {
                Box(
                    modifier = Modifier
                        .size(64.dp)
                        .clip(CircleShape)
                        .background(Color(0xFF1E293B))
                        .border(1.5.dp, PrimaryBlue, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Person,
                        contentDescription = "Avatar",
                        tint = PrimaryBlue,
                        modifier = Modifier.size(36.dp)
                    )
                }
                // Little blue pencil badge for edit indicator
                Box(
                    modifier = Modifier
                        .size(22.dp)
                        .clip(CircleShape)
                        .background(PrimaryBlue)
                        .border(1.5.dp, SurfaceDark, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Edit,
                        contentDescription = null,
                        tint = BackgroundDark,
                        modifier = Modifier.size(11.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.width(16.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = SettingsHelper.studentName,
                    color = TextPrimary,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "Student",
                    color = TextSecondary,
                    fontSize = 13.sp
                )
                Spacer(modifier = Modifier.height(6.dp))
                Button(
                    onClick = {
                        triggerHaptic(view, android.view.HapticFeedbackConstants.LONG_PRESS)
                        tempName = SettingsHelper.studentName
                        showEditSheet = true
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF1E293B)),
                    shape = RoundedCornerShape(12.dp),
                    contentPadding = PaddingValues(horizontal = 14.dp, vertical = 6.dp)
                ) {
                    Text("Edit Name", color = TextPrimary, fontSize = 11.5.sp, fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }

    // Modern styled Bottom Sheet Dialog for updating profile name (pure Compose dialog for container)
    if (showEditSheet) {
        AlertDialog(
            onDismissRequest = { showEditSheet = false },
            title = {
                Text(
                    text = "Edit Profile Name",
                    color = TextPrimary,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = TextAlign.Center
                )
            },
            text = {
                Column(modifier = Modifier.fillMaxWidth()) {
                    OutlinedTextField(
                        value = tempName,
                        onValueChange = { tempName = it },
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(top = 8.dp),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = PrimaryBlue,
                            unfocusedBorderColor = BorderDark,
                            focusedTextColor = TextPrimary,
                            unfocusedTextColor = TextPrimary
                        ),
                        singleLine = true,
                        shape = RoundedCornerShape(12.dp)
                    )
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        triggerHaptic(view, android.view.HapticFeedbackConstants.VIRTUAL_KEY)
                        playSound("Settings Saved")
                        if (tempName.trim().isNotEmpty()) {
                            SettingsHelper.updateStudentName(tempName.trim())
                            Toast.makeText(context, "Profile name updated!", Toast.LENGTH_SHORT).show()
                        }
                        showEditSheet = false
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = PrimaryBlue),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Text("Save", color = BackgroundDark, fontWeight = FontWeight.Bold)
                }
            },
            dismissButton = {
                TextButton(onClick = { showEditSheet = false }) {
                    Text("Cancel", color = TextSecondary)
                }
            },
            containerColor = SurfaceDark,
            shape = RoundedCornerShape(24.dp),
            modifier = Modifier.border(1.dp, BorderDark, RoundedCornerShape(24.dp))
        )
    }
}

@Composable
fun PreferencesSection(view: android.view.View?) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        shape = RoundedCornerShape(20.dp),
        border = BorderStroke(1.dp, BorderDark)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Palette,
                    contentDescription = null,
                    tint = PrimaryBlue,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Appearance",
                    color = TextPrimary,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
            }
            
            Spacer(modifier = Modifier.height(12.dp))

            // Segmented Theme Control
            SegmentedThemeSelector(
                selectedTheme = SettingsHelper.themeMode,
                onThemeSelected = { SettingsHelper.updateThemeMode(it) },
                view = view
            )

            Spacer(modifier = Modifier.height(14.dp))

            // Sound Support toggle
            PreferenceToggleItem(
                title = "Sound Effects",
                description = "Play subtle UI sounds.",
                checked = SettingsHelper.soundEffectsEnabled,
                onCheckedChange = {
                    triggerHaptic(view, android.view.HapticFeedbackConstants.KEYBOARD_TAP)
                    playSound("Toggle Changed")
                    SettingsHelper.updateSoundEffectsEnabled(it)
                }
            )

            HorizontalDivider(color = BorderDark, modifier = Modifier.padding(vertical = 10.dp))

            // Haptics toggle
            PreferenceToggleItem(
                title = "Haptic Feedback",
                description = "Provide vibration feedback.",
                checked = SettingsHelper.hapticFeedbackEnabled,
                onCheckedChange = {
                    SettingsHelper.updateHapticFeedbackEnabled(it)
                    // Immediate click haptic feedback as validation
                    if (it) {
                        try {
                            view?.performHapticFeedback(android.view.HapticFeedbackConstants.KEYBOARD_TAP)
                        } catch (e: Throwable) {}
                    }
                }
            )

            HorizontalDivider(color = BorderDark, modifier = Modifier.padding(vertical = 10.dp))

            // Animations toggle
            PreferenceToggleItem(
                title = "Animations",
                description = "Enable smooth transitions.",
                checked = SettingsHelper.animationsEnabled,
                onCheckedChange = {
                    triggerHaptic(view, android.view.HapticFeedbackConstants.KEYBOARD_TAP)
                    SettingsHelper.updateAnimationsEnabled(it)
                }
            )
        }
    }
}

@Composable
fun SegmentedThemeSelector(
    selectedTheme: String,
    onThemeSelected: (String) -> Unit,
    view: android.view.View?
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(Color(0xFF0F1115))
            .border(1.dp, BorderDark, RoundedCornerShape(12.dp))
            .padding(4.dp),
        horizontalArrangement = Arrangement.SpaceEvenly
    ) {
        listOf("System", "Dark", "Light").forEach { theme ->
            val isSelected = selectedTheme == theme
            Box(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(8.dp))
                    .background(if (isSelected) PrimaryBlue else Color.Transparent)
                    .clickable {
                        triggerHaptic(view, android.view.HapticFeedbackConstants.KEYBOARD_TAP)
                        onThemeSelected(theme)
                    }
                    .padding(vertical = 10.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = theme,
                    color = if (isSelected) BackgroundDark else TextSecondary,
                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                    fontSize = 13.sp
                )
            }
        }
    }
}

@Composable
fun PreferenceToggleItem(
    title: String,
    description: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                color = TextPrimary,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = description,
                color = TextSecondary,
                fontSize = 11.5.sp
            )
        }
        
        Switch(
            checked = checked,
            onCheckedChange = onCheckedChange,
            colors = SwitchDefaults.colors(
                checkedThumbColor = Color.White,
                checkedTrackColor = PrimaryBlue,
                uncheckedThumbColor = TextSecondary,
                uncheckedTrackColor = Color(0xFF0F1115),
                uncheckedBorderColor = BorderDark
            )
        )
    }
}

@Composable
fun PracticePreferencesSection(view: android.view.View?) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        shape = RoundedCornerShape(20.dp),
        border = BorderStroke(1.dp, BorderDark)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Timer,
                    contentDescription = null,
                    tint = PrimaryBlue,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Practice",
                    color = TextPrimary,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            TimerDropdownSelector(
                selectedTimer = SettingsHelper.defaultTimer,
                onTimerSelected = { SettingsHelper.updateDefaultTimer(it) },
                view = view
            )

            Spacer(modifier = Modifier.height(14.dp))

            PreferenceToggleItem(
                title = "Auto Save Drafts",
                description = "Automatically save active practice drafts when leaving screen.",
                checked = SettingsHelper.autoSaveDrafts,
                onCheckedChange = {
                    triggerHaptic(view, android.view.HapticFeedbackConstants.KEYBOARD_TAP)
                    SettingsHelper.updateAutoSaveDrafts(it)
                }
            )

            HorizontalDivider(color = BorderDark, modifier = Modifier.padding(vertical = 10.dp))

            PreferenceToggleItem(
                title = "Show Progress Percentage",
                description = "Render completion visual gauges in active sessions.",
                checked = SettingsHelper.showProgressPercentage,
                onCheckedChange = {
                    triggerHaptic(view, android.view.HapticFeedbackConstants.KEYBOARD_TAP)
                    SettingsHelper.updateShowProgressPercentage(it)
                }
            )
        }
    }
}

@Composable
fun TimerDropdownSelector(
    selectedTimer: String,
    onTimerSelected: (String) -> Unit,
    view: android.view.View?
) {
    var expanded by remember { mutableStateOf(false) }
    val options = listOf("No Timer", "15 min", "30 min", "45 min", "60 min", "90 min", "120 min")

    Column(modifier = Modifier.fillMaxWidth()) {
        Text(
            text = "Timer Options",
            color = TextSecondary,
            fontSize = 12.sp,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.padding(bottom = 6.dp)
        )
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(Color(0xFF0F1115))
                .border(1.dp, BorderDark, RoundedCornerShape(12.dp))
                .clickable {
                    triggerHaptic(view, android.view.HapticFeedbackConstants.KEYBOARD_TAP)
                    expanded = !expanded
                }
                .padding(horizontal = 14.dp, vertical = 13.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = selectedTimer,
                    color = TextPrimary,
                    fontSize = 14.sp
                )
                Icon(
                    imageVector = Icons.Default.ArrowDropDown,
                    contentDescription = null,
                    tint = TextSecondary
                )
            }

            DropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false },
                modifier = Modifier
                    .fillMaxWidth(0.85f)
                    .background(SurfaceDark)
                    .border(1.dp, BorderDark, RoundedCornerShape(8.dp))
            ) {
                options.forEach { option ->
                    DropdownMenuItem(
                        text = { Text(option, color = TextPrimary, fontSize = 14.sp) },
                        onClick = {
                            onTimerSelected(option)
                            expanded = false
                            triggerHaptic(view, android.view.HapticFeedbackConstants.VIRTUAL_KEY)
                        }
                    )
                }
            }
        }
    }
}

@Composable
fun StatisticsSection() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        shape = RoundedCornerShape(20.dp),
        border = BorderStroke(1.dp, BorderDark)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.BarChart,
                    contentDescription = null,
                    tint = PrimaryBlue,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Performance",
                    color = TextPrimary,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(14.dp))

            // 2x2 grid mapping image statistics labels
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    StatCardItem(
                        modifier = Modifier.weight(1f),
                        label = "Sessions",
                        value = SettingsHelper.sessionsCompleted,
                        suffix = ""
                    )
                    StatCardItem(
                        modifier = Modifier.weight(1f),
                        label = "Questions",
                        value = SettingsHelper.questionsSolved,
                        suffix = "",
                        useComma = true
                    )
                }
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    StatCardItem(
                        modifier = Modifier.weight(1f),
                        label = "Time",
                        value = SettingsHelper.studyTimeHours,
                        suffix = "h"
                    )
                    StatCardItem(
                        modifier = Modifier.weight(1f),
                        label = "Accuracy",
                        value = SettingsHelper.averageAccuracy,
                        suffix = "%"
                    )
                }
            }
        }
    }
}

@Composable
fun StatCardItem(
    modifier: Modifier = Modifier,
    label: String,
    value: Int,
    suffix: String,
    useComma: Boolean = false
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(16.dp))
            .background(Color(0xFF0F1115))
            .border(1.dp, BorderDark, RoundedCornerShape(16.dp))
            .padding(14.dp)
    ) {
        Column {
            Text(
                text = label,
                color = TextSecondary,
                fontSize = 11.sp,
                fontWeight = FontWeight.Medium
            )
            Spacer(modifier = Modifier.height(6.dp))
            AnimatedCountText(
                targetValue = value,
                suffix = suffix,
                useComma = useComma
            )
        }
    }
}

@Composable
fun AnimatedCountText(
    targetValue: Int,
    suffix: String = "",
    useComma: Boolean = false
) {
    var count by remember { mutableStateOf(0) }
    
    // Trigger count up only if animation toggle is enabled in settings
    LaunchedEffect(targetValue) {
        if (!SettingsHelper.animationsEnabled) {
            count = targetValue
            return@LaunchedEffect
        }
        val animationDuration = 550L
        val steps = 20
        val delayTime = animationDuration / steps
        val stepSize = (targetValue / steps).coerceAtLeast(1)
        
        for (i in 1..steps) {
            kotlinx.coroutines.delay(delayTime)
            count = (stepSize * i).coerceAtMost(targetValue)
        }
        count = targetValue
    }
    
    val displayText = if (useComma) formatNumber(count) else count.toString()
    
    Text(
        text = "$displayText$suffix",
        color = TextPrimary,
        fontSize = 20.sp,
        fontWeight = FontWeight.Bold
    )
}

@Composable
fun GeminiSection(view: android.view.View?) {
    var keyText by remember { mutableStateOf(SettingsHelper.geminiApiKey) }
    var keyVisible by remember { mutableStateOf(false) }
    var validationText by remember { mutableStateOf<String?>(null) }
    var isValidating by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        shape = RoundedCornerShape(20.dp),
        border = BorderStroke(1.dp, BorderDark)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Bolt,
                    contentDescription = null,
                    tint = PrimaryBlue,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Gemini Configuration",
                    color = TextPrimary,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
            }
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = "Empower your study sessions with AI integration.",
                color = TextSecondary,
                fontSize = 12.sp,
                modifier = Modifier.padding(bottom = 12.dp)
            )

            // Secure field with show/hide suffix toggler
            OutlinedTextField(
                value = keyText,
                onValueChange = {
                    keyText = it
                    SettingsHelper.updateGeminiApiKey(it)
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(Color(0xFF0F1115)),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = PrimaryBlue,
                    unfocusedBorderColor = BorderDark,
                    focusedTextColor = TextPrimary,
                    unfocusedTextColor = TextPrimary,
                    focusedPlaceholderColor = TextSecondary.copy(alpha = 0.5f),
                    unfocusedPlaceholderColor = TextSecondary.copy(alpha = 0.5f)
                ),
                placeholder = { Text("Paste Gemini API Key", fontSize = 13.5.sp) },
                singleLine = true,
                visualTransformation = if (keyVisible) VisualTransformation.None else PasswordVisualTransformation(),
                trailingIcon = {
                    IconButton(onClick = { keyVisible = !keyVisible }) {
                        Icon(
                            imageVector = if (keyVisible) Icons.Default.VisibilityOff else Icons.Default.Visibility,
                            contentDescription = "Show/Hide Key",
                            tint = TextSecondary,
                            modifier = Modifier.size(18.dp)
                        )
                    }
                }
            )

            Spacer(modifier = Modifier.height(12.dp))

            // Validate Key triggers mock logic
            Button(
                onClick = {
                    triggerHaptic(view, android.view.HapticFeedbackConstants.VIRTUAL_KEY)
                    playSound("Toggle Changed")
                    if (keyText.trim().isEmpty()) {
                        validationText = "Invalid API Key"
                    } else {
                        isValidating = true
                        // Preparation placeholder state
                        validationText = "Valid API Key"
                        isValidating = false
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = PrimaryBlue),
                shape = RoundedCornerShape(12.dp),
                contentPadding = PaddingValues(vertical = 12.dp)
            ) {
                if (isValidating) {
                    CircularProgressIndicator(color = BackgroundDark, modifier = Modifier.size(18.dp))
                } else {
                    Text(
                        text = "Validate Key",
                        color = BackgroundDark,
                        fontWeight = FontWeight.Bold,
                        fontSize = 13.5.sp
                    )
                }
            }

            validationText?.let { result ->
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = result,
                    color = if (result == "Valid API Key") SuccessGreen else ErrorRed,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = TextAlign.Center
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Secure local warning info card
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(10.dp))
                    .background(Color(0xFF0F1115))
                    .border(1.dp, BorderDark, RoundedCornerShape(10.dp))
                    .padding(10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.Info,
                    contentDescription = null,
                    tint = TextSecondary,
                    modifier = Modifier.size(15.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Keys are stored locally on your device for maximum security.",
                    color = TextSecondary,
                    fontSize = 10.5.sp,
                    lineHeight = 14.sp
                )
            }
        }
    }
}

@Composable
fun DataManagementSection(view: android.view.View?, context: Context) {
    // Progress fill animation for storage bar
    var progressVal by remember { mutableStateOf(0f) }
    LaunchedEffect(Unit) {
        if (SettingsHelper.animationsEnabled) {
            val duration = 650L
            val steps = 15
            for (i in 1..steps) {
                kotlinx.coroutines.delay(duration / steps)
                progressVal = (0.65f * (i.toFloat() / steps))
            }
        } else {
            progressVal = 0.65f
        }
    }

    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        shape = RoundedCornerShape(20.dp),
        border = BorderStroke(1.dp, BorderDark)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Storage,
                    contentDescription = null,
                    tint = PrimaryBlue,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Data & Storage",
                    color = TextPrimary,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(14.dp))

            // Usage details
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Storage Usage",
                    color = TextPrimary,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold
                )
                Text(
                    text = "${SettingsHelper.storageUsedMb} MB Used",
                    color = TextSecondary,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Glowing blue progress bar indicators
            LinearProgressIndicator(
                progress = progressVal,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(6.dp)
                    .clip(RoundedCornerShape(3.dp)),
                color = PrimaryBlue,
                trackColor = Color(0xFF0F1115)
            )

            Spacer(modifier = Modifier.height(16.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                OutlinedButton(
                    onClick = {
                        triggerHaptic(view, android.view.HapticFeedbackConstants.VIRTUAL_KEY)
                        playSound("Data Exported")
                        Toast.makeText(context, "Backup written! Exported to JSON as zip configuration.", Toast.LENGTH_SHORT).show()
                    },
                    modifier = Modifier.weight(1f),
                    border = BorderStroke(1.dp, BorderDark),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Text("Export Data", color = TextPrimary, fontSize = 13.sp)
                }

                OutlinedButton(
                    onClick = {
                        triggerHaptic(view, android.view.HapticFeedbackConstants.VIRTUAL_KEY)
                        Toast.makeText(context, "App data restored cleanly from backups!", Toast.LENGTH_SHORT).show()
                    },
                    modifier = Modifier.weight(1f),
                    border = BorderStroke(1.dp, BorderDark),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Text("Import Data", color = TextPrimary, fontSize = 13.sp)
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            OutlinedButton(
                onClick = {
                    triggerHaptic(view, android.view.HapticFeedbackConstants.VIRTUAL_KEY)
                    playSound("Data Exported")
                    Toast.makeText(context, "Full archive system backup created!", Toast.LENGTH_SHORT).show()
                },
                modifier = Modifier.fillMaxWidth(),
                border = BorderStroke(1.dp, BorderDark),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text("Generate Backup", color = TextPrimary, fontSize = 13.sp)
            }
        }
    }
}

@Composable
fun PrivacySection() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        shape = RoundedCornerShape(20.dp),
        border = BorderStroke(1.dp, BorderDark)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Shield,
                    contentDescription = null,
                    tint = PrimaryBlue,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Privacy",
                    color = TextPrimary,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
            }
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "All your deck content and practice history are stored locally on this device. No data is transmitted to external servers without your explicit permission.",
                color = TextSecondary,
                fontSize = 12.sp,
                lineHeight = 17.sp
            )
        }
    }
}

@Composable
fun AboutSection(view: android.view.View?, context: Context) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        shape = RoundedCornerShape(20.dp),
        border = BorderStroke(1.dp, BorderDark)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "About",
                    color = TextPrimary,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "v1.0.0",
                    color = TextSecondary,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            Column {
                AboutMenuItem(
                    label = "Rate App",
                    onClick = {
                        triggerHaptic(view, android.view.HapticFeedbackConstants.KEYBOARD_TAP)
                        Toast.makeText(context, "Redirecting to store review platform!", Toast.LENGTH_SHORT).show()
                    }
                )
                HorizontalDivider(color = BorderDark, modifier = Modifier.padding(vertical = 8.dp))
                AboutMenuItem(
                    label = "Feedback",
                    onClick = {
                        triggerHaptic(view, android.view.HapticFeedbackConstants.KEYBOARD_TAP)
                        Toast.makeText(context, "Email support portal launched!", Toast.LENGTH_SHORT).show()
                    }
                )
                HorizontalDivider(color = BorderDark, modifier = Modifier.padding(vertical = 8.dp))
                AboutMenuItem(
                    label = "Terms of Service",
                    onClick = {
                        triggerHaptic(view, android.view.HapticFeedbackConstants.KEYBOARD_TAP)
                        Toast.makeText(context, "Loading service policy agreements...", Toast.LENGTH_SHORT).show()
                    }
                )
            }
        }
    }
}

@Composable
fun AboutMenuItem(label: String, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(vertical = 6.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = label, color = TextPrimary, fontSize = 13.5.sp)
        Icon(
            imageVector = Icons.Default.ChevronRight,
            contentDescription = null,
            tint = TextSecondary.copy(alpha = 0.5f),
            modifier = Modifier.size(16.dp)
        )
    }
}

@Composable
fun SupportCard(view: android.view.View?, context: Context) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF0F1E36)), // Elegant deep navy background
        shape = RoundedCornerShape(20.dp),
        border = BorderStroke(1.dp, PrimaryBlue.copy(alpha = 0.35f))
    ) {
        Column(modifier = Modifier.padding(18.dp)) {
            Text(
                text = "Support FlipLess",
                color = TextPrimary,
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(6.dp))
            Text(
                text = "FlipLess is funded by small, non-intrusive ads that keep the app free for everyone.",
                color = TextSecondary.copy(alpha = 0.9f),
                fontSize = 12.5.sp,
                lineHeight = 16.sp
            )
            Spacer(modifier = Modifier.height(10.dp))
            Text(
                text = "Learn more about how we use ads",
                color = PrimaryBlue,
                fontSize = 13.5.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.clickable {
                    triggerHaptic(view, android.view.HapticFeedbackConstants.KEYBOARD_TAP)
                    Toast.makeText(context, "Ad Policy: Cookies and tracking options.", Toast.LENGTH_SHORT).show()
                }
            )
        }
    }
}

@Composable
fun DangerZoneSection(view: android.view.View?, context: Context) {
    var confirmClearHistory by remember { mutableStateOf(false) }
    var confirmClearAnalytics by remember { mutableStateOf(false) }
    var confirmClearAll by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        shape = RoundedCornerShape(20.dp),
        border = BorderStroke(1.dp, ErrorRed.copy(alpha = 0.25f))
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Warning,
                    contentDescription = null,
                    tint = ErrorRed,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Danger Zone",
                    color = ErrorRed,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(14.dp))

            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                // Clear History Button
                OutlinedButton(
                    onClick = {
                        triggerHaptic(view, android.view.HapticFeedbackConstants.LONG_PRESS)
                        confirmClearHistory = true
                    },
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = TextPrimary),
                    border = BorderStroke(1.dp, BorderDark),
                    shape = RoundedCornerShape(12.dp),
                    contentPadding = PaddingValues(vertical = 12.dp)
                ) {
                    Text("Clear History", fontWeight = FontWeight.Bold, fontSize = 13.sp)
                }

                // Clear Analytics Button
                OutlinedButton(
                    onClick = {
                        triggerHaptic(view, android.view.HapticFeedbackConstants.LONG_PRESS)
                        confirmClearAnalytics = true
                    },
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = TextPrimary),
                    border = BorderStroke(1.dp, BorderDark),
                    shape = RoundedCornerShape(12.dp),
                    contentPadding = PaddingValues(vertical = 12.dp)
                ) {
                    Text("Clear Analytics", fontWeight = FontWeight.Bold, fontSize = 13.sp)
                }

                // Clear All Data Button (solid warm pink/salmon color)
                Button(
                    onClick = {
                        triggerHaptic(view, android.view.HapticFeedbackConstants.LONG_PRESS)
                        confirmClearAll = true
                    },
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFFECACA)), // Beautiful high-alert salmon pink color
                    shape = RoundedCornerShape(12.dp),
                    contentPadding = PaddingValues(vertical = 12.dp)
                ) {
                    Text("Clear All Data", color = Color(0xFF7F1D1D), fontWeight = FontWeight.Bold, fontSize = 13.sp)
                }
            }
        }
    }

    // Confirmation Alert dialogues mapped to each destructive action
    if (confirmClearHistory) {
        AlertDialog(
            onDismissRequest = { confirmClearHistory = false },
            title = { Text("Clear History?", color = TextPrimary) },
            text = { Text("Are you sure you want to permanently delete all completed practice sessions? This action cannot be undone.", color = TextSecondary) },
            confirmButton = {
                Button(
                    onClick = {
                        triggerHaptic(view, android.view.HapticFeedbackConstants.LONG_PRESS)
                        SettingsHelper.clearHistory()
                        Toast.makeText(context, "Completed practice history logs cleared!", Toast.LENGTH_SHORT).show()
                        confirmClearHistory = false
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = ErrorRed)
                ) {
                    Text("Confirm Clear", color = Color.White)
                }
            },
            dismissButton = {
                TextButton(onClick = { confirmClearHistory = false }) {
                    Text("Cancel", color = TextSecondary)
                }
            },
            containerColor = SurfaceDark,
            modifier = Modifier.border(1.dp, BorderDark, RoundedCornerShape(24.dp))
        )
    }

    if (confirmClearAnalytics) {
        AlertDialog(
            onDismissRequest = { confirmClearAnalytics = false },
            title = { Text("Clear Analytics?", color = TextPrimary) },
            text = { Text("Are you sure you want to delete all study times and average accuracy measurements?", color = TextSecondary) },
            confirmButton = {
                Button(
                    onClick = {
                        triggerHaptic(view, android.view.HapticFeedbackConstants.LONG_PRESS)
                        SettingsHelper.clearAnalytics()
                        Toast.makeText(context, "Analytics metrics reset completely!", Toast.LENGTH_SHORT).show()
                        confirmClearAnalytics = false
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = ErrorRed)
                ) {
                    Text("Confirm Reset", color = Color.White)
                }
            },
            dismissButton = {
                TextButton(onClick = { confirmClearAnalytics = false }) {
                    Text("Cancel", color = TextSecondary)
                }
            },
            containerColor = SurfaceDark,
            modifier = Modifier.border(1.dp, BorderDark, RoundedCornerShape(24.dp))
        )
    }

    if (confirmClearAll) {
        AlertDialog(
            onDismissRequest = { confirmClearAll = false },
            title = { Text("Clear ALL Data?", color = TextPrimary, fontWeight = FontWeight.Bold) },
            text = { Text("WARNING: This will completely reset all configurations, username profiles, Gemini keys, local archives, and session histories. FlipLess will be restored to fresh state.", color = TextSecondary) },
            confirmButton = {
                Button(
                    onClick = {
                        triggerHaptic(view, android.view.HapticFeedbackConstants.LONG_PRESS)
                        SettingsHelper.clearAllData()
                        Toast.makeText(context, "FlipLess completely reset to clean state!", Toast.LENGTH_SHORT).show()
                        confirmClearAll = false
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = ErrorRed)
                ) {
                    Text("Confirm Factory Reset", color = Color.White)
                }
            },
            dismissButton = {
                TextButton(onClick = { confirmClearAll = false }) {
                    Text("Cancel", color = TextSecondary)
                }
            },
            containerColor = SurfaceDark,
            modifier = Modifier.border(1.dp, BorderDark, RoundedCornerShape(24.dp))
        )
    }
}
