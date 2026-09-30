import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';

abstract final class AiFixtures {
  static List<AiSession> buildSessions() {
    return [
      AiSession(
        id: MockIds.aiSession1,
        title: 'CV review tips',
        topic: AiTopic.cv,
        isPinned: true,
        preview: 'Here are CV tips for AUB students…',
        updatedAt: MockClock.hoursAgo(2),
      ),
      AiSession(
        id: MockIds.aiSession2,
        title: 'Interview STAR method',
        topic: AiTopic.interview,
        preview: 'For interview practice, try the STAR method…',
        updatedAt: MockClock.daysAgo(1),
      ),
      AiSession(
        id: MockIds.aiSession3,
        title: 'Finance guidance',
        topic: AiTopic.finance,
        preview: 'I can explain how Vithey Finance works…',
        updatedAt: MockClock.daysAgo(2),
      ),
    ];
  }

  static Map<String, List<AiMessage>> buildMessages() {
    return {
      MockIds.aiSession1: [
        AiMessage(
          id: 'm1',
          sessionId: MockIds.aiSession1,
          role: AiMessageRole.user,
          content: 'How can I improve my CV?',
          createdAt: MockClock.hoursAgo(2),
        ),
        AiMessage(
          id: 'm2',
          sessionId: MockIds.aiSession1,
          role: AiMessageRole.assistant,
          content: mockReply('cv', AiTopic.cv),
          reasoning: mockReasoning('cv', AiTopic.cv),
          createdAt: MockClock.hoursAgo(2),
        ),
      ],
      MockIds.aiSession2: [
        AiMessage(
          id: 'm3',
          sessionId: MockIds.aiSession2,
          role: AiMessageRole.user,
          content: 'Help me prepare for interviews',
          createdAt: MockClock.daysAgo(1),
        ),
        AiMessage(
          id: 'm4',
          sessionId: MockIds.aiSession2,
          role: AiMessageRole.assistant,
          content: mockReply('interview', AiTopic.interview),
          reasoning: mockReasoning('interview', AiTopic.interview),
          createdAt: MockClock.daysAgo(1),
        ),
      ],
      MockIds.aiSession3: [
        AiMessage(
          id: 'm5',
          sessionId: MockIds.aiSession3,
          role: AiMessageRole.user,
          content: 'How do tuition payments work?',
          createdAt: MockClock.daysAgo(2),
        ),
        AiMessage(
          id: 'm6',
          sessionId: MockIds.aiSession3,
          role: AiMessageRole.assistant,
          content: mockReply('finance', AiTopic.finance),
          reasoning: mockReasoning('finance', AiTopic.finance),
          createdAt: MockClock.daysAgo(2),
        ),
      ],
    };
  }

  /// Quick prompts shown on the empty chat home (AI-BOT-06).
  /// Profile / Apply "Improve" CTAs can deep-link any custom prompt instead.
  static const suggestions = <String>[
    'Help me write a CV',
    'How do I apply for this job?',
    'Test my Flutter skills',
  ];

  static String mockReasoning(String message, AiTopic? topic) {
    final lower = message.toLowerCase();
    if (lower.contains('flutter') || lower.contains('skill')) {
      return 'The student wants a Flutter skill check, not a generic lecture. '
          'I will score beginner → job-ready, show a comparison table, then a small Dart snippet they can try, plus a 7-day practice plan.';
    }
    if (lower.contains('poster') || lower.contains('media') || topic == AiTopic.media) {
      return 'They need a clear difference between poster, job post, and video. '
          'A table plus when-to-use guidance will answer faster than a long essay.';
    }
    if (RegExp(r'\b(job|apply|application)\b').hasMatch(lower) || topic == AiTopic.job) {
      return 'This is an apply-flow question. I will walk through Vithey Jobs step by step, '
          'compare statuses in a table, and flag CV tailoring before they tap Apply.';
    }
    if (lower.contains('cv') || lower.contains('resume') || topic == AiTopic.cv) {
      return 'AUB CVs are usually one page. I will map each section, give a copy-ready summary, '
          'and a before/after table so they can edit immediately.';
    }
    if (lower.contains('interview') || topic == AiTopic.interview) {
      return 'STAR is the right frame. I will explain each letter, give a campus-flavored sample answer, '
          'and a short checklist they can rehearse tonight.';
    }
    if (lower.contains('finance') || lower.contains('fee') || topic == AiTopic.finance) {
      return 'Finance answers must stay general unless the student is verified. '
          'I will describe wallet / pay / receipts without inventing a real balance.';
    }
    return 'I will greet them as Vithey AI, show what I can help with in a table, '
        'and invite a specific next question so the chat stays useful.';
  }

