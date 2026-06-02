package com.example

import android.view.HapticFeedbackConstants
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
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.*
import kotlinx.coroutines.delay

// -----------------------------------------------------------------------------------
// DATA MODELS FOR ANALYTICS SCREEN
// -----------------------------------------------------------------------------------
data class AnalyticsDataset(
    val filterName: String,
    val accuracy: Int,
    val sessionsCount: Int,
    val questionsSolved: Int,
    val studyHours: Int,
    val improvementPercent: String,
    val peakValue: Int,
    val peakDayLabel: String,
    val baselineValue: Int,
    val trendPoints: List<Float>, // mapped Mon to Sun values (typically 5 to 7 values)
    val subjects: List<SubjectAnalytics>,
    val weakSubject: WeakSubjectInfo,
    val strongSubject: StrongSubjectInfo,
    val topics: List<TopicAnalytics>,
    val recentSessions: List<RecentSessionInfo>
)

data class SubjectAnalytics(
    val name: String,
    val accuracy: Int,
    val attemptedQuestions: Int,
    val rankLabel: String
)

data class WeakSubjectInfo(
    val name: String,
    val accuracy: Int,
    val questionsCount: Int,
    val highlightDescription: String
)

data class StrongSubjectInfo(
    val name: String,
    val accuracy: Int,
    val highlightDescription: String,
    val badgeLabel: String
)

data class TopicAnalytics(
    val name: String,
    val accuracy: Int
)

data class RecentSessionInfo(
    val title: String,
    val detail: String,
    val accuracy: Int,
    val deltaText: String,
    val isWavyIcon: Boolean // waves or beaker representation
)

// -----------------------------------------------------------------------------------
// STABLE STATE HOLDER / VIEWMODEL FOR THE SCREEN
// -----------------------------------------------------------------------------------
@Stable
class AnalyticsStateHolder(
    initialDatasets: Map<String, AnalyticsDataset>
) {
    var datasets by mutableStateOf(initialDatasets)
    var selectedFilter by mutableStateOf("7 Days") // "7 Days", "30 Days", "90 Days", "All Time"
    var isSimulatingEmptyState by mutableStateOf(false)

    // Current data based on active filters
    val currentData: AnalyticsDataset
        get() = datasets[selectedFilter] ?: datasets.values.first()
}

