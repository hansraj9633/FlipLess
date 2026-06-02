package com.example

import android.view.HapticFeedbackConstants
import android.widget.Toast
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

// -----------------------------------------------------------------------------------
// DOMAIN MODELS & DATA
// -----------------------------------------------------------------------------------
data class PracticeSession(
    val id: String,
    val subject: String,
    val topic: String,
    val accuracy: Int,
    val score: Int,
    val totalQuestions: Int,
    val dateLabel: String,
    val relativeDate: String // "Today", "Yesterday", "This Week", "This Month", "Older"
)

// -----------------------------------------------------------------------------------
// STATE MANAGEMENT HOLDER / PROVIDER
// -----------------------------------------------------------------------------------
@Stable
class HistoryStateHolder(
    initialSessions: List<PracticeSession>
) {
    var rawSessions by mutableStateOf(initialSessions)
    
    // Core parameters for search/filtering
    var searchQuery by mutableStateOf("")
    var selectedSubject by mutableStateOf("All Subjects")
    var selectedDateFilter by mutableStateOf("All") // "All", "Today", "This Week", "This Month"
    var selectedSortOrder by mutableStateOf("Newest First") // "Newest First", "Oldest First", "Highest Score", "Highest Accuracy"
    
    // Interactive toggles
    var isSearchExpanded by mutableStateOf(false)
    var isFilterMenuExpanded by mutableStateOf(false)
    var sessionToDelete by mutableStateOf<PracticeSession?>(null)

    // Derived states
    val filteredAndSortedSessions: List<PracticeSession>
        get() {
            var list = rawSessions

            // 1. Subject filter
            if (selectedSubject != "All Subjects") {
                list = list.filter { it.subject.equals(selectedSubject, ignoreCase = true) }
            }

            // 2. Date filter mapping
            if (selectedDateFilter != "All") {
                list = list.filter { it.relativeDate.equals(selectedDateFilter, ignoreCase = true) }
            }

            // 3. Search query parsing
            if (searchQuery.isNotBlank()) {
                val q = searchQuery.trim()
                list = list.filter {
                    it.subject.contains(q, ignoreCase = true) ||
                    it.topic.contains(q, ignoreCase = true)
                }
            }

            // 4. Sorting applications
            return when (selectedSortOrder) {
                "Newest First" -> list // Simulated order of initial list insertion
                "Oldest First" -> list.asReversed()
                "Highest Score" -> list.sortedByDescending { it.score }
                "Lowest Score" -> list.sortedBy { it.score }
                "Highest Accuracy" -> list.sortedByDescending { it.accuracy }
                else -> list
            }
        }

    fun deleteSession(sessionId: String) {
        rawSessions = rawSessions.filter { it.id != sessionId }
    }
}

@Composable
fun rememberHistoryState(): HistoryStateHolder {
    val initialData = remember {
        listOf(
            PracticeSession(
                id = "1",
                subject = "Fluid Mechanics",
                topic = "Laminar & Turbulent Flow",
                accuracy = 92,
                score = 46,
                totalQuestions = 50,
                dateLabel = "Today, 2:30 PM",
                relativeDate = "Today"
            ),
            PracticeSession(
                id = "2",
                subject = "Surveying",
                topic = "Theodolite Measurements",
                accuracy = 78,
                score = 39,
                totalQuestions = 50,
                dateLabel = "Yesterday",
                relativeDate = "Yesterday"
            ),
            PracticeSession(
                id = "3",
                subject = "Fluid Mechanics",
                topic = "Bernoulli's Equation",
                accuracy = 85,
                score = 42,
                totalQuestions = 50,
                dateLabel = "24 Oct",
                relativeDate = "This Month"
            ),
            PracticeSession(
                id = "4",
                subject = "Thermodynamics",
                topic = "First Law Dynamics",
                accuracy = 100,
                score = 50,
                totalQuestions = 50,
                dateLabel = "22 Oct",
                relativeDate = "This Month"
            ),
            PracticeSession(
                id = "5",
                subject = "Surveying",
                topic = "Leveling Corrections",
                accuracy = 64,
                score = 32,
                totalQuestions = 50,
                dateLabel = "21 Oct",
                relativeDate = "This Month"
            )
        )
    }
    return remember { HistoryStateHolder(initialData) }
}

// -----------------------------------------------------------------------------------
// SOUND & LOGGING HOOKS
// -----------------------------------------------------------------------------------
private fun onSessionOpenedSound(context: android.content.Context) {
    android.util.Log.d("FlipLessSound", "Trigger sound feedback: Practice Session Details Opened")
}

