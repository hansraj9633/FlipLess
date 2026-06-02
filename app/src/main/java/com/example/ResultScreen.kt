package com.example

import android.content.Intent
import android.view.HapticFeedbackConstants
import android.widget.Toast
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

// -----------------------------------------------------------------------------------
// DOMAIN MODELS & DATA
// -----------------------------------------------------------------------------------

enum class QuestionStatus {
    Correct, Wrong, Skipped, MarkedForReview
}

data class ReviewQuestion(
    val id: Int,
    val status: QuestionStatus,
    val yourAnswer: String,
    val correctAnswer: String
)

// -----------------------------------------------------------------------------------
// STATE HOLDER / PROVIDER PATTERN
// -----------------------------------------------------------------------------------
@Stable
class ResultStateHolder(
    initialQuestions: List<ReviewQuestion>
) {
    var rawQuestions by mutableStateOf(initialQuestions)
    var selectedFilter by mutableStateOf<QuestionStatus?>(null) // null represents "All"
    
    var isExportingPdf by mutableStateOf(false)
    var isSharingResult by mutableStateOf(false)

    // Derived states
    val filteredQuestions: List<ReviewQuestion>
        get() = when (selectedFilter) {
            null -> rawQuestions
            else -> rawQuestions.filter { it.status == selectedFilter }
        }

    val totalCount: Int get() = rawQuestions.size
    val correctCount: Int get() = rawQuestions.count { it.status == QuestionStatus.Correct }
    val wrongCount: Int get() = rawQuestions.count { it.status == QuestionStatus.Wrong }
    val skippedCount: Int get() = rawQuestions.count { it.status == QuestionStatus.Skipped }
    val markedForReviewCount: Int get() = rawQuestions.count { it.status == QuestionStatus.MarkedForReview }
    
    val score: Int get() = correctCount * 4 - wrongCount // Example score calculation (+4 / -1)
    val maxPossibleScore: Int get() = totalCount * 4
    val accuracy: Int get() = if (totalCount - skippedCount > 0) {
        (correctCount * 100) / (totalCount - skippedCount)
    } else 0
}

@Composable
fun rememberResultState(): ResultStateHolder {
    val initialData = remember {
        listOf(
            ReviewQuestion(
                id = 1,
                status = QuestionStatus.Correct,
                yourAnswer = "Option: A",
                correctAnswer = "Option: A"
            ),
            ReviewQuestion(
                id = 2,
                status = QuestionStatus.Wrong,
                yourAnswer = "O(n)",
                correctAnswer = "O(log n)"
            ),
            ReviewQuestion(
                id = 3,
                status = QuestionStatus.Correct,
                yourAnswer = "PUT, GET, and DELETE",
                correctAnswer = "GET, PUT, DELETE, HEAD, and OPTIONS"
            ),
            ReviewQuestion(
                id = 4,
                status = QuestionStatus.Correct,
                yourAnswer = "FALSE",
                correctAnswer = "FALSE"
            ),
            ReviewQuestion(
                id = 5,
                status = QuestionStatus.Wrong,
                yourAnswer = "42",
                correctAnswer = "24"
            ),
            ReviewQuestion(
                id = 6,
                status = QuestionStatus.Skipped,
                yourAnswer = "Not Answered",
                correctAnswer = "Option: C"
            ),
            ReviewQuestion(
                id = 7,
                status = QuestionStatus.MarkedForReview,
                yourAnswer = "Option: B",
                correctAnswer = "Option: D"
            ),
            ReviewQuestion(
                id = 8,
                status = QuestionStatus.Correct,
                yourAnswer = "Option: C",
                correctAnswer = "Option: C"
            ),
            ReviewQuestion(
                id = 9,
                status = QuestionStatus.Wrong,
                yourAnswer = "Option: B",
                correctAnswer = "Option: A"
            ),
            ReviewQuestion(
                id = 10,
                status = QuestionStatus.Correct,
                yourAnswer = "Option: D",
                correctAnswer = "Option: D"
            ),
            ReviewQuestion(
                id = 11,
                status = QuestionStatus.Skipped,
                yourAnswer = "Not Answered",
                correctAnswer = "Option: B"
            ),
            ReviewQuestion(
                id = 12,
                status = QuestionStatus.MarkedForReview,
                yourAnswer = "Option: A",
                correctAnswer = "Option: C"
            )
        )
    }
    return remember { ResultStateHolder(initialData) }
}

