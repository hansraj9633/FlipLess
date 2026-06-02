import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/create_session_provider.dart';
import 'create_session_widgets.dart';

class CreateSessionForm extends ConsumerStatefulWidget {
  const CreateSessionForm({super.key});

  @override
  ConsumerState<CreateSessionForm> createState() => _CreateSessionFormState();
}

class _CreateSessionFormState extends ConsumerState<CreateSessionForm> {
  late TextEditingController _subjectController;
  late TextEditingController _topicController;
  late TextEditingController _questionsController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(createSessionProvider);
    _subjectController = TextEditingController(text: state.subject);
    _topicController = TextEditingController(text: state.topic);
    _questionsController = TextEditingController(text: state.questionCount.toString());
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    _questionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createSessionProvider);
    final notifier = ref.read(createSessionProvider.notifier);

    // Keep the questions controller synced if updated via steppers
    if (_questionsController.text != state.questionCount.toString()) {
      _questionsController.text = state.questionCount.toString();
    }

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SUBJECT FIELD
            const Text(
              'Subject *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subjectController,
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Example: Fluid Mechanics',
                errorText: (state.showErrors && !state.isSubjectValid)
                    ? 'Subject is required'
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              onChanged: (val) => notifier.updateSubject(val),
            ),
            const SizedBox(height: 20),

            // 2. TOPIC FIELD
            const Text(
              'Topic *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _topicController,
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Example: Open Channel Flow',
                errorText: (state.showErrors && !state.isTopicValid)
                    ? 'Topic is required'
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              onChanged: (val) => notifier.updateTopic(val),
            ),
            const SizedBox(height: 20),

            // 3. QUESTIONS STEPPER
            const Text(
              'Questions *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 160,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1.0),
              ),
              child: Row(
                children: [
                  // Minus Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      notifier.decrementQuestions();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.remove,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  // Middle manual input text
                  Expanded(
                    child: TextFormField(
                      controller: _questionsController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                      ),
                      onChanged: (val) {
                        final value = int.tryParse(val) ?? 1;
                        notifier.updateQuestionCount(value);
                      },
                    ),
                  ),
                  // Plus Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      notifier.incrementQuestions();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (state.questionCount <= 0) ...[
              const SizedBox(height: 4),
              const Text(
                'Must be at least 1 question',
                style: TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: 24),

            // 4. QUESTION TYPES CHIPS
            const Text(
              'Question Types *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                QuestionTypeChip(
                  label: 'MCQ',
                  isSelected: state.questionTypes.contains('MCQ'),
                  onTap: () => notifier.toggleQuestionType('MCQ'),
                ),
                QuestionTypeChip(
                  label: 'True / False',
                  isSelected: state.questionTypes.contains('True/False') || state.questionTypes.contains('True / False'),
                  onTap: () {
                    if (state.questionTypes.contains('True/False')) {
                      notifier.toggleQuestionType('True/False');
                    } else if (state.questionTypes.contains('True / False')) {
                      notifier.toggleQuestionType('True / False');
                    } else {
                      notifier.toggleQuestionType('True / False');
                    }
                  },
                ),
                QuestionTypeChip(
                  label: 'Integer',
                  isSelected: state.questionTypes.contains('Integer'),
                  onTap: () => notifier.toggleQuestionType('Integer'),
                ),
              ],
            ),
            if (state.showErrors && !state.isQuestionTypesValid) ...[
              const SizedBox(height: 8),
              const Text(
                'At least one question type is required',
                style: TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