@Composable
fun rememberAnalyticsState(): AnalyticsStateHolder {
    val initialData = remember {
        mapOf(
            "7 Days" to AnalyticsDataset(
                filterName = "7 Days",
                accuracy = 78,
                sessionsCount = 125,
                questionsSolved = 3421,
                studyHours = 81,
                improvementPercent = "+6%",
                peakValue = 81,
                peakDayLabel = "Current peak",
                baselineValue = 65,
                trendPoints = listOf(65f, 68f, 72f, 70f, 74f, 78f, 81f),
                subjects = listOf(
                    SubjectAnalytics("Fluid Mechanics", 78, 1240, "Rank #12"),
                    SubjectAnalytics("Geotechnical Eng.", 84, 890, "Rank #4"),
                    SubjectAnalytics("Surveying", 69, 540, "Rank #28")
                ),
                weakSubject = WeakSubjectInfo(
                    name = "Fluid Mechanics",
                    accuracy = 48,
                    questionsCount = 120,
                    highlightDescription = "Your accuracy in Open Channel Flow has dropped by 12% since Tuesday."
                ),
                strongSubject = StrongSubjectInfo(
                    name = "Surveying",
                    accuracy = 92,
                    highlightDescription = "Excellent mastery of Theodolite concepts. You're ready for the final mock exam.",
                    badgeLabel = "Mastery Badge Earned"
                ),
                topics = listOf(
                    TopicAnalytics("Open Channel Flow", 48),
                    TopicAnalytics("Theodolite Surveys", 92),
                    TopicAnalytics("Soil Classification", 81),
                    TopicAnalytics("Bernoulli Dynamics", 74)
                ),
                recentSessions = listOf(
                    RecentSessionInfo(
                        title = "Fluid Mechanics - Open Channel Flow",
                        detail = "Completed 2 hours ago • 45 Questions",
                        accuracy = 78,
                        deltaText = "+2% vs avg",
                        isWavyIcon = true
                    ),
                    RecentSessionInfo(
                        title = "Organic Chemistry - Alkanes",
                        detail = "Completed 5 hours ago • 30 Questions",
                        accuracy = 84,
                        deltaText = "+5% vs avg",
                        isWavyIcon = false
                    )
                )
            ),
            "30 Days" to AnalyticsDataset(
                filterName = "30 Days",
                accuracy = 74,
                sessionsCount = 410,
                questionsSolved = 11250,
                studyHours = 284,
                improvementPercent = "+8%",
                peakValue = 79,
                peakDayLabel = "Current peak",
                baselineValue = 62,
                trendPoints = listOf(62f, 66f, 64f, 70f, 72f, 75f, 79f),
                subjects = listOf(
                    SubjectAnalytics("Fluid Mechanics", 72, 4210, "Rank #15"),
                    SubjectAnalytics("Geotechnical Eng.", 79, 3120, "Rank #6"),
                    SubjectAnalytics("Surveying", 71, 2190, "Rank #22")
                ),
                weakSubject = WeakSubjectInfo(
                    name = "Geotechnical Eng.",
                    accuracy = 52,
                    questionsCount = 310,
                    highlightDescription = "Pore water pressure calculations show unstable velocity trends inside clay structures."
                ),
                strongSubject = StrongSubjectInfo(
                    name = "Fluid Mechanics",
                    accuracy = 88,
                    highlightDescription = "Superb performance in dimensional analysis, hydrodynamics, and boundary layers.",
                    badgeLabel = "Hydraulics Medal Earned"
                ),
                topics = listOf(
                    TopicAnalytics("Consolidation Stress", 52),
                    TopicAnalytics("Dimensional Analysis", 88),
                    TopicAnalytics("Tacheometry Systems", 71),
                    TopicAnalytics("Permeability Coefficients", 64)
                ),
                recentSessions = listOf(
                    RecentSessionInfo(
                        title = "Geotechnical Eng. - Soil Mechanics",
                        detail = "Completed 1 day ago • 60 Questions",
                        accuracy = 72,
                        deltaText = "-3% vs avg",
                        isWavyIcon = false
                    ),
                    RecentSessionInfo(
                        title = "Surveying - Triangulation",
                        detail = "Completed 3 days ago • 50 Questions",
                        accuracy = 85,
                        deltaText = "+4% vs avg",
                        isWavyIcon = true
                    )
                )
            ),
            "90 Days" to AnalyticsDataset(
                filterName = "90 Days",
                accuracy = 82,
                sessionsCount = 980,
                questionsSolved = 28400,
                studyHours = 680,
                improvementPercent = "+12%",
                peakValue = 86,
                peakDayLabel = "Quarter high",
                baselineValue = 70,
                trendPoints = listOf(70f, 73f, 75f, 79f, 82f, 84f, 86f),
                subjects = listOf(
                    SubjectAnalytics("Fluid Mechanics", 81, 11400, "Rank #10"),
                    SubjectAnalytics("Geotechnical Eng.", 85, 9200, "Rank #3"),
                    SubjectAnalytics("Surveying", 80, 7100, "Rank #14")
                ),
                weakSubject = WeakSubjectInfo(
                    name = "Surveying",
                    accuracy = 58,
                    questionsCount = 710,
                    highlightDescription = "Leveling corrections and earthwork calculations need intensive layout revisions."
                ),
                strongSubject = StrongSubjectInfo(
                    name = "Geotechnical Eng.",
                    accuracy = 91,
                    highlightDescription = "Exceptional understanding of effective stress, consolidation speed, and soil layers.",
                    badgeLabel = "Geotech Master Badge"
                ),
                topics = listOf(
                    TopicAnalytics("Earthwork Leveling", 58),
                    TopicAnalytics("Stress Distribution", 91),
                    TopicAnalytics("Boundary Layer Flows", 85),
                    TopicAnalytics("Fluid Kinematics", 77)
                ),
                recentSessions = listOf(
                    RecentSessionInfo(
                        title = "Surveying - Leveling Math",
                        detail = "Completed 1 week ago • 100 Questions",
                        accuracy = 65,
                        deltaText = "-2% vs avg",
                        isWavyIcon = true
                    ),
                    RecentSessionInfo(
                        title = "Fluid Mechanics - Pipe Flow Paths",
                        detail = "Completed 2 weeks ago • 80 Questions",
                        accuracy = 83,
                        deltaText = "+7% vs avg",
                        isWavyIcon = false
                    )
                )
            ),
            "All Time" to AnalyticsDataset(
                filterName = "All Time",
                accuracy = 80,
                sessionsCount = 1840,
                questionsSolved = 52100,
                studyHours = 1220,
                improvementPercent = "+15%",
                peakValue = 88,
                peakDayLabel = "Career peak",
                baselineValue = 68,
                trendPoints = listOf(68f, 70f, 74f, 72f, 79f, 83f, 88f),
                subjects = listOf(
                    SubjectAnalytics("Fluid Mechanics", 79, 21400, "Rank #11"),
                    SubjectAnalytics("Geotechnical Eng.", 83, 17800, "Rank #4"),
                    SubjectAnalytics("Surveying", 78, 11900, "Rank #18")
                ),
                weakSubject = WeakSubjectInfo(
                    name = "Geotechnical Eng.",
                    accuracy = 61,
                    questionsCount = 1420,
                    highlightDescription = "Shear strength of cohesive soils and triaxial drainage tests need focused practice."
                ),
                strongSubject = StrongSubjectInfo(
                    name = "Surveying",
                    accuracy = 94,
                    highlightDescription = "Outstanding grade achieved in horizontal curve alignments and GPS surveying formulas.",
                    badgeLabel = "Grand GPS Badge Active"
                ),
                topics = listOf(
                    TopicAnalytics("Triaxial Shear Math", 61),
                    TopicAnalytics("Route Curve Geometry", 94),
                    TopicAnalytics("Momentum Equations", 80),
                    TopicAnalytics("Effective Stress Maps", 79)
                ),
                recentSessions = listOf(
                    RecentSessionInfo(
                        title = "Organic Chemistry - Carbonyls",
                        detail = "Completed 1 month ago • 45 Questions",
                        accuracy = 81,
                        deltaText = "+3% vs avg",
                        isWavyIcon = false
                    ),
                    RecentSessionInfo(
                        title = "Fluid Mechanics - Buoyancy Rules",
                        detail = "Completed 1 month ago • 40 Questions",
                        accuracy = 79,
                        deltaText = "0% vs avg",
                        isWavyIcon = true
                    )
                )
            )
        )
    }
    return remember { AnalyticsStateHolder(initialData) }
}

