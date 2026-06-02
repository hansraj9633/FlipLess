package com.example

import android.os.Bundle
import android.view.HapticFeedbackConstants
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
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
import androidx.compose.ui.draw.blur
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
import com.example.ui.theme.*

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        SettingsHelper.init(this)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                Scaffold(
                    modifier = Modifier.fillMaxSize(),
                    containerColor = BackgroundDark
                ) { innerPadding ->
                    FlipLessAppContent(
                        modifier = Modifier.padding(innerPadding)
                    )
                }
            }
        }
    }
}

private fun safeHaptic(view: android.view.View?, constant: Int) {
    try {
        if (view != null && view.isAttachedToWindow) {
            view.performHapticFeedback(constant)
        }
    } catch (e: Throwable) {
        // Prevent haptic platform exceptions from crashing the app
    }
}

@Composable
fun FlipLessAppContent(modifier: Modifier = Modifier) {
    // Current Active Tab in Bottom Navigation
    var selectedTab by remember { mutableStateOf("home") } // "home", "history", "analytics", "settings"
    
    // Sub-screen under history tab ("list" -> History screen, "verify" -> Verification screen, "results" -> Rewarding Result screen)
    var currentHistoryScreen by remember { mutableStateOf("list") }

    // Support toggle to showcase Empty State ("No active sessions")
    var hasDraftSessions by remember { mutableStateOf(true) }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(BackgroundDark)
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            // Main content box taking up the upper part
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
            ) {
                when (selectedTab) {
                    "home" -> HomeTabScreen(
                        hasDrafts = hasDraftSessions,
                        onToggleDrafts = { hasDraftSessions = !hasDraftSessions },
                        onCreateSession = { 
                            currentHistoryScreen = "verify"
                            selectedTab = "history" 
                        }
                    )
                    "history" -> {
                        when (currentHistoryScreen) {
                            "list" -> HistoryScreen(
                                onNavigateBack = { selectedTab = "home" },
                                onOpenResult = { _ ->
                                    currentHistoryScreen = "results"
                                }
                            )
                            "verify" -> VerifyAnswersScreen(
                                onNavigateBack = { currentHistoryScreen = "list" },
                                onConfirm = { currentHistoryScreen = "results" }
                            )
                            "results" -> ResultScreen(
                                onNavigateBack = { currentHistoryScreen = "list" },
                                onReturnHome = { selectedTab = "home" }
                            )
                        }
                    }
                    "analytics" -> AnalyticsTabScreen()
                    "settings" -> SettingsTabScreen()
                }
            }

            // Bottom Navigation bar
            FlipLessBottomNavBar(
                selectedTab = selectedTab,
                onTabSelected = { tab ->
                    if (tab == "history" && selectedTab != "history") {
                        currentHistoryScreen = "list"
                    }
                    selectedTab = tab
                }
            )
        }
    }
}

