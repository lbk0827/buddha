/// assets/content/*.json 파서. PRD 「콘텐츠 JSON」 스키마를 그대로 따른다.
library;

enum DialogueRole { guide, observe, humor, ack, question, choice }

enum DialogueIntensity { low, mid }

T _enumOf<T extends Enum>(List<T> values, String? raw, T fallback) {
  if (raw == null) return fallback;
  for (final v in values) {
    if (v.name == raw) return v;
  }
  return fallback;
}

List<String> _strings(dynamic v) =>
    (v as List?)?.map((e) => e.toString()).toList() ?? const [];

class DialogueButton {
  final String label;
  final String? action;
  const DialogueButton({required this.label, this.action});

  factory DialogueButton.fromJson(dynamic json) {
    if (json is String) return DialogueButton(label: json);
    final m = json as Map<String, dynamic>;
    return DialogueButton(
      label: (m['label'] ?? m['text'] ?? '').toString(),
      action: m['action']?.toString(),
    );
  }
}

class DialogueItem {
  final String id;
  final String text;
  final String screen;
  final DialogueRole role;
  final DialogueIntensity intensity;

  /// guide | humor | creative | paraphrase
  final String origin;
  final String? rootId;

  /// 이 대사가 필요로 하는 컨텍스트 키 (예: practicedSec).
  final List<String> requires;

  /// 노출 금지 조건. "chip:heavy", "safety" 등.
  final List<String> forbidWhen;

  /// 0이면 반복 제한 없음. 14면 14일 내 재노출 금지.
  final int repeatDays;

  /// daily | after_worry:{chip} | notification | null
  final String? pool;
  final List<DialogueButton> buttons;

  const DialogueItem({
    required this.id,
    required this.text,
    required this.screen,
    required this.role,
    required this.intensity,
    required this.origin,
    required this.rootId,
    required this.requires,
    required this.forbidWhen,
    required this.repeatDays,
    required this.pool,
    required this.buttons,
  });

  bool get isHumor => role == DialogueRole.humor;

  factory DialogueItem.fromJson(Map<String, dynamic> m) => DialogueItem(
        id: m['id'].toString(),
        text: m['text'].toString(),
        screen: m['screen'].toString(),
        role: _enumOf(DialogueRole.values, m['role']?.toString(),
            DialogueRole.guide),
        intensity: _enumOf(DialogueIntensity.values,
            m['intensity']?.toString(), DialogueIntensity.low),
        origin: m['origin']?.toString() ?? 'guide',
        rootId: m['rootId']?.toString(),
        requires: _strings(m['requires']),
        forbidWhen: _strings(m['forbidWhen']),
        repeatDays: (m['repeatDays'] as num?)?.toInt() ?? 0,
        pool: m['pool']?.toString(),
        buttons: (m['buttons'] as List?)
                ?.map(DialogueButton.fromJson)
                .toList() ??
            const [],
      );
}

class Scripture {
  final String name;
  final String ref;
  final String paraphraseKo;
  final String? sourceNote;
  final String? sourceUrl;

  const Scripture({
    required this.name,
    required this.ref,
    required this.paraphraseKo,
    this.sourceNote,
    this.sourceUrl,
  });

  factory Scripture.fromJson(Map<String, dynamic> m) => Scripture(
        name: m['name']?.toString() ?? '',
        ref: m['ref']?.toString() ?? '',
        paraphraseKo: m['paraphraseKo']?.toString() ?? '',
        sourceNote: m['sourceNote']?.toString(),
        sourceUrl: m['sourceUrl']?.toString(),
      );
}

class SmallAction {
  final String text;
  final String link;
  const SmallAction({required this.text, required this.link});

  factory SmallAction.fromJson(Map<String, dynamic> m) => SmallAction(
        text: m['text']?.toString() ?? '',
        link: m['link']?.toString() ?? '',
      );
}

class RootItem {
  final String id;
  final String kind;
  final String topic;
  final String seonsaLine;
  final String plainExplanation;
  final Scripture scripture;

  /// verified | partial | unverified
  final String sourceStatus;
  final String? originalContext;
  final String? traditionNote;
  final SmallAction? smallAction;
  final List<String> doNotUse;

  /// draft | edited | reviewed | public. 앱은 public만 로드한다 (FR-5.1).
  final String reviewStatus;

  const RootItem({
    required this.id,
    required this.kind,
    required this.topic,
    required this.seonsaLine,
    required this.plainExplanation,
    required this.scripture,
    required this.sourceStatus,
    required this.originalContext,
    required this.traditionNote,
    required this.smallAction,
    required this.doNotUse,
    required this.reviewStatus,
  });

  bool get isPublic => reviewStatus == 'public';