// Sound Support event hook
private fun playSoundHook(context: android.content.Context, event: String) {
    // Hooks prepared for sound cues
    android.util.Log.d("SoundHooks", "Preloaded audio hooks: Play sound trigger for action context -> $event")
}

// -----------------------------------------------------------------------------------
// MAIN SCREEN ENTRY COMPOSABLE
// -----------------------------------------------------------------------------------
@Composable
fun AnalyticsTabScreen() {
    val state = rememberAnalyticsState()
    val view = LocalView.current
    val context = LocalContext.current

    // Trigger Screen Entry Animation Hook
    var entryTransitionStarted by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) {
        entryTransitionStarted = true
        playSoundHook(context, "Analytics Loaded")
    }

    // Offset slide details
    val entryOffsetAnimate by animateDpAsState(
        targetValue = if (entryTransitionStarted) 0.dp else 40.dp,
        animationSpec = tween(durationMillis = 250, easing = EaseOutQuad),
        label = "entryOffset"
    )

    val entryAlphaAnimate by animateFloatAsState(
        targetValue = if (entryTransitionStarted) 1f else 0f,
        animationSpec = tween(durationMillis = 250, easing = EaseOutQuad),
        label = "entryAlpha"
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(BackgroundDark)
            .graphicsLayer {
                translationY = entryOffsetAnimate.toPx()
                alpha = entryAlphaAnimate
            }
    ) {
        // Scrollable area wrapping up the elements
        Column(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp)
        ) {
            Spacer(modifier = Modifier.height(16.dp))

            // 1. HEADER SECTION
            AnalyticsHeader(
                isSimulatingEmpty = state.isSimulatingEmptyState,
                onToggleEmptyState = {
                    state.isSimulatingEmptyState = !state.isSimulatingEmptyState
                    safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                    val label = if (state.isSimulatingEmptyState) "Simulating Empty State" else "Showing Real Analytics"
                    Toast.makeText(context, label, Toast.LENGTH_SHORT).show()
                }
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Check if Empty State is triggered
            if (state.isSimulatingEmptyState) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f, fill = false)
                        .padding(vertical = 40.dp),
                    contentAlignment = Alignment.Center
                ) {
                    EmptyStateLayout(
                        onCreateSession = {
                            safeHaptic(view, HapticFeedbackConstants.LONG_PRESS)
                            Toast.makeText(context, "Redirecting to Session builder...", Toast.LENGTH_SHORT).show()
                        }
                    )
                }
            } else {
                // Real high-fidelity stats dashboards
                // 2. TIME FILTER SELECTOR
                TimeFilterSelector(
                    selectedFilter = state.selectedFilter,
                    onFilterSelected = { filter ->
                        if (state.selectedFilter != filter) {
                            state.selectedFilter = filter
                            safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                            playSoundHook(context, "Filter Changed")
                        }
                    }
                )

                Spacer(modifier = Modifier.height(20.dp))

                // 3. OVERVIEW CARD WITH INTEGRATED ACCURACY RING & 3-COLUMN METRICS
                OverviewCard(dataset = state.currentData)

                Spacer(modifier = Modifier.height(18.dp))

                // 4. PERFORMANCE TREND SECTION
                SectionHeading(title = "Performance Trend")
                Spacer(modifier = Modifier.height(8.dp))
                PerformanceTrendChart(dataset = state.currentData)

                Spacer(modifier = Modifier.height(24.dp))

                // 5. SUBJECT PERFORMANCE SECTION
                SectionHeading(title = "Subject Performance")
                Spacer(modifier = Modifier.height(10.dp))
                state.currentData.subjects.forEach { subject ->
                    SubjectPerformanceCard(subject = subject)
                    Spacer(modifier = Modifier.height(10.dp))
                }

                Spacer(modifier = Modifier.height(14.dp))

                // 6. FOCUS NEXT / WEAK SUBJECTS CARD
                SectionHeading(title = "Focus Next")
                Spacer(modifier = Modifier.height(10.dp))
                WeakSubjectCard(
                    weakSubject = state.currentData.weakSubject,
                    onPracticeAgain = {
                        safeHaptic(view, HapticFeedbackConstants.LONG_PRESS)
                        Toast.makeText(context, "Rebuilding dynamic custom test for ${state.currentData.weakSubject.name}", Toast.LENGTH_SHORT).show()
                    }
                )

                Spacer(modifier = Modifier.height(24.dp))

                // 7. BEST PERFORMANCE / STRONG SUBJECTS CARD
                SectionHeading(title = "Best Performance")
                Spacer(modifier = Modifier.height(10.dp))
                StrongSubjectCard(strongSubject = state.currentData.strongSubject)

                Spacer(modifier = Modifier.height(24.dp))

                // 8. TOPICS PERFORMANCE SECTION
                SectionHeading(title = "Topic Performance")
                Spacer(modifier = Modifier.height(10.dp))
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(20.dp),
                    colors = CardDefaults.cardColors(containerColor = SurfaceDark),
                    border = BorderStroke(1.dp, BorderDark)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        state.currentData.topics.forEachIndexed { index, topic ->
                            TopicPerformanceCard(topic = topic)
                            if (index < state.currentData.topics.size - 1) {
                                HorizontalDivider(
                                    color = BorderDark.copy(alpha = 0.5f),
                                    modifier = Modifier.padding(vertical = 12.dp)
                                )
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))

                // 9. RECENT SESSIONS SECTION
                SectionHeading(title = "Recent Sessions")
                Spacer(modifier = Modifier.height(10.dp))
                state.currentData.recentSessions.forEach { session ->
                    RecentPerformanceCard(session = session)
                    Spacer(modifier = Modifier.height(10.dp))
                }

                Spacer(modifier = Modifier.height(14.dp))

                // 10. PREMIUM FEATURE ADS ADVERTISEMENT PLACEHOLDER (motherboard look)
                PremiumFeatureBanner(
                    onGoPro = {
                        safeHaptic(view, HapticFeedbackConstants.CONFIRM)
                        Toast.makeText(context, "Opening Premium purchase flow...", Toast.LENGTH_SHORT).show()
                    }
                )

                Spacer(modifier = Modifier.height(14.dp))

                // 11. ADVERTISEMENT PLACEHOLDER
                AdAreaPlaceholder()

                Spacer(modifier = Modifier.height(72.dp)) // Padding for bottom navbar clearances
            }
        }
    }
}