@Composable
fun HomeTabScreen(
    hasDrafts: Boolean,
    onToggleDrafts: () -> Unit,
    onCreateSession: () -> Unit
) {
    val view = LocalView.current
    val context = LocalContext.current

    // Entry state for fade + slide up animation
    var shown by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) {
        shown = true
    }

    // Count-up stats animation values
    val countTransition = updateTransition(targetState = shown, label = "counts")
    
    val accuracyAnimate by countTransition.animateFloat(
        transitionSpec = { tween(1000, easing = FastOutSlowInEasing) },
        label = "accuracy"
    ) { state -> if (state) 78f else 0f }

    val sessionsAnimate by countTransition.animateInt(
        transitionSpec = { tween(1100, easing = FastOutSlowInEasing) },
        label = "sessions"
    ) { state -> if (state) 125 else 0 }

    val questionsAnimate by countTransition.animateInt(
        transitionSpec = { tween(1200, easing = FastOutSlowInEasing) },
        label = "questions"
    ) { state -> if (state) 3421 else 0 }

    val studyTimeAnimate by countTransition.animateInt(
        transitionSpec = { tween(900, easing = FastOutSlowInEasing) },
        label = "studyTime"
    ) { state -> if (state) 81 else 0 }

    // Breathing Animation for floating active button
    val infiniteTransition = rememberInfiniteTransition(label = "breathe")
    val fabScale by infiniteTransition.animateFloat(
        initialValue = 1.0f,
        targetValue = 1.04f,
        animationSpec = infiniteRepeatable(
            animation = tween(1400, easing = EaseInOutQuad),
            repeatMode = RepeatMode.Reverse
        ),
        label = "fabScale"
    )

    Box(
        modifier = Modifier.fillMaxSize()
    ) {
        // Main scrollable list
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(bottom = 96.dp) // space for FAB + nav gaps
        ) {
            // 1. HEADER SECTION
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    // Circular App Avatar
                    Box(
                        modifier = Modifier
                            .size(38.dp)
                            .clip(CircleShape)
                            .background(SurfaceDark)
                            .border(1.dp, BorderDark, CircleShape)
                            .clickable {
                                safeHaptic(view, HapticFeedbackConstants.LONG_PRESS)
                            },
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            Icons.Default.MenuBook,
                            contentDescription = "Logo",
                            tint = PrimaryBlue,
                            modifier = Modifier.size(18.dp)
                        )
                    }
                    Spacer(modifier = Modifier.width(10.dp))
                    Text(
                        text = "FlipLess",
                        color = TextPrimary,
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        fontFamily = FontFamily.SansSerif
                    )
                }
                
                // Notification bell icon
                Icon(
                    Icons.Outlined.Notifications,
                    contentDescription = "Notifications",
                    tint = TextPrimary,
                    modifier = Modifier
                        .size(26.dp)
                        .clickable(
                            interactionSource = remember { MutableInteractionSource() },
                            indication = null
                        ) {
                            safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                            Toast
                                .makeText(context, "No new alerts", Toast.LENGTH_SHORT)
                                .show()
                        }
                )
            }

            // 2. GREETING SECTION
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 10.dp)
            ) {
                Text(
                    text = "Good Evening, ${SettingsHelper.studentName} 👋",
                    color = TextPrimary,
                    fontSize = 25.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = (-0.5).sp
                )
                Spacer(modifier = Modifier.height(3.dp))
                Text(
                    text = "Ready to tackle your learning goals today?",
                    color = TextSecondary,
                    fontSize = 13.5.sp,
                    fontFamily = FontFamily.SansSerif
                )
            }

            Spacer(modifier = Modifier.height(14.dp))

            // 3. STATISTICS CARD (2x2 Grid Layout)
            Box(
                modifier = Modifier
                    .padding(horizontal = 16.dp)
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(24.dp))
                    .background(SurfaceDark)
                    .border(1.dp, BorderDark, RoundedCornerShape(24.dp))
                    .padding(20.dp)
            ) {
                Column {
                    Row(modifier = Modifier.fillMaxWidth()) {
                        // ACCURACY
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = "ACCURACY",
                                color = TextSecondary,
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Bold,
                                letterSpacing = 0.8.sp
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Row(
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = "${accuracyAnimate.toInt()}%",
                                    color = TextPrimary,
                                    fontSize = 28.sp,
                                    fontWeight = FontWeight.Bold
                                )
                                Spacer(modifier = Modifier.width(3.dp))
                                Icon(
                                    Icons.Default.TrendingUp,
                                    contentDescription = "Accuracy growing",
                                    tint = PrimaryBlue,
                                    modifier = Modifier.size(15.dp)
                                )
                            }
                            Spacer(modifier = Modifier.height(8.dp))
                            // Sliding accuracy blue indicator bar
                            Box(
                                modifier = Modifier
                                    .width(110.dp)
                                    .height(3.5.dp)
                                    .clip(RoundedCornerShape(3.dp))
                                    .background(BorderDark)
                            ) {
                                Box(
                                    modifier = Modifier
                                        .fillMaxHeight()
                                        .fillMaxWidth(fraction = (accuracyAnimate / 100f).coerceIn(0f, 1f))
                                        .background(PrimaryBlue)
                                )
                            }
                        }

                        // SESSIONS
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = "SESSIONS",
                                color = TextSecondary,
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Bold,
                                letterSpacing = 0.8.sp
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = "${sessionsAnimate}",
                                color = TextPrimary,
                                fontSize = 28.sp,
                                fontWeight = FontWeight.Bold
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = "+12 this week",
                                color = TextSecondary.copy(alpha = 0.65f),
                                fontSize = 11.sp
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    Row(modifier = Modifier.fillMaxWidth()) {
                        // QUESTIONS
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = "QUESTIONS",
                                color = TextSecondary,
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Bold,
                                letterSpacing = 0.8.sp
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = formatNumber(questionsAnimate),
                                color = TextPrimary,
                                fontSize = 28.sp,
                                fontWeight = FontWeight.Bold
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = "Lifetime items",
                                color = TextSecondary.copy(alpha = 0.65f),
                                fontSize = 11.sp
                              )
                          }

                        // STUDY TIME
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = "STUDY TIME",
                                color = TextSecondary,
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Bold,
                                letterSpacing = 0.8.sp
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = "${studyTimeAnimate}h",
                                color = TextPrimary,
                                fontSize = 28.sp,
                                fontWeight = FontWeight.Bold
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = "Deep focus flow",
                                color = TextSecondary.copy(alpha = 0.65f),
                                fontSize = 11.sp
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // 4. DRAFT SESSIONS SECTION WITH TOGGLED EMPTY STATES
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 6.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = "Draft Sessions",
                        color = TextPrimary,
                        fontSize = 17.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    // Orange dot badge
                    Box(
                        modifier = Modifier
                            .size(7.dp)
                            .clip(CircleShape)
                            .background(WarningAmber)
                    )
                }

                Row(verticalAlignment = Alignment.CenterVertically) {
                    // Small click helper for developers to toggle empty state look easily
                    Text(
                        text = if (hasDrafts) "Mock Empty" else "Show Drafts",
                        color = TextSecondary.copy(alpha = 0.5f),
                        fontSize = 11.sp,
                        modifier = Modifier
                            .clickable { onToggleDrafts() }
                            .padding(horizontal = 8.dp)
                    )
                    
                    Text(
                        text = "View all",
                        color = PrimaryBlue,
                        fontSize = 13.5.sp,
                        fontWeight = FontWeight.SemiBold,
                        modifier = Modifier
                            .clickable {
                                safeHaptic(view, HapticFeedbackConstants.VIRTUAL_KEY)
                            }
                    )
                }
            }

            Spacer(modifier = Modifier.height(6.dp))

            // Draft Lists or Empty State
            if (hasDrafts) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    DraftSessionCardCompose(
                        subject = "Fluid Mechanics",
                        icon = Icons.Default.Science,
                        progress = 0.45f,
                        onClick = {
                            safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                            Toast.makeText(context, "Resuming Fluid Mechanics Companion", Toast.LENGTH_SHORT).show()
                        }
                    )
                    DraftSessionCardCompose(
                        subject = "Modern History",
                        icon = Icons.Default.Book,
                        progress = 0.12f,
                        onClick = {
                            safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                            Toast.makeText(context, "Resuming Modern History Companion", Toast.LENGTH_SHORT).show()
                        }
                    )
                }
            } else {
                // Realistic Empty State
                Box(
                    modifier = Modifier
                        .padding(horizontal = 16.dp)
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(16.dp))
                        .background(SurfaceDark)
                        .border(1.dp, BorderDark, RoundedCornerShape(16.dp))
                        .padding(24.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            Icons.Default.LibraryBooks,
                            contentDescription = "Empty",
                            tint = TextSecondary.copy(alpha = 0.35f),
                            modifier = Modifier.size(44.dp)
                        )
                        Spacer(modifier = Modifier.height(10.dp))
                        Text(
                            text = "No active sessions.",
                            color = TextPrimary,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.SemiBold
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        Button(
                            onClick = {
                                safeHaptic(view, HapticFeedbackConstants.VIRTUAL_KEY)
                                onToggleDrafts()
                            },
                            colors = ButtonDefaults.buttonColors(containerColor = PrimaryBlue),
                            shape = RoundedCornerShape(18.dp),
                            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 6.dp)
                        ) {
                            Text("Create Session", color = BackgroundDark, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // 5. BANNER AD PLACEHOLDER
            Box(
                modifier = Modifier
                    .padding(horizontal = 16.dp)
                    .fillMaxWidth()
                    .height(48.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(SurfaceDark.copy(alpha = 0.45f))
                    .border(1.dp, BorderDark, RoundedCornerShape(12.dp)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "Banner Ad Placeholder",
                    color = TextSecondary.copy(alpha = 0.6f),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 0.5.sp
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            // 6. RECENT ACTIVITY LIST CONTAINER
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 4.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = "Recent Activity",
                    color = TextPrimary,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "Full History",
                    color = PrimaryBlue,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    modifier = Modifier.clickable {
                        safeHaptic(view, HapticFeedbackConstants.VIRTUAL_KEY)
                    }
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            RecentActivityListCompose()
        }

        // 7. CREATE FLOATING SESSION BUTTON WITH PULSING GLOW
        Box(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 12.dp)
                .graphicsLayer {
                    scaleX = fabScale
                    scaleY = fabScale
                }
        ) {
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(30.dp))
                    .background(PrimaryBlue)
                    .clickable {
                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
                            safeHaptic(view, 16) // 16 is HapticFeedbackConstants.CONFIRM on API 30+
                        } else {
                            safeHaptic(view, HapticFeedbackConstants.LONG_PRESS)
                        }
                        onCreateSession()
                    }
                    .padding(horizontal = 24.dp, vertical = 13.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        Icons.Default.AddCircleOutline,
                        contentDescription = "Add",
                        tint = BackgroundDark,
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Create Session",
                        color = BackgroundDark,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = (-0.2).sp
                    )
                }
            }
        }
    }
}