  static String mockReply(String message, AiTopic? topic, {bool isStudentVerified = false}) {
    final lower = message.toLowerCase();
    if (lower.contains('flutter') || lower.contains('skill')) {
      return _flutterReply;
    }
    if (lower.contains('poster') || lower.contains('media') || topic == AiTopic.media) {
      return _mediaReply;
    }
    if (RegExp(r'\b(job|apply|application)\b').hasMatch(lower) || topic == AiTopic.job) {
      return _jobReply;
    }
    if (lower.contains('student') || lower.contains('club') || lower.contains('event') || topic == AiTopic.student) {
      return _studentReply;
    }
    if (lower.contains('cv') || lower.contains('resume') || topic == AiTopic.cv) {
      return _cvReply;
    }
    if (lower.contains('interview') || topic == AiTopic.interview) {
      return _interviewReply;
    }
    if (lower.contains('finance') || lower.contains('fee') || topic == AiTopic.finance) {
      return isStudentVerified ? _financeVerifiedReply : _financeGuestReply;
    }
    return _defaultReply;
  }

  static String mockRegenerateReply(String userMessage, {bool isStudentVerified = false}) {
    final lower = userMessage.toLowerCase();
    if (lower.contains('flutter') || lower.contains('skill')) {
      return _flutterRegen;
    }
    if (lower.contains('poster') || lower.contains('media')) {
      return _mediaRegen;
    }
    if (lower.contains('finance') || lower.contains('fee')) {
      return isStudentVerified ? _financeRegenVerified : _financeGuestReply;
    }
    if (lower.contains('cv') || lower.contains('resume')) {
      return _cvRegen;
    }
    if (lower.contains('interview')) {
      return _interviewReply;
    }
    if (RegExp(r'\b(job|apply)\b').hasMatch(lower)) {
      return _jobReply;
    }
    return _defaultReply;
  }

  static const _cvReply = '''
# CV review for AUB students

Keep it to **one page**. Recruiters skim in under 20 seconds, so every line should earn its place.

## Section map

| Section | What to include | AUB-specific tip |
| --- | --- | --- |
| Header | Name, city, email, GitHub / LinkedIn | Skip a photo unless the posting asks |
| Summary | 2–3 lines, major + proof | Mention AUB + one shipped project |
| Education | Degree, years, GPA if ≥ 3.3 | Add relevant coursework only |
| Experience | Internships, clubs, freelance | Start bullets with **action verbs** |
| Projects | 2–3 with stack + outcome | Link a GitHub repo if public |
| Skills | Grouped, honest levels | Separate *used in class* vs *used in a project* |

## Copy-ready summary

> Third-year AUB Computer Science student focused on Flutter and campus products. Built a job-match flow used in class demos, and led a 6-person club hackathon team. Looking for a mobile internship where I can ship features, not only tutorials.

## Bullet formula

1. **Verb** — Designed / Built / Led / Reduced
2. **What** — the feature or event
3. **Proof** — number, time saved, or users

Example:

- Built a Flutter job-apply screen that cut the mock apply path from 6 taps to 3.
- Led a 12-person AUB club workshop on Git; 9 attendees shipped a PR the same week.

## Before you apply

- [ ] One page, consistent dates
- [ ] Keywords from the **job post** appear in Skills + bullets
- [ ] No placeholder `lorem` text
- [ ] PDF export looks clean on a phone

Want me to rewrite a specific section next? Paste it and I will return an edited version.''';

  static const _jobReply = '''
# How to apply on Vithey

Your CV draft is attached automatically when you tap **Apply**. Tailor the summary *before* that tap.

## Flow

1. Open **Jobs** and filter by role, campus, or remote.
2. Read **requirements** — highlight 3 keywords you already have.
3. Update your CV summary to those keywords (2 minutes).
4. Tap **Apply**. Status moves to *Submitted*.
5. Track it from **Profile → Applications**.

## Status meanings

| Status | What it means | What you do |
| --- | --- | --- |
| Draft | You started, not sent | Finish CV, then Apply |
| Submitted | Employer can see you | Wait; do not spam |
| Reviewing | Recruiter opened it | Prep a STAR story |
| Interview | They want to talk | Confirm time, test camera |
| Offer | Decision in writing | Read terms before accepting |
| Closed | Role filled / expired | Reuse the tailored CV elsewhere |

## Fit check (quick)

```text
Must-have skills in the post:  Flutter, REST, Git
You can show proof for:        Flutter, Git
Gap to mention honestly:       REST (coursework only)
```

> **Tip:** If you match fewer than half the must-haves, still apply *only* if you have a strong project in the same domain. Otherwise spend 30 minutes on a related project first.

I can rewrite your summary for a specific posting if you paste the job title and 4–5 requirements.''';