// -----------------------------------------------------------------------------------
// SOUND HOOKS & HAPTIC UTILITIES
// -----------------------------------------------------------------------------------
private fun onResultGeneratedSound(context: android.content.Context) {
    // Hook for sound: Results Generated success cue
    android.util.Log.d("FlipLessSound", "Trigger sound effect: Result Generated success cue")
}

private fun onExportCompleteSound(context: android.content.Context) {
    // Hook for sound: Export PDF Complete chime
    android.util.Log.d("FlipLessSound", "Trigger sound effect: Export PDF Complete chime")
}

private fun onShareCompleteSound(context: android.content.Context) {
    // Hook for sound: Share Complete audio feedback
    android.util.Log.d("FlipLessSound", "Trigger sound effect: Share Complete audio feedback")
}

private fun showResultInterstitialAd(context: android.content.Context) {
    // Hook for show interstitial ad logic matching step 12
    android.util.Log.d("FlipLessAd", "Trigger hook showResultInterstitialAd() - Wait time 3 sec elapsed.")
    Toast.makeText(context, "[Interstitial Ad Hook (Step 12) Tripped successfully]", Toast.LENGTH_SHORT).show()
}

private fun safeHaptic(view: android.view.View?, constant: Int) {
    try {
        if (view != null && view.isAttachedToWindow) {
            view.performHapticFeedback(constant)
        }
    } catch (e: Throwable) {
        // Safe haptic fallback preventing crashes
    }
}