@Composable
fun DraftSessionCardCompose(
    subject: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    progress: Float,
    onClick: () -> Unit
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.98f else 1.0f,
        animationSpec = tween(100),
        label = "scale"
    )

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            }
            .clip(RoundedCornerShape(16.dp))
            .background(SurfaceDark)
            .border(1.dp, BorderDark, RoundedCornerShape(16.dp))
            .clickable(interactionSource = interactionSource, indication = LocalIndication.current) {
                onClick()
            }
            .padding(horizontal = 14.dp, vertical = 13.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Icon background
        Box(
            modifier = Modifier
                .size(42.dp)
                .clip(RoundedCornerShape(10.dp))
                .background(BorderDark),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                icon,
                contentDescription = null,
                tint = TextSecondary,
                modifier = Modifier.size(20.dp)
            )
        }
        Spacer(modifier = Modifier.width(12.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = subject,
                color = TextPrimary,
                fontSize = 15.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(10.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                // Custom progress bar
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .height(4.dp)
                        .clip(RoundedCornerShape(2.dp))
                        .background(BorderDark)
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxHeight()
                            .fillMaxWidth(fraction = progress.coerceIn(0f, 1f))
                            .background(PrimaryBlue)
                    )
                }
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "${(progress * 100).toInt()}%",
                    color = TextSecondary.copy(alpha = 0.7f),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
        Spacer(modifier = Modifier.width(6.dp))
        Icon(
            Icons.Default.ChevronRight,
            contentDescription = null,
            tint = TextSecondary.copy(alpha = 0.5f),
            modifier = Modifier.size(18.dp)
        )
    }
}

