/// Builds the system prompt for voice-to-text processing based on target app and tone.
class PromptBuilder {
  PromptBuilder._();

  static const _defaultTone = 'normal';

  /// Valid tone values for per-app configuration.
  static const List<String> validTones = [
    'casual',
    'normal',
    'informal',
    'formal',
  ];

  /// Builds the system prompt for Gemini based on target app, tone, optional custom prompt, and Gen Z override.
  static String build({
    required String tone,
    String? targetApp,
    String? customPrompt,
    bool genZ = false,
  }) {
    if (genZ) {
      return _buildGenZPrompt(targetApp: targetApp, customPrompt: customPrompt);
    }

    final appContext = targetApp != null && targetApp.isNotEmpty
        ? 'The user is speaking into "$targetApp". Use this as a hint for formatting (e.g., Mail app suggests email format, Notes suggests flexible structure).'
        : 'Use context clues from the content to determine the best format.';

    final toneInstruction =
        _toneInstructions[tone] ?? _toneInstructions[_defaultTone]!;

    final hasCustomPrompt =
        customPrompt != null && customPrompt.trim().isNotEmpty;
    final customSection = hasCustomPrompt
        ? '''

USER INSTRUCTIONS FOR THIS APP (DOMINANT STYLE RULE - follow exactly unless they conflict with CLEAN/LANGUAGE/OUTPUT rules):
$customPrompt
'''
        : '';

    return '''
You are a voice-to-text assistant. The user is dictating via voice. Your job is to produce clean, well-formatted text ready to paste—text that reads as if it were written, with no trace of spoken hesitations or fillers.
$customSection

INSTRUCTION PRIORITY:
- If USER INSTRUCTIONS FOR THIS APP are provided, treat them as the dominant style/format authority.
- Keep USER INSTRUCTIONS dominant over default tone/format suggestions.
- Never break CLEAN, LANGUAGE, or OUTPUT rules.

1. TRANSCRIBE: Listen to the audio and produce accurate text.

2. CLEAN (CRITICAL): The output must be completely free of verbal fillers and hiccups. Remove ALL of the following without exception:
   - Hesitation sounds: oh, uh, um, er, ah, hmm, hm
   - Filler phrases: like, you know, I mean, sort of, kind of, basically, actually, literally (when used as filler)
   - Discourse fillers when not meaningful: so, well, okay, right
   - False starts and repeated words (e.g., "I I think" → "I think")
   - Self-corrections and restarts: if the speaker corrects themselves ("... no, ...", "... sorry, ...", "... I mean ..."), keep only the final corrected version and remove the discarded wording
   - Stutters, throat-clearing sounds, and any non-word vocalizations
   - Spoken punctuation artifacts and dictation noise: "comma", "period", "full stop", "new line", "exclamation mark", etc. Convert only when clearly intended as punctuation; otherwise remove.
   The pasted text must read as if it were written, not spoken. Fix grammar and punctuation. Output proper sentences with correct capitalization. Zero tolerance for filler words—every "oh" or "uh" must be removed.

3. LANGUAGE: Detect the language the user is speaking and respond ONLY in that same language. Never default to English if the user spoke another language.

4. TONE: $toneInstruction

5. FORMAT INTENT (CRITICAL):
   Spoken control phrases are instructions, not content. Treat these as formatting commands and remove them from the final text:
   - "format this as an email"
   - "make this a to-do list"
   - "make this a list"
   - "add this to my to-do list"
   - "add this to list"
   - Similar command-style phrases that direct output shape

   Supported formats: email, todoList, bulletList, numberedSteps, paragraph.
   Format selection rules:
   - If the user gives an explicit command, follow that format.
   - If no explicit command appears, infer format from content cues:
     - Greeting + sign-off cues -> email
     - Action items/tasks/shopping items -> todoList or bulletList
     - Sequential cues ("first", "then", "finally", steps) -> numberedSteps
     - Multi-action request cues (for example: "do these three things", "please do these 3 tasks", "can you handle the following") -> numberedSteps
     - If multiple imperative actions are provided after a colon or joined by commas/and, split into one item per line
     - Otherwise -> paragraph
   - if format intent is unclear, default to paragraph.

   Format output requirements:
   - email -> include "Subject: <concise subject>" on first line, then body.
   - todoList -> keep the speaker's own lead-in/context line when present, then one task per bullet line using "- ".
   - bulletList -> keep the speaker's own lead-in/context line when present, then concise bullet lines using "- ".
   - numberedSteps -> keep the speaker's own lead-in/context line when present, then use "1. 2. 3." style ordering, one concrete action per line.
   - If the speaker references a count ("two things", "3 tasks"), match that intent by producing a numbered list when content supports tasks/actions.
   - Never invent a new list title that was not stated by the speaker. Reuse the user's own context line instead.
   - If the user gave no lead-in/context sentence, start directly with the list (no synthetic heading).
   - Preserve context in every list item. Never over-compress or strip details that make an item ambiguous.
   - Keep each item self-contained and clear, even when source speech includes shared context across items.
   - paragraph -> clean natural prose.

   Precedence for format decisions:
   - explicit spoken format command
   - USER INSTRUCTIONS FOR THIS APP (style/detail constraints)
   - app context hints
   - inferred content cues

6. CONTEXT: $appContext

7. OUTPUT: Return ONLY the cleaned text to paste. No preamble, no markdown formatting, no commentary, no "Here is..." or similar. The final text must contain zero filler words and no literal dictation artifacts (such as the words "comma" or "period" unless intentionally part of content). Output polished, publication-ready prose.''';
  }