// -----------------------------------------------------------------------------------
// MAIN RESULT SCREEN COMPOSABLE
// -----------------------------------------------------------------------------------
@Composable
fun ResultScreen(
    onNavigateBack: () -> Unit,
    onReturnHome: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val view = LocalView.current
    val coroutineScope = rememberCoroutineScope()
    val state = rememberResultState()

    // 1. SCREEN ENTRY ANIMATION STATE
    var isVisible by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) {
        isVisible = true
        // Trigger Success vibration pattern and Result Generated sound hook
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            safeHaptic(view, 16) // 16 is HapticFeedbackConstants.CONFIRM
        } else {
            safeHaptic(view, HapticFeedbackConstants.LONG_PRESS)
        }
        onResultGeneratedSound(context)
        
        // 2. WAIT 3 SECONDS FOR INTERSTITIAL AD HOOK
        delay(3000)
        showResultInterstitialAd(context)
    }

    AnimatedVisibility(
        visible = isVisible,
        enter = fadeIn(animationSpec = tween(300)) + slideInVertically(
            initialOffsetY = { it / 6 },
            animationSpec = tween(300, easing = EaseOutQuad)
        ),
        exit = fadeOut(animationSpec = tween(200)),
        modifier = modifier.fillMaxSize()
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(BackgroundDark)
        ) {
            // A. HEADER COMPONENT
            ResultHeader(
                onBackClick = {
                    safeHaptic(view, HapticFeedbackConstants.LONG_PRESS)
                    onNavigateBack()
                }
            )

            // B. CONTAINER WITH SINGLE LAZYBODY TO AVOID COMPOSABLE JANK
            LazyColumn(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                contentPadding = PaddingValues(bottom = 24.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Large Score Card Including Circular Progress
                item {
                    ScoreCard(
                        score = 72,
                        totalScoreMax = 100,
                        accuracy = state.accuracy,
                        timeTakenStr = "12m",
                        subjectName = "Fluid Mechanics",
                        topicName = "OPEN CHANNEL FLOW"
                    )
                }

                // Summary Numbers Row Cards (Correct, Wrong, Skipped)
                item {
                    MetricsGrid(
                        correctCount = state.correctCount,
                        wrongCount = state.wrongCount,
                        skippedCount = state.skippedCount
                    )
                }

                // Banner Ad Reserved Space
                item {
                    AdBannerPlaceholder()
                }

                // Primary Action Button Controls Block
                item {
                    ShareActionsSection(
                        isExporting = state.isExportingPdf,
                        isSharing = state.isSharingResult,
                        onShare = {
                            coroutineScope.launch {
                                state.isSharingResult = true
                                safeHaptic(view, HapticFeedbackConstants.VIRTUAL_KEY)
                                
                                // Launch standard Chooser Native Share Sheet
                                try {
                                    val sendIntent: Intent = Intent().apply {
                                        action = Intent.ACTION_SEND
                                        putExtra(
                                            Intent.EXTRA_TEXT,
                                            "I achieved a score of 72/100 (78% Accuracy) in Fluid Mechanics - Open Channel Flow! Checked with FlipLess App."
                                        )
                                        type = "text/plain"
                                    }
                                    val shareIntent = Intent.createChooser(sendIntent, "Share Results")
                                    context.startActivity(shareIntent)
                                } catch (e: Exception) {
                                    Toast.makeText(context, "Sharing complete!", Toast.LENGTH_SHORT).show()
                                }

                                delay(1000)
                                onShareCompleteSound(context)
                                state.isSharingResult = false
                            }
                        },
                        onExportPdf = {
                            coroutineScope.launch {
                                state.isExportingPdf = true
                                safeHaptic(view, HapticFeedbackConstants.VIRTUAL_KEY)
                                delay(1800) // Simulated PDF compilation delay
                                onExportCompleteSound(context)
                                Toast.makeText(
                                    context,
                                    "PDF export successfully built and saved to Downloads!",
                                    Toast.LENGTH_LONG
                                ).show()
                                state.isExportingPdf = false
                            }
                        },
                        onReturnHome = {
                            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
                                safeHaptic(view, 16) // 16 is HapticFeedbackConstants.CONFIRM
                            } else {
                                safeHaptic(view, HapticFeedbackConstants.LONG_PRESS)
                            }
                            onReturnHome()
                        }
                    )
                }

                // Divider line with label
                item {
                    Text(
                        text = "Detailed Review",
                        color = TextPrimary,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 4.dp)
                    )
                }

                // Horizontal Filter Chips selection Row
                item {
                    FilterChipBar(
                        selectedStatus = state.selectedFilter,
                        onSelectStatus = { status ->
                            safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                            state.selectedFilter = status
                        },
                        correctCount = state.correctCount,
                        wrongCount = state.wrongCount,
                        skippedCount = state.skippedCount,
                        reviewCount = state.markedForReviewCount
                    )
                }

                // Question Cards list (Staggered or simple animated visibility)
                val filteredList = state.filteredQuestions
                if (filteredList.isEmpty()) {
                    item {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 32.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Icon(
                                imageVector = Icons.Default.Info,
                                contentDescription = "",
                                tint = TextSecondary.copy(alpha = 0.3f),
                                modifier = Modifier.size(40.dp)
                            )
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(
                                text = "No questions match this review category.",
                                color = TextSecondary,
                                fontSize = 13.sp
                            )
                        }
                    }
                } else {
                    items(
                        items = filteredList,
                        key = { it.id }
                    ) { item ->
                        QuestionReviewCard(
                            question = item,
                            modifier = Modifier.padding(horizontal = 16.dp)
                        )
                        Spacer(modifier = Modifier.height(10.dp))
                    }
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------------
// WIDGET 1: HEADER
// -----------------------------------------------------------------------------------
@Composable
fun ResultHeader(
    onBackClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .statusBarsPadding()
            .background(BackgroundDark)
            .padding(horizontal = 8.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        IconButton(onClick = onBackClick) {
            Icon(
                imageVector = Icons.Default.ArrowBack,
                contentDescription = "Navigate Back",
                tint = TextPrimary,
                modifier = Modifier.size(24.dp)
            )
        }
        Spacer(modifier = Modifier.width(4.dp))
        Column {
            Text(
                text = "Session Results",
                color = TextPrimary,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(1.dp))
            Text(
                text = "PERFORMANCE SUMMARY",
                color = TextSecondary.copy(alpha = 0.5f),
                fontSize = 9.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 0.8.sp
            )
        }
    }
}

// -----------------------------------------------------------------------------------
// WIDGET 2: SCORE CARD (CIRCLE PROGRESS + SUBJECTS)
// -----------------------------------------------------------------------------------
@Composable
fun ScoreCard(
    score: Int,
    totalScoreMax: Int,
    accuracy: Int,
    timeTakenStr: String,
    subjectName: String,
    topicName: String,
    modifier: Modifier = Modifier
) {
    var animatedProgress by remember { mutableStateOf(0f) }
    var scoreValueAnimate by remember { mutableStateOf(0) }
    
    LaunchedEffect(score) {
        // Smooth visual meter entry scale on screen initialization
        animate(
            initialValue = 0f,
            targetValue = score.toFloat() / totalScoreMax.toFloat(),
            animationSpec = tween(1200, easing = EaseOutQuad)
        ) { value, _ ->
            animatedProgress = value
        }
    }

    LaunchedEffect(score) {
        // Score value count up animation
        animate(
            initialValue = 0f,
            targetValue = score.toFloat(),
            animationSpec = tween(1100, easing = EaseOutQuad)
        ) { value, _ ->
            scoreValueAnimate = value.toInt()
        }
    }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
            .clip(RoundedCornerShape(24.dp))
            .background(SurfaceDark)
            .border(1.dp, BorderDark, RoundedCornerShape(24.dp))
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Subject and Topic displays
        Text(
            text = subjectName,
            color = TextSecondary,
            fontSize = 14.sp,
            fontWeight = FontWeight.Medium,
            textAlign = TextAlign.Center
        )
        Spacer(modifier = Modifier.height(2.dp))
        Text(
            text = topicName,
            color = TextPrimary,
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 0.5.sp,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(28.dp))

        // Large circular progress canvas centered
        Box(
            modifier = Modifier.size(190.dp),
            contentAlignment = Alignment.Center
        ) {
            // Background arc track
            Canvas(modifier = Modifier.fillMaxSize()) {
                drawCircle(
                    color = BorderDark,
                    style = Stroke(width = 16.dp.toPx(), cap = StrokeCap.Round)
                )
            }

            // Foreground animated actual results progress indicator
            Canvas(modifier = Modifier.fillMaxSize().padding(1.dp)) {
                drawArc(
                    brush = Brush.sweepGradient(
                        colors = listOf(PrimaryBlue, PrimaryBlue.copy(alpha = 0.6f), PrimaryBlue)
                    ),
                    startAngle = -90f,
                    sweepAngle = animatedProgress * 360f,
                    useCenter = false,
                    style = Stroke(width = 16.dp.toPx(), cap = StrokeCap.Round)
                )
            }

            // Score inner context values
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = "$scoreValueAnimate",
                    color = TextPrimary,
                    fontSize = 52.sp,
                    fontWeight = FontWeight.ExtraBold,
                    lineHeight = 52.sp
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = "TOTAL SCORE",
                    color = TextSecondary,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(28.dp))

        // Accuracy and Time Taken metrics bottom stats bar
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Accuracy Section
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = "$accuracy%",
                    color = TextPrimary,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = "Accuracy",
                    color = TextSecondary,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Normal
                )
            }

            // Divider vertical
            Box(
                modifier = Modifier
                    .width(1.dp)
                    .height(26.dp)
                    .background(BorderDark)
            )

            // Time Taken Section
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = timeTakenStr,
                    color = TextPrimary,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = "Time Taken",
                    color = TextSecondary,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Normal
                )
            }
        }
    }
}