// -----------------------------------------------------------------------------------
// REUSABLE SUB-WIDGET COMPOSABLES
// -----------------------------------------------------------------------------------

@Composable
fun SectionHeading(title: String) {
    Text(
        text = title,
        color = TextPrimary,
        fontSize = 17.sp,
        fontWeight = FontWeight.Bold,
        letterSpacing = (-0.2).sp
    )
}

// SUB-WIDGET 1: HEADER
@Composable
fun AnalyticsHeader(
    isSimulatingEmpty: Boolean,
    onToggleEmptyState: () -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column {
            Text(
                text = "Analytics",
                color = TextPrimary,
                fontSize = 25.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = (-0.5).sp,
                modifier = Modifier.testTag("analytics_header_title")
            )
            Spacer(modifier = Modifier.height(3.dp))
            Text(
                text = "Track your learning progress.",
                color = TextSecondary,
                fontSize = 13.5.sp,
                fontFamily = FontFamily.SansSerif
            )
        }

        // Small simulation toggle to showcase Empty state
        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(30.dp))
                .background(if (isSimulatingEmpty) PrimaryBlue else SurfaceDark)
                .clickable { onToggleEmptyState() }
                .border(1.dp, BorderDark, RoundedCornerShape(30.dp))
                .padding(horizontal = 12.dp, vertical = 6.dp)
        ) {
            Text(
                text = if (isSimulatingEmpty) "Show Real" else "Try Empty",
                color = if (isSimulatingEmpty) BackgroundDark else TextSecondary,
                fontSize = 10.5.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

// SUB-WIDGET 2: TIME FILTER SELECTOR
@Composable
fun TimeFilterSelector(
    selectedFilter: String,
    onFilterSelected: (String) -> Unit
) {
    val filters = listOf("7 Days", "30 Days", "All Time") // Matches the high fidelity visual filters

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(32.dp))
            .background(SurfaceDark)
            .border(1.dp, BorderDark, RoundedCornerShape(32.dp))
            .padding(4.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        filters.forEach { filter ->
            val isSelected = filter == selectedFilter
            Box(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(28.dp))
                    .background(if (isSelected) PrimaryBlue else Color.Transparent)
                    .clickable { onFilterSelected(filter) }
                    .padding(vertical = 10.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = filter,
                    color = if (isSelected) BackgroundDark else TextSecondary,
                    fontSize = 12.5.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

// SUB-WIDGET 3: OVERVIEW CARD (Accuracy, Sessions, Solved, Time Grid)
@Composable
fun OverviewCard(dataset: AnalyticsDataset) {
    val view = LocalView.current
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val animatedScale by animateFloatAsState(
        targetValue = if (isPressed) 0.98f else 1.0f,
        animationSpec = tween(durationMillis = 100),
        label = "scale"
    )

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .graphicsLayer {
                scaleX = animatedScale
                scaleY = animatedScale
            }
            .clickable(
                interactionSource = interactionSource,
                indication = LocalIndication.current
            ) {
                safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
            },
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        border = BorderStroke(1.dp, BorderDark)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Circle Accuracy Ring with animating state
            AccuracyRingWidget(accuracy = dataset.accuracy)

            Spacer(modifier = Modifier.height(16.dp))

            // Percentage bubble trend capsule
            Row(
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .background(SuccessGreen.copy(alpha = 0.12f))
                    .padding(horizontal = 10.dp, vertical = 5.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Default.TrendingUp,
                    contentDescription = null,
                    tint = SuccessGreen,
                    modifier = Modifier.size(13.dp)
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = "${dataset.improvementPercent} improvement",
                    color = SuccessGreen,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Columns Metric Grid
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                MetricColumn(
                    modifier = Modifier.weight(1f),
                    label = "SESSIONS",
                    value = formatValueAnimate(dataset.sessionsCount)
                )
                MetricVerticalDivider()
                MetricColumn(
                    modifier = Modifier.weight(1.3f),
                    label = "SOLVED",
                    value = formatValueAnimate(dataset.questionsSolved, true)
                )
                MetricVerticalDivider()
                MetricColumn(
                    modifier = Modifier.weight(1f),
                    label = "TIME",
                    value = "${formatValueAnimate(dataset.studyHours)}h"
                )
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Motivational message
            Text(
                text = "You're performing in the top 5% of engineering students this week. Keep up the momentum!",
                color = TextSecondary,
                fontSize = 12.5.sp,
                textAlign = TextAlign.Center,
                lineHeight = 18.sp,
                modifier = Modifier.padding(horizontal = 8.dp)
            )
        }
    }
}

@Composable
fun MetricColumn(
    modifier: Modifier = Modifier,
    label: String,
    value: String
) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = label,
            color = TextSecondary.copy(alpha = 0.8f),
            fontSize = 9.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 0.8.sp
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = value,
            color = TextPrimary,
            fontSize = 19.sp,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
fun MetricVerticalDivider() {
    Box(
        modifier = Modifier
            .width(1.dp)
            .height(24.dp)
            .background(BorderDark)
    )
}

// SUB-WIDGET 4: ACCURACY RING WIDGET
@Composable
fun AccuracyRingWidget(accuracy: Int) {
    // Fill rotation animation
    var animationTriggered by remember { mutableStateOf(false) }
    LaunchedEffect(accuracy) {
        animationTriggered = false
        delay(60)
        animationTriggered = true
    }

    val animatedSweep by animateFloatAsState(
        targetValue = if (animationTriggered) (accuracy / 100f) else 0f,
        animationSpec = tween(1200, easing = FastOutSlowInEasing),
        label = "sweepAnim"
    )

    // Animated accuracy values inside
    val animatedPercentValue by animateIntAsState(
        targetValue = if (animationTriggered) accuracy else 0,
        animationSpec = tween(1200, easing = FastOutSlowInEasing),
        label = "countUpPercent"
    )

    Box(
        modifier = Modifier.size(175.dp),
        contentAlignment = Alignment.Center
    ) {
        Canvas(modifier = Modifier.size(150.dp)) {
            val strokeWidthPx = 13.dp.toPx()
            
            // 1. Draw Background Ring Track
            drawArc(
                color = BorderDark,
                startAngle = -210f,
                sweepAngle = 240f,
                useCenter = false,
                style = Stroke(width = strokeWidthPx, cap = StrokeCap.Round)
            )

            // 2. Draw Progress Arc Segment
            drawArc(
                color = PrimaryBlue,
                startAngle = -210f,
                sweepAngle = animatedSweep * 240f,
                useCenter = false,
                style = Stroke(width = strokeWidthPx, cap = StrokeCap.Round)
            )
        }

        // Inner Text displays
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "${animatedPercentValue}%",
                color = TextPrimary,
                fontSize = 32.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = (-0.5).sp
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = "Accuracy",
                color = TextSecondary,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

// SUB-WIDGET 5: PERFORMANCE TREND LINE CHART
@Composable
fun PerformanceTrendChart(dataset: AnalyticsDataset) {
    // Animate point elevations
    var chartShown by remember { mutableStateOf(false) }
    LaunchedEffect(dataset) {
        chartShown = false
        delay(100)
        chartShown = true
    }

    val animatedFactor by animateFloatAsState(
        targetValue = if (chartShown) 1f else 0f,
        animationSpec = tween(1000, easing = FastOutSlowInEasing),
        label = "chartAnim"
    )

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        border = BorderStroke(1.dp, BorderDark)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(18.dp)
        ) {
            // Small header inside trend
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Performance Trend",
                    color = TextPrimary,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                )
                
                Icon(
                    Icons.Default.TrendingUp,
                    contentDescription = null,
                    tint = TextSecondary.copy(alpha = 0.5f),
                    modifier = Modifier.size(16.dp)
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Canvas drawing line chart
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(130.dp)
            ) {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    val points = dataset.trendPoints
                    if (points.size > 1) {
                        val numPoints = points.size
                        val spacingX = size.width / (numPoints - 1)
                        
                        // Map values (assuming range from 50% to 95% for chart range)
                        val valueMin = 50f
                        val valueMax = 95f
                        
                        val mappedCoordinates = points.mapIndexed { idx, value ->
                            val x = idx * spacingX
                            val valueFraction = (value - valueMin) / (valueMax - valueMin)
                            val scaledValueFraction = valueFraction * animatedFactor
                            // Invert y index so high accuracy stays up
                            val y = size.height - (scaledValueFraction * size.height)
                            Offset(x, y)
                        }

                        // Build Cubic Bezier Path
                        val linePath = Path()
                        if (mappedCoordinates.isNotEmpty()) {
                            linePath.moveTo(mappedCoordinates[0].x, mappedCoordinates[0].y)
                            for (i in 1 until mappedCoordinates.size) {
                                val pPrev = mappedCoordinates[i - 1]
                                val pCurr = mappedCoordinates[i]
                                
                                val controlX1 = pPrev.x + (spacingX / 2f)
                                val controlY1 = pPrev.y
                                val controlX2 = pPrev.x + (spacingX / 2f)
                                val controlY2 = pCurr.y
                                
                                linePath.cubicTo(controlX1, controlY1, controlX2, controlY2, pCurr.x, pCurr.y)
                            }
                        }

                        // 1. Draw glowing Gradient field below path
                        val fillPath = Path().apply {
                            addPath(linePath)
                            // close bounds
                            lineTo(size.width, size.height)
                            lineTo(0f, size.height)
                            close()
                        }

                        drawPath(
                            path = fillPath,
                            brush = Brush.verticalGradient(
                                colors = listOf(
                                    PrimaryBlue.copy(alpha = 0.28f),
                                    Color.Transparent
                                ),
                                startY = 0f,
                                endY = size.height
                            )
                        )

                        // 2. Draw actual main Bezier curve line stroke
                        drawPath(
                            path = linePath,
                            color = PrimaryBlue,
                            style = Stroke(width = 3.dp.toPx(), cap = StrokeCap.Round)
                        )

                        // 3. Draw a peak/end point glowing node accent
                        if (mappedCoordinates.isNotEmpty()) {
                            val peakNode = mappedCoordinates.last()
                            // Back drop halo ring
                            drawCircle(
                                color = PrimaryBlue.copy(alpha = 0.4f),
                                radius = 7.dp.toPx(),
                                center = peakNode
                            )
                            // Core white node
                            drawCircle(
                                color = TextPrimary,
                                radius = 3.dp.toPx(),
                                center = peakNode
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Time X-axis labels
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = "Mon",
                    color = TextSecondary.copy(alpha = 0.7f),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.SemiBold
                )
                Text(
                    text = "Sun",
                    color = TextSecondary.copy(alpha = 0.7f),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.SemiBold
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Bottom descriptive columns with Peak & Baseline results
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "${dataset.peakValue}%",
                        color = TextPrimary,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.height(1.dp))
                    Text(
                        text = dataset.peakDayLabel,
                        color = TextSecondary,
                        fontSize = 11.sp
                    )
                }

                Column(horizontalAlignment = Alignment.End) {
                    Text(
                        text = "${dataset.baselineValue}%",
                        color = TextPrimary,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.height(1.dp))
                    Text(
                        text = "Baseline",
                        color = TextSecondary,
                        fontSize = 11.sp
                    )
                }
            }
        }
    }
}

// SUB-WIDGET 6: SUBJECT PERFORMANCE COMPONENT
@Composable
fun SubjectPerformanceCard(subject: SubjectAnalytics) {
    var loadedByAnim by remember { mutableStateOf(false) }
    LaunchedEffect(subject) {
        loadedByAnim = false
        delay(80)
        loadedByAnim = true
    }

    val animProgressFraction by animateFloatAsState(
        targetValue = if (loadedByAnim) (subject.accuracy / 100f) else 0f,
        animationSpec = tween(durationMillis = 1000, easing = EaseInOutQuad),
        label = "subjProgress"
    )

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        border = BorderStroke(1.dp, BorderDark)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(15.dp)
        ) {
            // Subject header row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = subject.name,
                    color = TextPrimary,
                    fontSize = 14.5.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f)
                )

                Text(
                    text = "${subject.accuracy}%",
                    color = PrimaryBlue,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Blue horizontal progress bars
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(6.dp)
                    .clip(RoundedCornerShape(3.dp))
                    .background(BorderDark)
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxHeight()
                        .fillMaxWidth(animProgressFraction)
                        .background(PrimaryBlue)
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Footer row with stats & rank
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "${formatValueAnimate(subject.attemptedQuestions, true)} attempted",
                    color = TextSecondary,
                    fontSize = 11.5.sp
                )

                Text(
                    text = subject.rankLabel,
                    color = TextSecondary.copy(alpha = 0.8f),
                    fontSize = 11.5.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

// SUB-WIDGET 7: WEAK SUBJECTCARD (Needs Attention - Coral left stripe)
@Composable
fun WeakSubjectCard(
    weakSubject: WeakSubjectInfo,
    onPracticeAgain: () -> Unit
) {
    val view = LocalView.current
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val animatedScale by animateFloatAsState(
        targetValue = if (isPressed) 0.98f else 1.0f,
        animationSpec = tween(durationMillis = 100),
        label = "scale"
    )

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .graphicsLayer {
                scaleX = animatedScale
                scaleY = animatedScale
            }
            .clickable(
                interactionSource = interactionSource,
                indication = LocalIndication.current
            ) {
                safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
            },
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        border = BorderStroke(1.dp, BorderDark)
    ) {
        Box(modifier = Modifier.fillMaxWidth()) {
            // Coral left accent stripe
            Box(
                modifier = Modifier
                    .width(4.dp)
                    .matchParentSize()
                    .background(ErrorRed)
            )

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(start = 18.dp, end = 16.dp, top = 16.dp, bottom = 16.dp)
            ) {
                // Header with Alert Needs Attention tag + accuracy
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Icon(
                            Icons.Default.Warning,
                            contentDescription = null,
                            tint = ErrorRed.copy(alpha = 0.8f),
                            modifier = Modifier.size(13.dp)
                        )
                        Text(
                            text = "NEEDS ATTENTION",
                            color = ErrorRed.copy(alpha = 0.85f),
                            fontSize = 9.sp,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 0.8.sp
                        )
                    }

                    Text(
                        text = "${weakSubject.accuracy}%",
                        color = ErrorRed,
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                Spacer(modifier = Modifier.height(4.dp))

                // Subject name
                Text(
                    text = weakSubject.name,
                    color = TextPrimary,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(4.dp))

                // Diagnostic description warning text
                Text(
                    text = weakSubject.highlightDescription,
                    color = TextSecondary,
                    fontSize = 12.5.sp,
                    lineHeight = 18.sp
                )

                Spacer(modifier = Modifier.height(14.dp))

                // Practice Again rounded button
                Button(
                    onClick = onPracticeAgain,
                    colors = ButtonDefaults.buttonColors(containerColor = PrimaryBlue),
                    shape = RoundedCornerShape(20.dp),
                    contentPadding = PaddingValues(horizontal = 18.dp, vertical = 8.dp)
                ) {
                    Text(
                        text = "Practice Again",
                        color = BackgroundDark,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}

// SUB-WIDGET 8: STRONG SUBJECT CARD (Best Performance - Green left stripe)
@Composable
fun StrongSubjectCard(strongSubject: StrongSubjectInfo) {
    val view = LocalView.current
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val animatedScale by animateFloatAsState(
        targetValue = if (isPressed) 0.98f else 1.0f,
        animationSpec = tween(durationMillis = 100),
        label = "scale"
    )

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .graphicsLayer {
                scaleX = animatedScale
                scaleY = animatedScale
            }
            .clickable(
                interactionSource = interactionSource,
                indication = LocalIndication.current
            ) {
                safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
            },
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        border = BorderStroke(1.dp, BorderDark)
    ) {
        Box(modifier = Modifier.fillMaxWidth()) {
            // Bright Green left accent stripe
            Box(
                modifier = Modifier
                    .width(4.dp)
                    .matchParentSize()
                    .background(SuccessGreen)
            )

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(start = 18.dp, end = 16.dp, top = 16.dp, bottom = 16.dp)
            ) {
                // Header with Best performance tag + status percent
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Icon(
                            Icons.Default.Star,
                            contentDescription = null,
                            tint = SuccessGreen,
                            modifier = Modifier.size(13.dp)
                        )
                        Text(
                            text = "BEST PERFORMANCE",
                            color = SuccessGreen,
                            fontSize = 9.sp,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 0.8.sp
                        )
                    }

                    Text(
                        text = "${strongSubject.accuracy}%",
                        color = SuccessGreen,
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                Spacer(modifier = Modifier.height(4.dp))

                // Subject name
                Text(
                    text = strongSubject.name,
                    color = TextPrimary,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(4.dp))

                // Detailed compliment message
                Text(
                    text = strongSubject.highlightDescription,
                    color = TextSecondary,
                    fontSize = 12.5.sp,
                    lineHeight = 18.sp
                )

                Spacer(modifier = Modifier.height(14.dp))

                // Mastery Badge indication Row
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(24.dp)
                            .clip(CircleShape)
                            .background(SuccessGreen.copy(alpha = 0.15f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            Icons.Default.EmojiEvents, // Trophy replacement
                            contentDescription = null,
                            tint = SuccessGreen,
                            modifier = Modifier.size(13.dp)
                        )
                    }

                    Text(
                        text = strongSubject.badgeLabel,
                        color = TextSecondary,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }
    }
}

// SUB-WIDGET 9: TOPICS PERFORMANCE CARD
@Composable
fun TopicPerformanceCard(topic: TopicAnalytics) {
    var animateFillState by remember { mutableStateOf(false) }
    LaunchedEffect(topic) {
        animateFillState = false
        delay(80)
        animateFillState = true
    }

    val progressByAnimate by animateFloatAsState(
        targetValue = if (animateFillState) (topic.accuracy / 100f) else 0f,
        animationSpec = tween(durationMillis = 1000, easing = EaseInOutQuad),
        label = "topicProgress"
    )

    Column(modifier = Modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = topic.name,
                color = TextPrimary,
                fontSize = 13.5.sp,
                fontWeight = FontWeight.SemiBold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f)
            )

            Text(
                text = "${topic.accuracy}%",
                color = TextPrimary,
                fontSize = 13.5.sp,
                fontWeight = FontWeight.Bold
            )
        }

        Spacer(modifier = Modifier.height(6.dp))

        // Progress line
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(4.dp)
                .clip(RoundedCornerShape(2.dp))
                .background(BorderDark)
        ) {
            Box(
                modifier = Modifier
                    .fillMaxHeight()
                    .fillMaxWidth(progressByAnimate)
                    .background(PrimaryBlue)
            )
        }
    }
}

// SUB-WIDGET 10: RECENT PERFORMANCE CARD
@Composable
fun RecentPerformanceCard(session: RecentSessionInfo) {
    val view = LocalView.current
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val animatedScale by animateFloatAsState(
        targetValue = if (isPressed) 0.98f else 1.0f,
        animationSpec = tween(durationMillis = 90),
        label = "scale"
    )

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .graphicsLayer {
                scaleX = animatedScale
                scaleY = animatedScale
            }
            .clip(RoundedCornerShape(16.dp))
            .background(SurfaceDark)
            .border(1.dp, BorderDark, RoundedCornerShape(16.dp))
            .clickable(
                interactionSource = interactionSource,
                indication = LocalIndication.current
            ) {
                safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
            }
            .padding(14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Icon circular square background container
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(BackgroundDark),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = if (session.isWavyIcon) Icons.Default.Waves else Icons.Default.Science,
                contentDescription = null,
                tint = TextSecondary,
                modifier = Modifier.size(19.dp)
            )
        }

        Spacer(modifier = Modifier.width(12.dp))

        // Titles and times column
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = session.title,
                color = TextPrimary,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = session.detail,
                color = TextSecondary,
                fontSize = 11.5.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }

        Spacer(modifier = Modifier.width(10.dp))

        // Accuracy score on right with percent change delta
        Column(horizontalAlignment = Alignment.End) {
            Text(
                text = "${session.accuracy}%",
                color = TextPrimary,
                fontSize = 14.5.sp,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = session.deltaText,
                color = SuccessGreen,
                fontSize = 9.5.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

// SUB-WIDGET 11: PREMIUM AD BANNER WITH AMBIENT CHIP VISUAL GRAPHICS
@Composable
fun PremiumFeatureBanner(onGoPro: () -> Unit) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val animatedScale by animateFloatAsState(
        targetValue = if (isPressed) 0.98f else 1.0f,
        animationSpec = tween(100),
        label = "bannerScale"
    )

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .graphicsLayer {
                scaleX = animatedScale
                scaleY = animatedScale
            }
            .clickable(
                interactionSource = interactionSource,
                indication = null
            ) {
                onGoPro()
            },
        shape = RoundedCornerShape(20.dp),
        border = BorderStroke(1.dp, PrimaryBlue.copy(alpha = 0.35f))
    ) {
        // Deep ambient linear backdrop imitating high density circuit layout
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            SurfaceDark,
                            BackgroundDark
                        )
                    )
                )
                .padding(20.dp)
        ) {
            Column(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "PREMIUM FEATURE",
                    color = PrimaryBlue,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.2.sp
                )
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = "Unlock Detailed AI Heatmaps & Topic Predictions",
                    color = TextPrimary,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.Bold,
                    lineHeight = 23.sp
                )
                Spacer(modifier = Modifier.height(14.dp))
                
                // Go Pro pill button
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(30.dp))
                        .background(TextPrimary)
                        .padding(horizontal = 20.dp, vertical = 9.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "Go Pro",
                        color = BackgroundDark,
                        fontSize = 11.5.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}