  factory RootItem.fromJson(Map<String, dynamic> m) => RootItem(
        id: m['id'].toString(),
        kind: m['kind']?.toString() ?? 'paraphrase',
        topic: m['topic']?.toString() ?? '',
        seonsaLine: m['seonsaLine']?.toString() ?? '',
        plainExplanation: m['plainExplanation']?.toString() ?? '',
        scripture:
            Scripture.fromJson((m['scripture'] as Map?)?.cast<String, dynamic>() ?? {}),
        sourceStatus: m['sourceStatus']?.toString() ?? 'unverified',
        originalContext: m['originalContext']?.toString(),
        traditionNote: m['traditionNote']?.toString(),
        smallAction: m['smallAction'] == null
            ? null
            : SmallAction.fromJson(
                (m['smallAction'] as Map).cast<String, dynamic>()),
        doNotUse: _strings(m['doNotUse']),
        reviewStatus: m['reviewStatus']?.toString() ?? 'draft',
      );
}

class TestOption {
  final String text;
  final String dir;
  const TestOption({required this.text, required this.dir});

  factory TestOption.fromJson(Map<String, dynamic> m) => TestOption(
        text: m['text'].toString(),
        dir: m['dir'].toString(),
      );
}

class TestQuestion {
  final String id;

  /// G | A | C
  final String element;
  final String context;
  final String text;
  final List<TestOption> options;
  final bool skippable;
  final bool deep;

  const TestQuestion({
    required this.id,
    required this.element,
    required this.context,
    required this.text,
    required this.options,
    required this.skippable,
    required this.deep,
  });

  factory TestQuestion.fromJson(Map<String, dynamic> m) => TestQuestion(
        id: m['id'].toString(),
        element: m['element'].toString(),
        context: m['context']?.toString() ?? '',
        text: m['text'].toString(),
        options: (m['options'] as List)
            .map((e) => TestOption.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        skippable: m['skippable'] as bool? ?? true,
        deep: m['deep'] as bool? ?? false,
      );
}

class TypeSymbol {
  final String image;
  final String meaning;
  final String iconography;
  const TypeSymbol({
    required this.image,
    required this.meaning,
    required this.iconography,
  });

  factory TypeSymbol.fromJson(Map<String, dynamic> m) => TypeSymbol(
        image: m['image']?.toString() ?? '',
        meaning: m['meaning']?.toString() ?? '',
        iconography: m['iconography']?.toString() ?? '',
      );
}

class TypeResultContent {
  final String name;
  final String line;
  final TypeSymbol? symbol;
  const TypeResultContent({
    required this.name,
    required this.line,
    this.symbol,
  });

  factory TypeResultContent.fromJson(Map<String, dynamic> m) =>
      TypeResultContent(
        name: m['name']?.toString() ?? '',
        line: m['line']?.toString() ?? '',
        symbol: m['symbol'] is Map
            ? TypeSymbol.fromJson((m['symbol'] as Map).cast<String, dynamic>())
            : null,
      );
}

class DirectionContent {
  final String interp;
  final String strength;
  final String action;
  final String? actionLink;

  const DirectionContent({
    required this.interp,
    required this.strength,
    required this.action,
    this.actionLink,
  });

  factory DirectionContent.fromJson(Map<String, dynamic> m) => DirectionContent(
        interp: m['interp']?.toString() ?? '',
        strength: m['strength']?.toString() ?? '',
        action: m['action']?.toString() ?? '',
        actionLink: m['actionLink']?.toString(),
      );
}

class ScoringRules {
  final int minAnswers;
  final int deepMaxAnswered;
  final int deepMaxShown;

  const ScoringRules({
    this.minAnswers = 3,
    this.deepMaxAnswered = 3,
    this.deepMaxShown = 5,
  });

  factory ScoringRules.fromJson(Map<String, dynamic> m) => ScoringRules(
        minAnswers: (m['minAnswers'] as num?)?.toInt() ?? 3,
        deepMaxAnswered: (m['deepMaxAnswered'] as num?)?.toInt() ?? 3,
        deepMaxShown: (m['deepMaxShown'] as num?)?.toInt() ?? 5,
      );
}

class TestContent {
  final String basis;

  /// 'G' → [R,E,U,D] 등
  final Map<String, List<String>> elements;

  /// 'kwan' → [R,F] 등
  final Map<String, List<String>> types;
  final List<TestQuestion> questions;
  final Map<String, TypeResultContent> typeResults;
  final Map<String, DirectionContent> directions;
  final ScoringRules scoring;

  const TestContent({
    required this.basis,
    required this.elements,
    required this.types,
    required this.questions,
    required this.typeResults,
    required this.directions,
    required this.scoring,
  });