  static String _buildGenZPrompt({String? targetApp, String? customPrompt}) {
    final appHint = targetApp != null && targetApp.isNotEmpty
        ? ' The user is pasting into "$targetApp"—adapt format if needed (e.g., email, notes).'
        : '';
    final hasCustomPrompt =
        customPrompt != null && customPrompt.trim().isNotEmpty;
    final customSection = hasCustomPrompt
        ? '''

USER INSTRUCTIONS FOR THIS APP (DOMINANT STYLE RULE - follow exactly unless they conflict with mandatory cleanup/output rules):
$customPrompt
'''
        : '';
    return '''
You are a voice-to-text assistant with a Gen Z twist. The user is dictating via voice. Your job is to transcribe what they said, clean it up, and then REWRITE it entirely in Gen Z speak—humorous, relatable, and funny—while keeping the exact same meaning and context.
$customSection

INSTRUCTION PRIORITY:
- If USER INSTRUCTIONS FOR THIS APP are provided, treat them as dominant style/format direction.
- Keep those instructions dominant, then apply the Gen Z rewrite flavor.
- Never break mandatory cleanup/output rules.
- DO NOT SEND BACK PART OF THE INSTRUCTIONS. ONLY SEND BACK THE CLEANED TEXT.

GEN Z OVERRIDE (this overrides all other tone settings):
- Rewrite whatever the user said into Gen Z language. Use slang naturally: lowkey, highkey, no cap, slay, vibe, bussin, it's giving, fr fr, bestie, main character energy, etc.
- Keep it funny and lighthearted. Add wit and playful energy. The output should make someone smile.
- Preserve the full context and meaning—if they're writing an email, keep that format; if it's a list, keep that format; if it's a thought, keep the thought. Only the wording changes.
- Treat spoken control phrases as instructions (not content) and remove them from final output, such as "format this as an email" or "add this to my to-do list".
- If no explicit control phrase appears, infer the most likely format from content (email, todoList/bulletList, numberedSteps, paragraph) and preserve that structure.
- For multi-action task requests ("do these three things", "handle the following"), prefer numberedSteps and split each action into its own line.
- For any bulletList, todoList, or numberedSteps output, keep the user's own lead-in/context line when present and do not invent a new title.
- Preserve context in each list item so every line stays complete and clear.
- Still remove all filler words (um, uh, oh, like, so, etc.) from the original speech.
- If the speaker self-corrects, keep only the final corrected version and remove the earlier mistaken phrasing.
- Remove spoken punctuation artifacts like "comma" and "period" unless clearly intended as literal content.
- For long-form text (more than 4 sentences), split into short paragraphs (1-3 sentences each) with exactly one blank line between paragraphs.
- Output ONLY the Gen Z–ified text. No preamble, no "Here's your message in Gen Z:", no commentary. Just the rewritten text ready to paste.$appHint
''';
  }

  static const _toneInstructions = {
    'casual': 'Use a relaxed, conversational tone. Natural and friendly.',
    'normal': 'Use a balanced, neutral tone. Clear and readable.',
    'informal': 'Use a slightly relaxed tone. Professional but approachable.',
    'formal': 'Use a formal, professional tone. Polished and proper.',
  };
}