  static const _interviewReply = '''
# Interview prep — STAR method

STAR keeps answers short and specific. Aim for **60–90 seconds** per story.

| Letter | Meaning | Prompt to yourself |
| --- | --- | --- |
| **S** | Situation | Where / when / who? |
| **T** | Task | What was *your* job? |
| **A** | Action | What did *you* do? (not “we”) |
| **R** | Result | Number, lesson, or shipped outcome |

## Sample (campus project)

> **S** — Our AUB club app crashed when 40 people joined an event at once.  
> **T** — I owned the event-join screen.  
> **A** — I added pagination, a loading state, and retried failed joins.  
> **R** — Peak join time dropped from ~8s to ~2s in our mock test, and the demo day ran without a freeze.

## Tonight’s checklist

1. Pick **3 stories**: teamwork, a bug you fixed, a time you asked for help.
2. Write each as four bullets (S-T-A-R).
3. Say them out loud once — cut filler (“basically”, “like”).
4. Prepare one question for *them* (team, first project, internship length).

Story bank
- Conflict on a group project
- Deadline you still hit
- Feature you learned the week you shipped it

If you tell me the role (e.g. Flutter intern), I will draft three STAR stories in your voice.''';

  static const _flutterReply = '''
# Flutter skills check

Here is an honest, campus-level scorecard — not a certificate, a practice map.

## Where you likely are

| Area | Starter | Job-ready | How to prove it |
| --- | --- | --- | --- |
| Widgets | `StatelessWidget` screens | Extracted widgets + theme | Screenshot + GitHub |
| State | `setState` only | GetX / Riverpod / Bloc | One feature, not a tutorial clone |
| Lists | Dummy arrays | Pagination + empty/error | Pull-to-refresh |
| Networking | `http.get` in the widget | Repository + models | Loading + failure UI |
| Navigation | `Navigator.push` | Named routes / GetX | Deep link into a detail |
| Quality | App “works on my phone” | Analyze clean, no `print` | `flutter analyze` |

## Mini challenge (copy into DartPad or your app)

```dart
class SkillChip extends StatelessWidget {
  const SkillChip({super.key, required this.label, required this.level});

  final String label;
  final int level; // 1–5

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('\$label  •  \$level/5'),
    );
  }
}
```

Replace `Chip` with your Vithey pill if you are working in this repo.

## 7-day drill

1. **Day 1–2** — Rebuild one screen from Vithey (composer or a list tile) without copy-paste.
2. **Day 3** — Move API-looking data behind a repository.
3. **Day 4** — Empty, loading, and error states.
4. **Day 5** — Theme tokens only (no random hex).
5. **Day 6** — Write 3 widget tests *or* a golden for one card.
6. **Day 7** — Record a 60s walkthrough; put the link on your CV.

> If you can explain **why** a widget rebuilds, you are past beginner — even if the UI is still simple.

Tell me what you have already built (screens, packages) and I will mark each row Starter vs Job-ready with evidence.''';

  static const _flutterRegen = '''
# Alternate Flutter plan

Same goal, tighter loop.

| Day | Build | Done when |
| --- | --- | --- |
| 1 | List + detail | Back button restores scroll |
| 2 | Form + validation | Invalid submit does not crash |
| 3 | Fake API delay | You see a skeleton, then data |
| 4 | Offline empty | Friendly copy, not a red error |

```dart
Future<List<String>> loadSkills() async {
  await Future<void>.delayed(const Duration(milliseconds: 400));
  return ['Dart', 'Flutter', 'Git'];
}
```

Ship one vertical slice instead of five half-screens.''';