@Composable
fun RecentActivityListCompose() {
    val items = remember {
        listOf(
            Triple("Calculus III", "Vector Fields", "92%"),
            Triple("Organic Chem", "Alkanes", "74%"),
            Triple("Algorithms", "Graph Theory", "88%"),
            Triple("Ethics", "Utilitarianism", "100%"),
            Triple("Microbiology", "Cell Wall", "62%")
        )
    }

    val view = LocalView.current

    Box(
        modifier = Modifier
            .padding(horizontal = 16.dp)
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(SurfaceDark)
            .border(1.dp, BorderDark, RoundedCornerShape(16.dp))
    ) {
        Column {
            // Header
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 12.dp),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = "SUBJECT",
                    color = TextSecondary,
                    fontSize = 9.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 0.8.sp
                )
                Text(
                    text = "SCORE",
                    color = TextSecondary,
                    fontSize = 9.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 0.8.sp
                )
            }
            HorizontalDivider(color = BorderDark)

            items.forEachIndexed { idx, pair ->
                val interactionSource = remember { MutableInteractionSource() }
                val isPressed by interactionSource.collectIsPressedAsState()
                val scale by animateFloatAsState(
                    targetValue = if (isPressed) 0.98f else 1f,
                    animationSpec = tween(80),
                    label = "scale"
                )

                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .graphicsLayer {
                            scaleX = scale
                            scaleY = scale
                        }
                        .clickable(interactionSource = interactionSource, indication = LocalIndication.current) {
                            safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                        }
                        .padding(horizontal = 16.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column {
                        Text(
                            text = pair.first,
                            color = TextPrimary,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = pair.second,
                            color = TextSecondary,
                            fontSize = 11.5.sp
                        )
                    }

                    val isHighPct = pair.third == "92%" || pair.third == "100%"
                    Text(
                        text = pair.third,
                        color = if (isHighPct) TextPrimary else TextSecondary,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                if (idx < items.size - 1) {
                    HorizontalDivider(color = BorderDark)
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------------
// NAV SCREEN PLACEHOLDERS FOR MULTI-TAB ARCHITECTURE RENDER
// -----------------------------------------------------------------------------------

@Composable
fun HistoryTabScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(Icons.Default.History, contentDescription = null, tint = PrimaryBlue, modifier = Modifier.size(54.dp))
        Spacer(modifier = Modifier.height(12.dp))
        Text("Practice History Logs", color = TextPrimary, fontSize = 18.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(4.dp))
        Text("Review full breakdowns of all past textbook attempts.", color = TextSecondary, textAlign = TextAlign.Center, fontSize = 13.sp)
    }
}

// SettingsTabScreen is now loaded dynamically from SettingsScreen.kt

// -----------------------------------------------------------------------------------
// CUSTOM BOTTOM NAVIGATION BAR COMPOSABLE
// -----------------------------------------------------------------------------------

@Composable
fun FlipLessBottomNavBar(
    selectedTab: String,
    onTabSelected: (String) -> Unit
) {
    val items = listOf(
        TabItem("home", "Home", Icons.Default.FactCheck, Icons.Outlined.FactCheck),
        TabItem("history", "History", Icons.Default.Timer, Icons.Outlined.Timer),
        TabItem("analytics", "Analytics", Icons.Default.BarChart, Icons.Outlined.BarChart),
        TabItem("settings", "Settings", Icons.Default.Settings, Icons.Outlined.Settings)
    )

    NavigationBar(
        containerColor = BackgroundDark,
        tonalElevation = 8.dp,
        modifier = Modifier.border(0.5.dp, BorderDark, RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp))
    ) {
        items.forEach { item ->
            val isActive = selectedTab == item.id
            val isHistoryTab = item.id == "history"
            
            NavigationBarItem(
                selected = isActive,
                onClick = { onTabSelected(item.id) },
                icon = {
                    Icon(
                        imageVector = if (isActive) item.activeIcon else item.inactiveIcon,
                        contentDescription = item.label,
                        tint = if (isActive) {
                            if (isHistoryTab) BackgroundDark else PrimaryBlue
                        } else {
                            TextSecondary
                        },
                        modifier = Modifier.size(24.dp)
                    )
                },
                colors = NavigationBarItemDefaults.colors(
                    indicatorColor = if (isActive) {
                        if (isHistoryTab) PrimaryBlue else SurfaceDark
                    } else {
                        Color.Transparent
                    }
                )
            )
        }
    }
}

data class TabItem(
    val id: String,
    val label: String,
    val activeIcon: androidx.compose.ui.graphics.vector.ImageVector,
    val inactiveIcon: androidx.compose.ui.graphics.vector.ImageVector
)

private fun formatNumber(number: Int): String {
    return if (number >= 1000) {
        val thousands = number / 1000
        val remaining = number % 1000
        "$thousands,${String.format("%03d", remaining)}"
    } else {
        number.toString()
    }
}