// SUB-WIDGET 12: ADVERTISEMENT PLACEHOLDER (HEIGHT 50DP MATCHING BRIEF)
@Composable
fun AdAreaPlaceholder() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(50.dp)
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
}

// EMPTY STATE LAYOUT COMPOSABLE
@Composable
fun EmptyStateLayout(onCreateSession: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark),
        border = BorderStroke(1.dp, BorderDark)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(30.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(
                Icons.Default.QueryStats,
                contentDescription = null,
                tint = TextSecondary.copy(alpha = 0.35f),
                modifier = Modifier.size(54.dp)
            )

            Spacer(modifier = Modifier.height(14.dp))

            Text(
                text = "No Analytics Yet",
                color = TextPrimary,
                fontSize = 17.sp,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(4.dp))

            Text(
                text = "Complete your first session to unlock analytics.",
                color = TextSecondary,
                fontSize = 13.sp,
                textAlign = TextAlign.Center,
                lineHeight = 18.sp
            )

            Spacer(modifier = Modifier.height(20.dp))

            Button(
                onClick = onCreateSession,
                colors = ButtonDefaults.buttonColors(containerColor = PrimaryBlue),
                shape = RoundedCornerShape(22.dp),
                contentPadding = PaddingValues(horizontal = 20.dp, vertical = 10.dp)
            ) {
                Text(
                    text = "Create Session",
                    color = BackgroundDark,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

// Helper utility to format numbers gracefully per step count animating
@Composable
private fun formatValueAnimate(targetValue: Int, useComma: Boolean = false): String {
    var animCounterActive by remember { mutableStateOf(false) }
    LaunchedEffect(targetValue) {
        animCounterActive = false
        delay(70)
        animCounterActive = true
    }

    val animatedValue by animateIntAsState(
        targetValue = if (animCounterActive) targetValue else 0,
        animationSpec = tween(850, easing = FastOutSlowInEasing),
        label = "counterUp"
    )

    return if (useComma) {
        formatThousands(animatedValue)
    } else {
        animatedValue.toString()
    }
}

private fun formatThousands(number: Int): String {
    return if (number >= 1000) {
        val thousands = number / 1000
        val remaining = number % 1000
        "$thousands,${String.format("%03d", remaining)}"
    } else {
        number.toString()
    }
}

private fun safeHaptic(view: android.view.View?, constant: Int) {
    try {
        if (view != null && view.isAttachedToWindow) {
            view.performHapticFeedback(constant)
        }
    } catch (e: Throwable) {
        // Safe fallback prevents crash
    }
}