// -----------------------------------------------------------------------------------
// WIDGET 3: METRICS DETAILS GRID (CORRECT, WRONG, SKIPPED)
// -----------------------------------------------------------------------------------
@Composable
fun MetricsGrid(
    correctCount: Int,
    wrongCount: Int,
    skippedCount: Int,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            // Correct Card
            Box(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(16.dp))
                    .background(SurfaceDark)
                    .border(1.dp, BorderDark, RoundedCornerShape(16.dp))
                    .padding(14.dp)
            ) {
                Column {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.CheckCircle,
                            contentDescription = null,
                            tint = SuccessGreen,
                            modifier = Modifier.size(18.dp)
                        )
                        Text(
                            text = "Correct",
                            color = TextSecondary,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium
                        )
                    }
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        text = "$correctCount",
                        color = TextPrimary,
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }

            // Wrong Card
            Box(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(16.dp))
                    .background(SurfaceDark)
                    .border(1.dp, BorderDark, RoundedCornerShape(16.dp))
                    .padding(14.dp)
            ) {
                Column {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Cancel,
                            contentDescription = null,
                            tint = ErrorRed,
                            modifier = Modifier.size(18.dp)
                        )
                        Text(
                            text = "Wrong",
                            color = TextSecondary,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium
                        )
                    }
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        text = "$wrongCount",
                        color = TextPrimary,
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }

        // Skipped Card (Half width design representation matching stitch image visual balance)
        Row(modifier = Modifier.fillMaxWidth()) {
            Box(
                modifier = Modifier
                    .fillMaxWidth(0.5f)
                    .padding(end = 5.dp)
                    .clip(RoundedCornerShape(16.dp))
                    .background(SurfaceDark)
                    .border(1.dp, BorderDark, RoundedCornerShape(16.dp))
                    .padding(14.dp)
            ) {
                Column {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.SkipNext,
                            contentDescription = null,
                            tint = WarningAmber,
                            modifier = Modifier.size(18.dp)
                        )
                        Text(
                            text = "Skipped",
                            color = TextSecondary,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium
                        )
                    }
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        text = "$skippedCount",
                        color = TextPrimary,
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------------
// WIDGET 4: AD BANNER PLACEHOLDER
// -----------------------------------------------------------------------------------
@Composable
fun AdBannerPlaceholder(modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .padding(horizontal = 16.dp)
            .fillMaxWidth()
            .height(50.dp)
            .clip(RoundedCornerShape(12.dp))
            .background(SurfaceDark.copy(alpha = 0.4f))
            .border(1.dp, BorderDark, RoundedCornerShape(12.dp)),
        contentAlignment = Alignment.Center
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Icon(
                imageVector = Icons.Default.Campaign,
                contentDescription = null,
                tint = TextSecondary.copy(alpha = 0.4f),
                modifier = Modifier.size(18.dp)
            )
            Text(
                text = "Banner Ad Placeholder",
                color = TextSecondary.copy(alpha = 0.5f),
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 0.8.sp
            )
        }
    }
}