  static const _mediaReply = '''
# Poster vs job post vs video

Pick the format that matches the **action** you want.

| Type | Best for | Primary action | Avoid when |
| --- | --- | --- | --- |
| **Poster** | Events, clubs, announcements | View / save | You need applicants |
| **Job post** | Hiring with a structured apply | **Apply** + CV | It is only a vibe / aesthetic |
| **Video** | Walkthroughs, campus life | Watch / share | Policy or details must be scanned |

## Rule of thumb

- Need **people in a room** → poster
- Need **applications** → job post
- Need **emotion or a demo** → video

> Job posts convert. Posters broadcast. Videos explain.

To apply: open **Jobs**, read the listing, tailor your CV, tap **Apply**. Posters do not collect CVs.''';

  static const _mediaRegen = '''
# Another comparison

```text
Poster   →  reach
Job post →  pipeline
Video    →  story
```

| Question | Format |
| --- | --- |
| When / where is the event? | Poster |
| Who should send a CV? | Job post |
| How does the product feel? | Video |

Mix them: a job post can *link* a video, but the Apply button stays on the job post.''';

  static const _studentReply = '''
# Student life on Vithey

Use the feed for discovery, Profile for proof, Finance only after verification.

| Area | What you do | Why it matters |
| --- | --- | --- |
| Home feed | Events, posters, jobs | See campus in one scroll |
| Follow | Clubs + classmates | Their posts surface first |
| Verify student | Profile → verification | Unlocks Finance |
| Jobs | Apply with your CV | Internships without leaving the app |

## This week

1. Complete **student verification** if you have not.
2. Follow 3 clubs you actually attend.
3. Save one job post and tailor one CV bullet to it.

> Verification is a one-time campus check — I never invent your ID status.

What do you want next: events, clubs, or a first job apply?''';

  static const _financeVerifiedReply = '''
# Vithey Finance (verified student)

You are **student-verified**, so I can explain the product — I still cannot see your live balance.

| Tab | What it is | What I will never do |
| --- | --- | --- |
| Wallet | Campus balance + activity | Quote a fake number |
| Payments | Tuition / club fees | Charge anything |
| History | Receipts per transaction | Hide a payment from you |

## Habits that help

1. Check **due dates** before the weekend.
2. Download a receipt right after a successful pay.
3. If a payment is pending, wait — do not double-pay.

> Open the **Finance** tab for live records. This chat is guidance only.

If a status looks wrong, screenshot History (hide amounts if you prefer) and ask me what the status *means* — not to change it.''';

  static const _financeGuestReply = '''
# Vithey Finance (overview)

Detailed account help unlocks after **student verification** in Profile.

| I can do now | I cannot do until you verify |
| --- | --- |
| Explain wallet / pay / receipts | Read your real balance |
| Describe statuses in general | Move or refund money |
| Point you to Profile → Verify | Bypass campus checks |

Vithey Finance in one line: **wallet, campus payments, receipts** — and I never store your live totals in chat.

Verify from **Profile**, then ask again if you want the verified walkthrough.''';

  static const _financeRegenVerified = '''
# Extra Finance notes (verified)

- Set a reminder **2 days** before a tuition installment.
- Keep receipts in History; they are the source of truth.
- Pending ≠ failed. Wait, then refresh Finance — do not retry blindly.

Still no live numbers from me. Use the Finance tab for that.''';

  static const _cvRegen = '''
# Alternate CV outline

```text
Header → Summary → Education → Experience → Projects → Skills
```

| Weak | Strong |
| --- | --- |
| “Responsible for the app” | “Shipped the apply button used in the class demo” |
| “Team player” | “Paired with 2 classmates to split API + UI” |
| “Know Flutter” | “Flutter lists, forms, and GetX screens in Vithey” |

Lead with outcomes. Cut adjectives that you cannot prove.''';

  static const _defaultReply = '''
# I am Vithey AI

Campus assistant for AUB-style workflows — CVs, jobs, interviews, student life, and Finance *guidance*.

| Ask me about | You will get |
| --- | --- |
| **CV** | Section table, sample summary, checklist |
| **Jobs** | Apply steps + status table |
| **Interview** | STAR + a worked example |
| **Flutter / skills** | Scorecard, code snippet, 7-day drill |
| **Finance** | Product map (live balance stays in the Finance tab) |

Try:
- Help me write a CV
- How do I apply for this job?
- Test my Flutter skills

> I reason first, then answer with structure (tables, lists, code) so you can act — not only read.

Pick one of those, or paste a job post / CV section and I will edit it in place.''';
}