  List<TestQuestion> get baseQuestions =>
      questions.where((q) => !q.deep).toList();
  List<TestQuestion> get deepQuestions =>
      questions.where((q) => q.deep).toList();

  /// 방향 → 소속 요소 ('R' → 'G').
  String? elementOfDirection(String dir) {
    for (final e in elements.entries) {
      if (e.value.contains(dir)) return e.key;
    }
    return null;
  }

  factory TestContent.fromJson(Map<String, dynamic> m) {
    final results = (m['results'] as Map?)?.cast<String, dynamic>() ?? {};
    final directionsRaw =
        (results['directions'] as Map?)?.cast<String, dynamic>() ?? {};

    final typeResults = <String, TypeResultContent>{};
    for (final e in results.entries) {
      if (e.key == 'directions') continue;
      if (e.value is Map) {
        typeResults[e.key] = TypeResultContent.fromJson(
            (e.value as Map).cast<String, dynamic>());
      }
    }

    return TestContent(
      basis: m['basis']?.toString() ?? '최근 한 달의 나',
      elements: ((m['elements'] as Map?)?.cast<String, dynamic>() ?? {})
          .map((k, v) => MapEntry(k, _strings(v))),
      types: ((m['types'] as Map?)?.cast<String, dynamic>() ?? {})
          .map((k, v) => MapEntry(k, _strings(v))),
      questions: (m['questions'] as List? ?? [])
          .map((e) => TestQuestion.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      typeResults: typeResults,
      directions: directionsRaw.map((k, v) => MapEntry(
          k, DirectionContent.fromJson((v as Map).cast<String, dynamic>()))),
      scoring: ScoringRules.fromJson(
          (m['scoring'] as Map?)?.cast<String, dynamic>() ?? {}),
    );
  }
}

class SafetyContact {
  final String name;
  final String number;
  final String? hours;
  final String? note;

  const SafetyContact({
    required this.name,
    required this.number,
    this.hours,
    this.note,
  });

  factory SafetyContact.fromJson(Map<String, dynamic> m) => SafetyContact(
        name: m['name']?.toString() ?? '',
        number: m['number']?.toString() ?? '',
        hours: m['hours']?.toString(),
        note: m['note']?.toString(),
      );
}

class SafetyScreenText {
  final String title;
  final String body;
  final String primaryButton;
  final String secondaryButton;

  const SafetyScreenText({
    required this.title,
    required this.body,
    required this.primaryButton,
    required this.secondaryButton,
  });

  factory SafetyScreenText.fromJson(Map<String, dynamic> m) => SafetyScreenText(
        title: m['title']?.toString() ?? '잠깐 멈추자.',
        body: m['body']?.toString() ??
            '지금 많이 힘들어 보인다. 혼자 두고 싶지 않다. 아래 번호는 언제든 연결된다.',
        primaryButton: m['primaryButton']?.toString() ?? '상담 연락처 보기',
        secondaryButton: m['secondaryButton']?.toString() ?? '아니에요, 계속할게요',
      );
}

class SafetyContent {
  final List<String> keywords;
  final List<RegExp> patterns;
  final SafetyScreenText screen;
  final List<SafetyContact> contacts;

  const SafetyContent({
    required this.keywords,
    required this.patterns,
    required this.screen,
    required this.contacts,
  });

  /// safety.json이 없거나 깨졌을 때도 안전 화면을 끄지 않는다 (PRD safety.json 주석).
  static SafetyContent fallback() => SafetyContent(
        keywords: const [],
        patterns: const [],
        screen: SafetyScreenText.fromJson(const {}),
        contacts: const [
          SafetyContact(
              name: '자살예방상담전화', number: '109', hours: '24시간', note: null),
          SafetyContact(
              name: '정신건강위기상담전화',
              number: '1577-0199',
              hours: '24시간',
              note: null),
        ],
      );

  factory SafetyContent.fromJson(Map<String, dynamic> m) {
    final patterns = <RegExp>[];
    for (final raw in _strings(m['patterns'])) {
      try {
        patterns.add(RegExp(raw));
      } on FormatException {
        // 검수 전 초안이 깨진 정규식을 담고 있어도 앱은 계속 뜬다.
      }
    }
    final contacts = (m['contacts'] as List? ?? [])
        .map((e) => SafetyContact.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    return SafetyContent(
      keywords: _strings(m['keywords']),
      patterns: patterns,
      screen: SafetyScreenText.fromJson(
          (m['screen'] as Map?)?.cast<String, dynamic>() ?? {}),
      contacts: contacts.isEmpty ? fallback().contacts : contacts,
    );
  }
}