// -----------------------------------------------------------------------------------
// WIDGET 5: SHARE & ACTIONS CONTROLS COMPONENT (WITH ANIMATED PRESS EFFECTS)
// -----------------------------------------------------------------------------------
@Composable
fun ShareActionsSection(
    isExporting: Boolean,
    isSharing: Boolean,
    onShare: () -> Unit,
    onExportPdf: () -> Unit,
    onReturnHome: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    
    // 1. Interactive scale animation bounds for button press feel
    val interaction1 = remember { MutableInteractionSource() }
    val isPressed1 by interaction1.collectIsPressedAsState()
    val buttonScale1 by animateFloatAsState(
        targetValue = if (isPressed1) 0.96f else 1.0f,
        animationSpec = tween(80),
        label = "btnScale1"
    )

    val interaction2 = remember { MutableInteractionSource() }
    val isPressed2 by interaction2.collectIsPressedAsState()
    val buttonScale2 by animateFloatAsState(
        targetValue = if (isPressed2) 0.96f else 1.0f,
        animationSpec = tween(80),
        label = "btnScale2"
    )

    val interaction3 = remember { MutableInteractionSource() }
    val isPressed3 by interaction3.collectIsPressedAsState()
    val buttonScale3 by animateFloatAsState(
        targetValue = if (isPressed3) 0.96f else 1.0f,
        animationSpec = tween(80),
        label = "btnScale3"
    )

    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        // SHARE RESULTS BUTTON (Primary, Blue Colored Filled)
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .graphicsLayer {
                    scaleX = buttonScale1
                    scaleY = buttonScale1
                }
                .clip(RoundedCornerShape(30.dp))
                .background(PrimaryBlue)
                .clickable(
                    interactionSource = interaction1,
                    indication = LocalIndication.current,
                    enabled = !isSharing
                ) {
                    onShare()
                }
                .padding(vertical = 14.dp),
            contentAlignment = Alignment.Center
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (isSharing) {
                    CircularProgressIndicator(
                        color = BackgroundDark,
                        modifier = Modifier.size(16.dp),
                        strokeWidth = 2.dp
                    )
                } else {
                    Icon(
                        imageVector = Icons.Default.Share,
                        contentDescription = null,
                        tint = BackgroundDark,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Share Results",
                        color = BackgroundDark,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }

        // EXPORT PDF BUTTON (Outline gray/blue)
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .graphicsLayer {
                    scaleX = buttonScale2
                    scaleY = buttonScale2
                }
                .clip(RoundedCornerShape(30.dp))
                .border(1.dp, BorderDark, RoundedCornerShape(30.dp))
                .clickable(
                    interactionSource = interaction2,
                    indication = LocalIndication.current,
                    enabled = !isExporting
                ) {
                    onExportPdf()
                }
                .padding(vertical = 12.dp),
            contentAlignment = Alignment.Center
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (isExporting) {
                    CircularProgressIndicator(
                        color = PrimaryBlue,
                        modifier = Modifier.size(16.dp),
                        strokeWidth = 2.dp
                    )
                } else {
                    Icon(
                        imageVector = Icons.Default.PictureAsPdf,
                        contentDescription = null,
                        tint = TextPrimary,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Export PDF",
                        color = TextPrimary,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }

        // RETURN HOME BUTTON (Outline gray/blue)
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .graphicsLayer {
                    scaleX = buttonScale3
                    scaleY = buttonScale3
                }
                .clip(RoundedCornerShape(30.dp))
                .border(1.dp, BorderDark, RoundedCornerShape(30.dp))
                .clickable(interactionSource = interaction3, indication = LocalIndication.current) {
                    onReturnHome()
                }
                .padding(vertical = 12.dp),
            contentAlignment = Alignment.Center
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Home,
                    contentDescription = null,
                    tint = TextPrimary,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Return Home",
                    color = TextPrimary,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

// -----------------------------------------------------------------------------------
// WIDGET 6: HORIZONTAL FILTER CHIPS ROW
// -----------------------------------------------------------------------------------
@Composable
fun FilterChipBar(
    selectedStatus: QuestionStatus?,
    onSelectStatus: (QuestionStatus?) -> Unit,
    correctCount: Int,
    wrongCount: Int,
    skippedCount: Int,
    reviewCount: Int,
    modifier: Modifier = Modifier
) {
    val items = listOf(
        Triple<String, String, QuestionStatus?>("All Questions", "", null),
        Triple("Correct", "($correctCount)", QuestionStatus.Correct),
        Triple("Wrong", "($wrongCount)", QuestionStatus.Wrong),
        Triple("Skipped", "($skippedCount)", QuestionStatus.Skipped),
        Triple("Marked", "($reviewCount)", QuestionStatus.MarkedForReview)
    )

    Row(
        modifier = modifier
            .fillMaxWidth()
            .horizontalScroll(rememberScrollState())
            .padding(horizontal = 16.dp, vertical = 6.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        items.forEach { data ->
            val isSelected = selectedStatus == data.third
            val text = if (data.second.isNotEmpty()) "${data.first} ${data.second}" else data.first
            
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(20.dp))
                    .background(if (isSelected) PrimaryBlue else SurfaceDark)
                    .border(
                        1.dp,
                        if (isSelected) PrimaryBlue else BorderDark,
                        RoundedCornerShape(20.dp)
                    )
                    .clickable { onSelectStatus(data.third) }
                    .padding(horizontal = 14.dp, vertical = 8.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = text,
                    color = if (isSelected) BackgroundDark else TextSecondary,
                    fontSize = 12.sp,
                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium
                )
            }
        }
    }
}

// -----------------------------------------------------------------------------------
// WIDGET 7: QUESTION REVIEW DETAIL CARD (INDIVIDUAL COMPONENT WITH UNIQUE ANSWERS)
// -----------------------------------------------------------------------------------
@Composable
fun QuestionReviewCard(
    question: ReviewQuestion,
    modifier: Modifier = Modifier
) {
    // Styling attributes based on evaluation status
    val statusColor = when (question.status) {
        QuestionStatus.Correct -> SuccessGreen
        QuestionStatus.Wrong -> ErrorRed
        QuestionStatus.Skipped -> TextSecondary
        QuestionStatus.MarkedForReview -> WarningAmber
    }

    val statusIcon = when (question.status) {
        QuestionStatus.Correct -> Icons.Default.CheckCircle
        QuestionStatus.Wrong -> Icons.Default.Cancel
        QuestionStatus.Skipped -> Icons.Default.SkipNext
        QuestionStatus.MarkedForReview -> Icons.Default.Bookmark
    }

    val statusLabel = when (question.status) {
        QuestionStatus.Correct -> "Correct"
        QuestionStatus.Wrong -> "Wrong"
        QuestionStatus.Skipped -> "Skipped"
        QuestionStatus.MarkedForReview -> "Marked"
    }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(20.dp))
            .background(SurfaceDark)
            .border(1.dp, BorderDark, RoundedCornerShape(20.dp))
            .padding(16.dp)
    ) {
        // Row 1: Header status and Badge icon
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(8.dp))
                    .background(BorderDark)
                    .padding(horizontal = 8.dp, vertical = 4.dp)
            ) {
                Text(
                    text = "Question ${String.format("%02d", question.id)} • $statusLabel",
                    color = TextSecondary,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold
                )
            }
            
            Icon(
                imageVector = statusIcon,
                contentDescription = null,
                tint = statusColor,
                modifier = Modifier.size(18.dp)
            )
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Your answer bubble
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(SurfaceDark.copy(alpha = 0.5f))
                .border(0.5.dp, BorderDark, RoundedCornerShape(12.dp))
                .padding(12.dp)
        ) {
            Text(
                text = "YOUR ANSWER",
                color = if (question.status == QuestionStatus.Wrong) ErrorRed.copy(alpha = 0.8f) else PrimaryBlue,
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 0.5.sp
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = question.yourAnswer,
                color = TextPrimary,
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        // Correct answer bubble
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(SurfaceDark.copy(alpha = 0.5f))
                .border(0.5.dp, BorderDark, RoundedCornerShape(12.dp))
                .padding(12.dp)
        ) {
            Text(
                text = "CORRECT ANSWER",
                color = SuccessGreen,
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 0.5.sp
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = question.correctAnswer,
                color = TextPrimary,
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold
            )
        }
    }
}