private fun onSessionDeletedSound(context: android.content.Context) {
    android.util.Log.d("FlipLessSound", "Trigger sound feedback: Archival Session Record Erased")
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

// -----------------------------------------------------------------------------------
// MAIN HISTORY SCREEN COMPOSABLE
// -----------------------------------------------------------------------------------
@Composable
fun HistoryScreen(
    onNavigateBack: () -> Unit,
    onOpenResult: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val view = LocalView.current
    val state = rememberHistoryState()

    // Screen entering animations
    var isVisible by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) {
        isVisible = true
    }

    AnimatedVisibility(
        visible = isVisible,
        enter = fadeIn(animationSpec = tween(250)) + slideInVertically(
            initialOffsetY = { it / 8 },
            animationSpec = tween(250, easing = EaseOutQuad)
        ),
        exit = fadeOut(animationSpec = tween(150)),
        modifier = modifier.fillMaxSize()
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(BackgroundDark)
        ) {
            Column(modifier = Modifier.fillMaxSize()) {
                
                // 1. HISTORY HEADER
                HistoryHeader(
                    isSearchOpen = state.isSearchExpanded,
                    searchQuery = state.searchQuery,
                    onSearchQueryChange = { state.searchQuery = it },
                    onToggleSearch = {
                        safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                        state.isSearchExpanded = !state.isSearchExpanded
                        if (!state.isSearchExpanded) {
                            state.searchQuery = "" // Reset search when collapsing
                        }
                    },
                    onToggleFilters = {
                        safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                        state.isFilterMenuExpanded = !state.isFilterMenuExpanded
                    },
                    onBulkDeleteTrigger = {
                        safeHaptic(view, HapticFeedbackConstants.LONG_PRESS)
                        Toast.makeText(context, "Long-press individual card to trigger delete dialog", Toast.LENGTH_LONG).show()
                    }
                )

                // 2. REFINEMENT & FILTER BOX (SLIDE DOWN ACCORDION CARD)
                AnimatedVisibility(
                    visible = state.isFilterMenuExpanded,
                    enter = expandVertically(animationSpec = tween(200)) + fadeIn(),
                    exit = shrinkVertically(animationSpec = tween(200)) + fadeOut()
                ) {
                    FilterSettingsPanel(
                        selectedDate = state.selectedDateFilter,
                        onDateSelect = {
                            safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                            state.selectedDateFilter = it
                        },
                        selectedSort = state.selectedSortOrder,
                        onSortSelect = {
                            safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                            state.selectedSortOrder = it
                        }
                    )
                }

                // 3. SUBJECT FILTER CHIPS ROW (All Subjects, Fluid Mechanics, Surveying...)
                FilterChipSection(
                    selectedSubject = state.selectedSubject,
                    onSubjectSelect = { subject ->
                        safeHaptic(view, HapticFeedbackConstants.KEYBOARD_TAP)
                        state.selectedSubject = subject
                    }
                )

                // 4. MAIN CONTENT AREA (Lazy List of History Sessions or Empty State)
                val currentList = state.filteredAndSortedSessions

                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth()
                ) {
                    if (currentList.isEmpty()) {
                        EmptyHistoryWidget(
                            onCreateSession = {
                                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
                                    safeHaptic(view, 16) // 16 is HapticFeedbackConstants.CONFIRM
                                } else {
                                    safeHaptic(view, HapticFeedbackConstants.LONG_PRESS)
                                }
                                onNavigateBack() // Takes user back to Home screen to initialize a custom session
                            }
                        )
                    } else {
                        LazyColumn(
                            modifier = Modifier.fillMaxSize(),
                            contentPadding = PaddingValues(start = 16.dp, end = 16.dp, top = 8.dp, bottom = 80.dp),
                            verticalArrangement = Arrangement.spacedBy(14.dp)
                        ) {
                            itemsIndexed(
                                items = currentList,
                                key = { _, item -> item.id }
                            ) { index, session ->
                                // Custom staggered sliding/fading card entry simulation
                                var itemVisible by remember { mutableStateOf(false) }
                                LaunchedEffect(Unit) {
                                    delay(index * 40L)
                                    itemVisible = true
                                }

                                Column {
                                    AnimatedVisibility(
                                        visible = itemVisible,
                                        enter = fadeIn(tween(180)) + slideInVertically(
                                            initialOffsetY = { 30 },
                                            animationSpec = tween(180, easing = EaseOutQuad)
                                        ),
                                        exit = fadeOut(tween(100))
                                    ) {
                                        SessionHistoryCard(
                                            session = session,
                                            onTapCard = {
                                                safeHaptic(view, HapticFeedbackConstants.VIRTUAL_KEY)
                                                onSessionOpenedSound(context)
                                                onOpenResult(session.id)
                                            },
                                            onLongPressCard = {
                                                safeHaptic(view, HapticFeedbackConstants.LONG_PRESS)
                                                state.sessionToDelete = session
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }

                    // 5. BANNER AD RESERVED CONTAINER AT THE VERY BOTTOM OF OVERLAY SCREEN (Responsive, overlay format)
                    Box(
                        modifier = Modifier
                            .align(Alignment.BottomCenter)
                            .fillMaxWidth()
                            .padding(bottom = 12.dp)
                    ) {
                        AdBannerPlaceholder()
                    }
                }
            }

            // 6. DELETE FLOW CONFIRMATION DIALOG GUEST HOOK
            state.sessionToDelete?.let { session ->
                DeleteConfirmationDialog(
                    sessionName = session.topic,
                    onDismiss = {
                        state.sessionToDelete = null
                    },
                    onDeleteConfirm = {
                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
                            safeHaptic(view, 16) // 16 is HapticFeedbackConstants.CONFIRM
                        } else {
                            safeHaptic(view, HapticFeedbackConstants.LONG_PRESS)
                        }
                        state.deleteSession(session.id)
                        onSessionDeletedSound(context)
                        Toast.makeText(context, "Session deleted successfully.", Toast.LENGTH_SHORT).show()
                        state.sessionToDelete = null
                    }
                )
            }
        }
    }
}

// -----------------------------------------------------------------------------------
// SEARCH BAR COMPOSABLE (REUSABLE COMPONENT)
// -----------------------------------------------------------------------------------
@Composable
fun SearchBarWidget(
    searchQuery: String,
    onSearchQueryChange: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    TextField(
        value = searchQuery,
        onValueChange = onSearchQueryChange,
        placeholder = {
            Text(
                "Search subject, topic...",
                color = TextSecondary.copy(alpha = 0.6f),
                fontSize = 13.sp
            )
        },
        colors = TextFieldDefaults.colors(
            focusedContainerColor = SurfaceDark,
            unfocusedContainerColor = SurfaceDark,
            focusedIndicatorColor = Color.Transparent,
            unfocusedIndicatorColor = Color.Transparent,
            focusedTextColor = TextPrimary,
            unfocusedTextColor = TextPrimary
        ),
        modifier = modifier
            .height(44.dp)
            .clip(RoundedCornerShape(12.dp))
            .border(1.dp, BorderDark, RoundedCornerShape(12.dp)),
        singleLine = true
    )
}

@Composable
fun HistoryHeader(
    isSearchOpen: Boolean,
    searchQuery: String,
    onSearchQueryChange: (String) -> Unit,
    onToggleSearch: () -> Unit,
    onToggleFilters: () -> Unit,
    onBulkDeleteTrigger: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .statusBarsPadding()
            .background(BackgroundDark)
            .padding(horizontal = 16.dp, vertical = 12.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            // Profile image & Title pair
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.weight(1f)
            ) {
                // Profile Avatar visual matching prompt
                Box(
                    modifier = Modifier
                        .size(38.dp)
                        .clip(CircleShape)
                        .background(SurfaceDark)
                        .border(1.5.dp, BorderDark, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Outlined.Person,
                        contentDescription = "User Profile",
                        tint = TextSecondary,
                        modifier = Modifier.size(18.dp)
                    )
                }
                
                Spacer(modifier = Modifier.width(10.dp))
                
                if (!isSearchOpen) {
                    Column {
                        Text(
                            text = "History",
                            color = TextPrimary,
                            fontSize = 24.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(1.dp))
                        Text(
                            text = "Review your previous practice sessions.",
                            color = TextSecondary.copy(alpha = 0.5f),
                            fontSize = 9.sp,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 0.5.sp
                        )
                    }
                }
            }

            // Inline search field if expanded - replaces header partially
            if (isSearchOpen) {
                SearchBarWidget(
                    searchQuery = searchQuery,
                    onSearchQueryChange = onSearchQueryChange,
                    modifier = Modifier
                        .weight(2f)
                        .padding(end = 6.dp)
                )
            }

            // Toolbar action Buttons
            Row(verticalAlignment = Alignment.CenterVertically) {
                // Trash icon for bulk delete cues
                IconButton(onClick = onBulkDeleteTrigger) {
                    Icon(
                        imageVector = Icons.Outlined.Delete,
                        contentDescription = "Clear Session",
                        tint = TextSecondary.copy(alpha = 0.8f),
                        modifier = Modifier.size(20.dp)
                    )
                }

                // Search visibility controller
                IconButton(onClick = onToggleSearch) {
                    Icon(
                        imageVector = if (isSearchOpen) Icons.Default.Close else Icons.Default.Search,
                        contentDescription = "Search",
                        tint = if (isSearchOpen) PrimaryBlue else TextPrimary,
                        modifier = Modifier.size(20.dp)
                    )
                }

                // Refinement / Sorting expander list toggle
                IconButton(onClick = onToggleFilters) {
                    Icon(
                        imageVector = Icons.Default.FilterList,
                        contentDescription = "Sort Options",
                        tint = TextPrimary,
                        modifier = Modifier.size(20.dp)
                    )
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------------
// SUB-WIDGET 2: COLLAPSIBLE FILTERS & SORT PANEL
// -----------------------------------------------------------------------------------
@Composable
fun FilterSettingsPanel(
    selectedDate: String,
    onDateSelect: (String) -> Unit,
    selectedSort: String,
    onSortSelect: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    val dateOptions = listOf("All", "Today", "Yesterday", "This Month")
    val sortOptions = listOf("Newest First", "Oldest First", "Highest Score", "Highest Accuracy")

    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 4.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(SurfaceDark)
            .border(1.dp, BorderDark, RoundedCornerShape(16.dp))
            .padding(14.dp)
    ) {
        // Date Section
        Text(
            text = "FILTER BY DATE RANGE",
            color = TextSecondary,
            fontSize = 9.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 0.8.sp
        )
        Spacer(modifier = Modifier.height(8.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            dateOptions.forEach { opt ->
                val active = selectedDate == opt
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(10.dp))
                        .background(if (active) PrimaryBlue else BackgroundDark)
                        .clickable { onDateSelect(opt) }
                        .padding(vertical = 6.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = opt,
                        color = if (active) BackgroundDark else TextSecondary,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        // Sorting Selection
        Text(
            text = "SORT SESSIONS",
            color = TextSecondary,
            fontSize = 9.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 0.8.sp
        )
        Spacer(modifier = Modifier.height(8.dp))
        Row(
            modifier = Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            sortOptions.forEach { opt ->
                val active = selectedSort == opt
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(10.dp))
                        .background(if (active) PrimaryBlue else BackgroundDark)
                        .clickable { onSortSelect(opt) }
                        .padding(horizontal = 12.dp, vertical = 6.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = opt,
                        color = if (active) BackgroundDark else TextSecondary,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------------
// SUB-WIDGET 3: SUBJECT HORIZONTAL FILTER CHIPS ROW
// -----------------------------------------------------------------------------------
@Composable
fun FilterChipSection(
    selectedSubject: String,
    onSubjectSelect: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    val subjects = listOf("All Subjects", "Fluid Mechanics", "Surveying", "Thermodynamics")

    Row(
        modifier = modifier
            .fillMaxWidth()
            .horizontalScroll(rememberScrollState())
            .padding(horizontal = 16.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        subjects.forEach { subj ->
            val isSelected = selectedSubject == subj
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(20.dp))
                    .background(if (isSelected) SurfaceDark else BackgroundDark)
                    .border(
                        1.dp,
                        if (isSelected) PrimaryBlue else BorderDark,
                        RoundedCornerShape(20.dp)
                    )
                    .clickable { onSubjectSelect(subj) }
                    .padding(horizontal = 16.dp, vertical = 10.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = subj,
                    color = if (isSelected) TextPrimary else TextSecondary,
                    fontSize = 12.sp,
                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium
                )
            }
        }
    }
}

// -----------------------------------------------------------------------------------
// SUB-WIDGET 4: SESSION HISTORY CARD (CRITICAL DESIGN COMPONENT RENDER)
// -----------------------------------------------------------------------------------
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun SessionHistoryCard(
    session: PracticeSession,
    onTapCard: () -> Unit,
    onLongPressCard: () -> Unit,
    modifier: Modifier = Modifier
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val animatedScale by animateFloatAsState(
        targetValue = if (isPressed) 0.97f else 1.0f,
        animationSpec = tween(90),
        label = "clickScale"
    )

    Card(
        modifier = modifier
            .fillMaxWidth()
            .graphicsLayer {
                scaleX = animatedScale
                scaleY = animatedScale
            }
            .clip(RoundedCornerShape(20.dp))
            .border(1.dp, BorderDark, RoundedCornerShape(20.dp))
            .combinedClickable(
                interactionSource = interactionSource,
                indication = LocalIndication.current,
                onClick = onTapCard,
                onLongClick = onLongPressCard
            ),
        colors = CardDefaults.cardColors(containerColor = SurfaceDark)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Main left details container taking weight(1f) to stay highly responsive
            Column(modifier = Modifier.weight(1f)) {
                
                // Subject name and relative date indicator row
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = session.subject,
                        color = PrimaryBlue,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                    
                    Text(
                        text = session.dateLabel,
                        color = TextSecondary.copy(alpha = 0.5f),
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium
                    )
                }

                Spacer(modifier = Modifier.height(4.dp))

                // Topic main bold header description
                Text(
                    text = session.topic,
                    color = TextPrimary,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.height(14.dp))

                // Accuracy + Score grid pairs Layout
                Row(verticalAlignment = Alignment.CenterVertically) {
                    // Accuracy metric segment
                    Column(modifier = Modifier.width(90.dp)) {
                        Text(
                            text = "Accuracy",
                            color = TextSecondary.copy(alpha = 0.6f),
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 0.5.sp
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = "${session.accuracy}%",
                            color = PrimaryBlue,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.ExtraBold
                        )
                    }

                    // Score metric segment
                    Column {
                        Text(
                            text = "Score",
                            color = TextSecondary.copy(alpha = 0.6f),
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 0.5.sp
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = "${session.score}/${session.totalQuestions}",
                            color = TextPrimary,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.ExtraBold
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.width(8.dp))

            // Action Chevron arrow Circle button (Visual matching on far-right structure in Stitch design)
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .border(1.dp, BorderDark, CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.ChevronRight,
                    contentDescription = "Open Result Screen",
                    tint = TextSecondary,
                    modifier = Modifier.size(16.dp)
                )
            }
        }
    }
}

// -----------------------------------------------------------------------------------
// SUB-WIDGET 5: HISTORIC EMPTY STATE CANVAS
// -----------------------------------------------------------------------------------
@Composable
fun EmptyHistoryWidget(
    onCreateSession: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .padding(24.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Elegant background placeholder icon representing history archiver empty state
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .clip(CircleShape)
                    .background(SurfaceDark)
                    .border(1.dp, BorderDark, CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.History,
                    contentDescription = null,
                    tint = TextSecondary.copy(alpha = 0.3f),
                    modifier = Modifier.size(38.dp)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = "No Sessions Yet",
                color = TextPrimary,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(4.dp))

            Text(
                text = "Complete your first practice session to start building your history logs.",
                color = TextSecondary,
                fontSize = 13.sp,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(horizontal = 16.dp)
            )

            Spacer(modifier = Modifier.height(20.dp))

            // Quick launch button linking back to home/create
            Button(
                onClick = onCreateSession,
                colors = ButtonDefaults.buttonColors(containerColor = PrimaryBlue),
                shape = RoundedCornerShape(24.dp),
                contentPadding = PaddingValues(horizontal = 24.dp, vertical = 10.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Add,
                        contentDescription = null,
                        tint = BackgroundDark,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
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
}

// -----------------------------------------------------------------------------------
// SUB-WIDGET 6: DESTRUCTIVE ACTION / DELETE CONFIRMATION INTERFACE FLOW
// -----------------------------------------------------------------------------------
@Composable
fun DeleteConfirmationDialog(
    sessionName: String,
    onDismiss: () -> Unit,
    onDeleteConfirm: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Text(
                text = "Delete Session?",
                color = TextPrimary,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )
        },
        text = {
            Text(
                text = "This action cannot be undone. Are you sure you want to delete the record for \"$sessionName\"?",
                color = TextSecondary,
                fontSize = 13.5.sp
            )
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text(
                    text = "Cancel",
                    color = TextSecondary,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        },
        confirmButton = {
            Button(
                onClick = onDeleteConfirm,
                colors = ButtonDefaults.buttonColors(containerColor = ErrorRed),
                shape = RoundedCornerShape(14.dp)
            ) {
                Text(
                    text = "Delete",
                    color = TextPrimary,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        },
        containerColor = SurfaceDark,
        shape = RoundedCornerShape(20.dp),
        modifier = Modifier.border(1.dp, BorderDark, RoundedCornerShape(20.dp))
    )
}
