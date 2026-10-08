import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// 키캡 한 개. 그림([icon]) 또는 큰 글자([big]) 하나와, 아래 작은 [label].
///
/// 글자는 그림에 굽지 않고 앱 글꼴로 쓴다. 그림 모델이 한글을 틀리게 그려서다.
@immutable
class KeycapKey {
  const KeycapKey(this.id, this.label, {this.big, this.bigColor});

  final String id;
  final String label;

  /// 그림 대신 크게 찍는 글자(「+1」). null 이면 그림을 쓴다.
  final String? big;
  final Color? bigColor;

  /// `assets/keycap/icon_<id>.webp`. 그림은 docs/키캡_리소스_발주서.md.
  String get icon => 'assets/keycap/icon_$id.webp';
}

/// 키캡 색 한 벌. 윗면, 옆면(위→아래), 글자.
@immutable
class KeycapColors {
  const KeycapColors({
    required this.top,
    required this.wallTop,
    required this.wallBottom,
    required this.ink,
  });

  final Color top;
  final Color wallTop;
  final Color wallBottom;
  final Color ink;
}

/// 키링 하나 — 키캡 네 개가 한 줄.
@immutable
class KeycapRing {
  const KeycapRing(this.name, this.colors, this.keys);

  final String name;
  final KeycapColors colors;
  final List<KeycapKey> keys;
}

const kKeycapRings = <KeycapRing>[
  KeycapRing(
    '오늘의 수행',
    KeycapColors(
      top: Color(0xFFFBFAF7),
      wallTop: Color(0xFFECE8E1),
      wallBottom: Color(0xFFCFC8BC),
      ink: Color(0xFF2B2420),
    ),
    [
      KeycapKey('merit', '공덕', big: '+1', bigColor: Color(0xFFD98B2B)),
      KeycapKey('worry', '번뇌', big: '-108', bigColor: Color(0xFFC0392B)),
      KeycapKey('nirvana', '해탈'),
      KeycapKey('bulb', '깨닫는 중'),
    ],
  ),
  KeycapRing(
    '직장인 수행',
    KeycapColors(
      top: Color(0xFFF6EBD3),
      wallTop: Color(0xFFE8D9BA),
      wallBottom: Color(0xFFC9B48C),
      ink: Color(0xFF3A2E22),
    ),
    [
      KeycapKey('clock', '칼퇴 성불'),
      KeycapKey('tomorrow', '내일 깨닫자'),
      KeycapKey('meeting', '회의 해탈'),
      KeycapKey('battery', '멘탈 충전'),
    ],
  ),
  KeycapRing(
    '쉼',
    KeycapColors(
      top: Color(0xFFD6E3C1),
      wallTop: Color(0xFFC0D0A6),
      wallBottom: Color(0xFF97AC7B),
      ink: Color(0xFF26332B),
    ),
    [
      KeycapKey('campfire', '멍 때리기'),
      KeycapKey('breeze', '숨 고르기'),
      KeycapKey('lotus', '자비 충전'),
      KeycapKey('cloud', '지나간다'),
    ],
  ),
  KeycapRing(
    '밈',
    KeycapColors(
      top: Color(0xFFF9D9DF),
      wallTop: Color(0xFFF0C0CA),
      wallBottom: Color(0xFFD495A3),
      ink: Color(0xFF52202E),
    ),
    [
      KeycapKey('rocket', '극락 가즈아'),
      KeycapKey('rebirth', '윤회 중'),
      KeycapKey('gassho', '성불하십쇼'),
      KeycapKey('wallet', '무소유'),
    ],
  ),
];

/// 3차원 점. 키링 좌표: x 는 키가 늘어선 쪽(오른쪽 뒤로), y 는 앞에서 뒤로,
/// z 는 위. 키캡 바닥 한 변이 1 이다.
@immutable
class KeycapPoint {
  const KeycapPoint(this.x, this.y, this.z);
  final double x, y, z;

  KeycapPoint operator +(KeycapPoint o) =>
      KeycapPoint(x + o.x, y + o.y, z + o.z);
  KeycapPoint operator -(KeycapPoint o) =>
      KeycapPoint(x - o.x, y - o.y, z - o.z);
  KeycapPoint scale(double k) => KeycapPoint(x * k, y * k, z * k);
  double dot(KeycapPoint o) => x * o.x + y * o.y + z * o.z;
  KeycapPoint cross(KeycapPoint o) =>
      KeycapPoint(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  KeycapPoint get unit {
    final l = math.sqrt(dot(this));
    return l == 0 ? this : scale(1 / l);
  }

  static KeycapPoint lerp(KeycapPoint a, KeycapPoint b, double t) =>
      a + (b - a).scale(t);
}

/// 키링을 비스듬히 내려다본 모습 — 왼쪽 앞 위에서 본다. 키가 오른쪽 뒤로
/// 늘어서고, 키캡의 윗면·앞면·왼쪽 옆면이 보인다.
///
/// 평행 투영이라 같은 평면 위의 사각형은 평행사변형이 된다. 그래서 윗면
/// 그림·글자는 아핀 변환([topFace]) 하나로 붙는다.
abstract final class KeycapScene {
  /// 3차원 축 하나가 화면에서 가는 방향(키 한 변 = 1).
  static const ex = Offset(0.95, -0.12);
  static const ey = Offset(-0.24, -0.64);
  static const ez = Offset(0, -0.50);

  /// 보는 사람 쪽 방향 — 화면에서 한 점으로 겹치는 3차원 방향. 이 방향과
  /// 같은 쪽을 보는 면만 그린다.
  static final view = () {
    final r1 = KeycapPoint(ex.dx, ey.dx, ez.dx);
    final r2 = KeycapPoint(ex.dy, ey.dy, ez.dy);
    final d = r1.cross(r2);
    return d.y < 0 ? d : d.scale(-1);
  }();

  /// 빛이 오는 방향 — 왼쪽 앞 위.
  static final light = const KeycapPoint(-0.35, -0.55, 0.76).unit;

  /// 키 간격.
  static const pitch = 1.04;

  /// 키캡 높이. 윗면은 바닥보다 좁고, 앞쪽이 더 들어가 있다(OEM 모양).
  static const capHeight = 0.5;
  static const insetSide = 0.09;
  static const insetFront = 0.12;
  static const insetBack = 0.05;
  static const bottomRadius = 0.09;
  static const topRadius = 0.15;

  /// 눌리는 깊이와, 쉴 때 키캡 아래 스위치 위의 틈.
  static const travel = 0.13;
  static const gap = travel + 0.03;

  /// 투명 스위치 몸통.
  static const housingHeight = 0.5;
  static const housingInset = 0.025;

  /// 쇠붙이 — 첫 스위치 왼쪽 옆면 아래에 걸려 왼쪽 아래로 늘어진다.
  static const hookPoint = KeycapPoint(
    housingInset,
    0.3,
    -housingHeight + 0.12,
  );
  static const ringWidth = 1.35;
  static const ringAngle = -1.35;

  /// keyring.webp 높이 ÷ 폭, 오른쪽 끝 작은 고리 가운데의 가로 자리.
  /// 작은 고리 가운데는 그림 세로 가운데에 있다(tools/build_keycap_assets.py).
  static const ringAspect = 320 / 639;
  static const ringHookX = 594 / 639;

  static Offset project(KeycapPoint p) => ex * p.x + ey * p.y + ez * p.z;

  static double capBottom(double press) =>
      gap - travel * press.clamp(-0.3, 1.05);

  /// 둥근 모서리 사각형 둘레를 같은 수의 점으로. 바닥·윗면이 짝지어지도록
  /// 같은 모서리에서 시작해 같은 방향으로 돈다.
  static List<KeycapPoint> outline(
    double x0,
    double y0,
    double x1,
    double y1,
    double r,
    double z, {
    int perCorner = 6,
  }) {
    final corners = [
      (x1 - r, y0 + r, -math.pi / 2), // 오른쪽 앞
      (x1 - r, y1 - r, 0.0), // 오른쪽 뒤
      (x0 + r, y1 - r, math.pi / 2), // 왼쪽 뒤
      (x0 + r, y0 + r, math.pi), // 왼쪽 앞
    ];
    return [
      for (final (cx, cy, a0) in corners)
        for (var k = 0; k <= perCorner; k++)
          KeycapPoint(
            cx + r * math.cos(a0 + math.pi / 2 * k / perCorner),
            cy + r * math.sin(a0 + math.pi / 2 * k / perCorner),
            z,
          ),
    ];
  }

  static List<KeycapPoint> capBottomOutline(int i, double press) {
    final x0 = i * pitch;
    return outline(x0, 0, x0 + 1, 1, bottomRadius, capBottom(press));
  }

  static List<KeycapPoint> capTopOutline(int i, double press) {
    final x0 = i * pitch;
    return outline(
      x0 + insetSide,
      insetFront,
      x0 + 1 - insetSide,
      1 - insetBack,
      topRadius,
      capBottom(press) + capHeight,
    );
  }

  /// 윗면 그림을 붙이는 변환. 그림 좌표 (가로, 세로)는 키 한 변 = [s] 로
  /// 잰 값이고, 가로는 키가 늘어선 쪽, 세로 아래는 앞쪽이다.
  static Matrix4 topFace(int i, double press, double s, Offset origin) {
    final corner = KeycapPoint(
      i * pitch + insetSide,
      1 - insetBack,
      capBottom(press) + capHeight,
    );
    final a = origin + project(corner) * s;
    return Matrix4(
      ex.dx,
      ex.dy,
      0,
      0, //
      -ey.dx,
      -ey.dy,
      0,
      0,
      0,
      0,
      1,
      0,
      a.dx,
      a.dy,
      0,
      1,
    );
  }

  static double get topWidth => 1 - 2 * insetSide;
  static double get topDepth => 1 - insetFront - insetBack;

  /// 키 [i]가 화면에서 차지하는 볼록 다각형(키캡 + 스위치). 누를 키를 찾는 데 쓴다.
  static List<Offset> silhouette(int i, double press) {
    final x0 = i * pitch;
    final h = housingInset;
    return _hull([
      for (final p in capBottomOutline(i, press)) project(p),
      for (final p in capTopOutline(i, press)) project(p),
      for (final x in [x0 + h, x0 + 1 - h])
        for (final y in [h, 1 - h]) project(KeycapPoint(x, y, -housingHeight)),
    ]);
  }

  /// 쇠붙이 그림의 네 모서리(키 한 변 = 1).
  static List<Offset> ringCorners() {
    final hook = project(hookPoint);
    const w = ringWidth, h = ringWidth * ringAspect;
    final c = math.cos(ringAngle), sn = math.sin(ringAngle);
    Offset rot(Offset v) => Offset(v.dx * c - v.dy * sn, v.dx * sn + v.dy * c);
    return [
      for (final v in [
        Offset(-ringHookX * w, -h / 2),
        Offset((1 - ringHookX) * w, -h / 2),
        Offset(-ringHookX * w, h / 2),
        Offset((1 - ringHookX) * w, h / 2),
      ])
        hook + rot(v),
    ];
  }

  /// 키링 전체(키 네 개, [ring]이면 쇠붙이까지)를 감싸는 사각형(키 한 변 = 1).
  static Rect bounds(int keys, {bool ring = true}) =>
      _bounds[(keys, ring)] ??= _measure(keys, ring);

  /// 투영값이 바뀌지 않으니 한 번 잰 값을 쓴다. 화면을 다시 그릴 때마다 재지 않게.
  static final _bounds = <(int, bool), Rect>{};

  static Rect _measure(int keys, bool ring) {
    final pts = <Offset>[
      for (var i = 0; i < keys; i++) ...[
        ...silhouette(i, -0.3),
        ...silhouette(i, 1),
      ],
      if (ring) ...ringCorners(),
    ];
    var r = Rect.fromPoints(pts.first, pts.first);
    for (final p in pts) {
      r = r.expandToInclude(Rect.fromPoints(p, p));
    }
    return r.inflate(0.06);
  }

  static List<Offset> _hull(List<Offset> pts) {
    final p = [...pts]
      ..sort(
        (a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy),
      );
    double cross(Offset o, Offset a, Offset b) =>
        (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
    final lower = <Offset>[], upper = <Offset>[];
    for (final q in p) {
      while (lower.length >= 2 &&
          cross(lower[lower.length - 2], lower.last, q) <= 0) {
        lower.removeLast();
      }
      lower.add(q);
    }
    for (final q in p.reversed) {
      while (upper.length >= 2 &&
          cross(upper[upper.length - 2], upper.last, q) <= 0) {
        upper.removeLast();
      }
      upper.add(q);
    }
    return [...lower..removeLast(), ...upper..removeLast()];
  }

  static bool contains(List<Offset> poly, Offset p) {
    var sign = 0;
    for (var k = 0; k < poly.length; k++) {
      final a = poly[k], b = poly[(k + 1) % poly.length];
      final c = (b.dx - a.dx) * (p.dy - a.dy) - (b.dy - a.dy) * (p.dx - a.dx);
      if (c == 0) continue;
      final s = c > 0 ? 1 : -1;
      if (sign == 0) {
        sign = s;
      } else if (s != sign) {
        return false;
      }
    }
    return true;
  }
}

/// 키링 한 줄을 그린다 — 바닥 그림자, 투명 스위치, 축, 키캡 몸통.
/// 윗면 그림·글자는 위젯으로 따로 얹는다([KeycapBoard]).
///
/// [keys]만 그린다(null 이면 전부). 키마다 따로 그리면 누른 키 하나만 다시
/// 그려진다 — 앞 키가 뒤 키를 가리니 뒤 키부터 겹쳐 쌓는다. 바닥 그림자는
/// [shadow]일 때만.
class KeycapRowPainter extends CustomPainter {
  KeycapRowPainter({
    required this.presses,
    required this.colors,
    required this.s,
    required this.origin,
    this.keys,
    this.shadow = true,
  }) : super(
         repaint: Listenable.merge([
           for (var i = 0; i < presses.length; i++)
             if (keys == null || keys.contains(i)) presses[i],
         ]),
       );

  final List<Animation<double>> presses;
  final KeycapColors colors;
  final List<int>? keys;
  final bool shadow;

  /// 키 한 변(dp).
  final double s;

  /// 3차원 원점이 오는 화면 자리.
  final Offset origin;

  Offset _pt(KeycapPoint p) => origin + KeycapScene.project(p) * s;

  Path _poly(Iterable<KeycapPoint> pts) =>
      Path()..addPolygon([for (final p in pts) _pt(p)], true);

  static Color _shade(Color c, double k) => Color.from(
    alpha: c.a,
    red: (c.r * k).clamp(0, 1),
    green: (c.g * k).clamp(0, 1),
    blue: (c.b * k).clamp(0, 1),
  );

  double _light(KeycapPoint n) =>
      0.72 + 0.32 * math.max(0, n.unit.dot(KeycapScene.light));

  @override
  void paint(Canvas canvas, Size size) {
    final n = presses.length;
    if (shadow) _paintShadow(canvas, n);
    // 뒤(오른쪽)부터 앞(왼쪽)으로.
    for (var i = n - 1; i >= 0; i--) {
      if (keys != null && !keys!.contains(i)) continue;
      final press = presses[i].value;
      _paintHousing(canvas, i);
      _paintStem(canvas, i, press);
      _paintCap(canvas, i, press);
    }
  }

  void _paintShadow(Canvas canvas, int n) {
    const z = -KeycapScene.housingHeight;
    final x1 = (n - 1) * KeycapScene.pitch + 1;
    canvas.drawPath(
      _poly([
        const KeycapPoint(0, 0, z),
        KeycapPoint(x1, 0, z),
        KeycapPoint(x1, 1, z),
        const KeycapPoint(0, 1, z),
      ]).shift(Offset(s * 0.04, s * 0.08)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.13)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.09),
    );
  }

  /// 상자의 보이는 세 면(앞·왼쪽·위).
  List<(List<KeycapPoint>, KeycapPoint)> _box(
    double x0,
    double y0,
    double z0,
    double x1,
    double y1,
    double z1,
  ) => [
    (
      [
        KeycapPoint(x0, y0, z0),
        KeycapPoint(x1, y0, z0),
        KeycapPoint(x1, y0, z1),
        KeycapPoint(x0, y0, z1),
      ],
      const KeycapPoint(0, -1, 0),
    ),
    (
      [
        KeycapPoint(x0, y0, z0),
        KeycapPoint(x0, y1, z0),
        KeycapPoint(x0, y1, z1),
        KeycapPoint(x0, y0, z1),
      ],
      const KeycapPoint(-1, 0, 0),
    ),
    (
      [
        KeycapPoint(x0, y0, z1),
        KeycapPoint(x1, y0, z1),
        KeycapPoint(x1, y1, z1),
        KeycapPoint(x0, y1, z1),
      ],
      const KeycapPoint(0, 0, 1),
    ),
  ];

  /// 투명 아크릴 스위치 — 옅게 비치는 면, 밝은 모서리, 안쪽 몸통.
  void _paintHousing(Canvas canvas, int i) {
    const h = KeycapScene.housingInset;
    const z0 = -KeycapScene.housingHeight;
    final x0 = i * KeycapScene.pitch;
    final alphas = [0.42, 0.30, 0.55];

    final outer = _box(x0 + h, h, z0, x0 + 1 - h, 1 - h, 0);
    final inner = _box(x0 + 0.16, 0.16, z0 + 0.07, x0 + 0.84, 0.84, -0.06);
    for (var f = 0; f < 3; f++) {
      final (pts, normal) = inner[f];
      final path = _poly(pts);
      canvas.drawPath(
        path,
        Paint()
          ..color = _shade(
            const Color(0xFFE9E6E1),
            _light(normal),
          ).withValues(alpha: 0.35),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = Colors.white.withValues(alpha: 0.7),
      );
    }
    for (var f = 0; f < 3; f++) {
      final (pts, normal) = outer[f];
      final path = _poly(pts);
      canvas.drawPath(
        path,
        Paint()
          ..color = _shade(
            const Color(0xFFF4F2EF),
            _light(normal),
          ).withValues(alpha: alphas[f]),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFF9E978C).withValues(alpha: 0.35),
      );
    }
    // 앞 모서리의 빛.
    canvas.drawLine(
      _pt(KeycapPoint(x0 + h, h, 0)),
      _pt(KeycapPoint(x0 + h, h, z0)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = 1,
    );
  }

  /// 축 — 키캡과 스위치 사이 틈으로 보인다.
  void _paintStem(Canvas canvas, int i, double press) {
    final x0 = i * KeycapScene.pitch;
    final top = KeycapScene.capBottom(press) + 0.02;
    if (top <= 0) return;
    for (final (pts, normal) in _box(
      x0 + 0.33,
      0.33,
      0,
      x0 + 0.67,
      0.67,
      top,
    )) {
      canvas.drawPath(
        _poly(pts),
        Paint()..color = _shade(const Color(0xFFE2DCD2), _light(normal)),
      );
    }
  }

  void _paintCap(Canvas canvas, int i, double press) {
    final bottom = KeycapScene.capBottomOutline(i, press);
    final top = KeycapScene.capTopOutline(i, press);
    final center = KeycapPoint(
      i * KeycapScene.pitch + 0.5,
      0.5,
      KeycapScene.capBottom(press) + KeycapScene.capHeight / 2,
    );
    final base = colors.top;

    // 옆면 — 둘레를 잘게 나눠 면마다 빛을 받는 만큼 칠한다. 아래로 갈수록
    // 조금 더 어둡게(바닥 가까이 빛이 덜 든다).
    const bands = [0.0, 0.4, 0.75, 1.0];
    const ao = [0.88, 0.95, 1.0];
    final m = bottom.length;
    for (var j = 0; j < m; j++) {
      final k = (j + 1) % m;
      var normal = (bottom[k] - bottom[j]).cross(top[j] - bottom[j]);
      final mid = KeycapPoint.lerp(bottom[j], top[k], 0.5);
      if (normal.dot(mid - center) < 0) normal = normal.scale(-1);
      if (normal.dot(KeycapScene.view) <= 0) continue;
      final light = _light(normal);
      for (var b = 0; b < 3; b++) {
        final lo0 = KeycapPoint.lerp(bottom[j], top[j], bands[b]);
        final lo1 = KeycapPoint.lerp(bottom[k], top[k], bands[b]);
        final hi1 = KeycapPoint.lerp(bottom[k], top[k], bands[b + 1]);
        final hi0 = KeycapPoint.lerp(bottom[j], top[j], bands[b + 1]);
        final color = _shade(base, light * ao[b] * 0.97);
        final path = _poly([lo0, lo1, hi1, hi0]);
        canvas
          ..drawPath(path, Paint()..color = color)
          // 이웃 조각 사이 틈이 보이지 않게 같은 색으로 한 번 더.
          ..drawPath(
            path,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.7,
          );
      }
    }

    // 윗면 — 가운데가 오목해 뒤쪽이 조금 밝다.
    final topPath = _poly(top);
    final light = _light(const KeycapPoint(0, 0, 1));
    final back = _pt(KeycapPoint(center.x, 1, top.first.z));
    final front = _pt(KeycapPoint(center.x, 0, top.first.z));
    canvas.drawPath(
      topPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            _shade(base, light * 1.04),
            _shade(base, light),
            _shade(base, light * 0.95),
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromPoints(back, front)),
    );
    canvas.drawPath(
      topPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.75),
    );

    // 외곽선 — 밝은 바탕에서 흰 키캡이 묻히지 않게.
    canvas.drawPath(
      Path()..addPolygon([
        for (final p in KeycapScene._hull([
          for (final q in bottom) KeycapScene.project(q),
          for (final q in top) KeycapScene.project(q),
        ]))
          origin + p * s,
      ], true),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = _shade(colors.wallBottom, 0.8).withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(KeycapRowPainter old) =>
      old.colors != colors ||
      old.s != s ||
      old.origin != origin ||
      old.shadow != shadow ||
      !listEquals(old.keys, keys) ||
      !listEquals(old.presses, presses);
}

/// 키 하나가 눌리고 올라오는 움직임.
///
/// 손가락이 닿는 순간 내려가며 [onPress], 다 떼면 튕겨 올라오며 [onRelease].
/// 탭 판정을 기다리지 않아야 눌리는 맛이 난다. 아주 짧게 톡 쳐도 바닥까지
/// 내려갔다 올라온다.
class _KeyMotion {
  _KeyMotion(
    TickerProvider vsync, {
    required this.onPress,
    required this.onRelease,
  }) : press = AnimationController.unbounded(vsync: vsync);

  /// 바닥까지 내려가는 시간. 짧고 단단하게.
  static const _down = Duration(milliseconds: 28);

  /// 떼는 소리는 누른 소리보다 이만큼은 늦게 — 너무 빨리 치면 두 소리가 뭉친다.
  static const _minHold = Duration(milliseconds: 55);

  /// 올라오는 스프링. 감쇠비 0.55 — 끝에서 살짝 튀어 오른다.
  static final _spring = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 1100,
    ratio: 0.55,
  );

  final AnimationController press;
  final VoidCallback onPress;
  final VoidCallback onRelease;

  /// 이 키를 누르고 있는 손가락들. 다 떼야 올라온다.
  final _pointers = <int>{};
  Timer? _holding;
  var _bottoming = false;
  var _releaseQueued = false;
  var _disposed = false;

  void down(int pointer) {
    final first = _pointers.isEmpty;
    _pointers.add(pointer);
    if (!first) return;
    _releaseQueued = false;
    _holding?.cancel();
    _holding = Timer(_minHold, _tryRelease);
    onPress();
    HapticFeedback.lightImpact();
    _bottoming = true;
    press.animateTo(1, duration: _down, curve: Curves.easeOutQuad).whenComplete(
      () {
        _bottoming = false;
        _tryRelease();
      },
    );
  }

  void up(int pointer) {
    if (!_pointers.remove(pointer) || _pointers.isNotEmpty) return;
    _releaseQueued = true;
    _tryRelease();
  }

  /// 바닥에 닿았고 [_minHold]가 지났으면 올린다. 아니면 그때까지 미룬다.
  void _tryRelease() {
    if (_disposed ||
        !_releaseQueued ||
        _pointers.isNotEmpty ||
        _bottoming ||
        (_holding?.isActive ?? false)) {
      return;
    }
    _releaseQueued = false;
    onRelease();
    press.animateWith(SpringSimulation(_spring, press.value, 0, 0));
  }

  void dispose() {
    _disposed = true;
    _holding?.cancel();
    press.dispose();
  }
}

/// 키링 한 줄 — 비스듬히 놓인 키캡 네 개와 쇠붙이. 주어진 [size] 안에 맞춘다.
///
/// 키가 서로 겹쳐 보여서 키마다 네모 버튼을 두지 않는다. 손가락이 닿은 점이
/// 어느 키 윤곽([KeycapScene.silhouette]) 안인지 앞 키부터 따져 고른다.
class KeycapBoard extends StatefulWidget {
  const KeycapBoard({
    super.key,
    required this.ring,
    required this.size,
    required this.onPress,
    required this.onRelease,
  });

  final KeycapRing ring;
  final Size size;
  final VoidCallback onPress;
  final VoidCallback onRelease;

  static const hardwareAsset = 'assets/keycap/keyring.webp';

  /// 키 [i]의 윗면 자리에 놓이는 위젯 키. 테스트가 누를 자리를 찾는 데 쓴다.
  static ValueKey<String> keyFor(int i) => ValueKey('keycap-$i');

  @override
  State<KeycapBoard> createState() => _KeycapBoardState();
}

class _KeycapBoardState extends State<KeycapBoard>
    with TickerProviderStateMixin {
  late final List<_KeyMotion> _keys = [
    for (var i = 0; i < 4; i++)
      _KeyMotion(
        this,
        onPress: () => widget.onPress(),
        onRelease: () => widget.onRelease(),
      ),
  ];

  /// 화면에 닿아 있는 손가락마다 누르고 있는 키(키 사이 빈 곳이면 null)와
  /// 방금 떠난 키.
  final _fingers = <int, ({int? key, int? left})>{};

  late double _s;
  late Offset _origin;

  @override
  void dispose() {
    for (final k in _keys) {
      k.dispose();
    }
    super.dispose();
  }

  /// 가로는 쇠붙이까지 넣어 맞추고, 세로는 키캡만 가운데에 둔다. 아래로
  /// 늘어진 쇠붙이는 칸 밖으로 나가도 된다 — 그래야 키캡이 위로 쏠리지 않는다.
  void _layout() {
    final all = KeycapScene.bounds(_keys.length);
    final keys = KeycapScene.bounds(_keys.length, ring: false);
    _s = math.min(
      widget.size.width / all.width,
      widget.size.height / keys.height,
    );
    _origin = Offset(
      (widget.size.width - all.width * _s) / 2 - all.left * _s,
      (widget.size.height - keys.height * _s) / 2 - keys.top * _s,
    );
  }

  /// 방금 떠난 키는 윤곽을 이만큼 줄여 따진다. 키 경계에서 손가락이 조금
  /// 떨려도 두 키가 번갈아 「따닥따닥」 눌리지 않게.
  static const _reentry = 0.72;

  /// 손가락 아래 키. 누르고 있는 [current] 안이면 그대로(뒤 키 윤곽과
  /// 겹쳐도 옮겨 가지 않는다), 아니면 앞 키부터 따진다.
  int? _hit(Offset local, {int? current, int? left}) {
    final p = (local - _origin) / _s;
    bool inside(int i, {double scale = 1}) {
      final poly = KeycapScene.silhouette(i, _keys[i].press.value);
      if (scale == 1) return KeycapScene.contains(poly, p);
      final c = poly.reduce((a, b) => a + b) / poly.length.toDouble();
      return KeycapScene.contains([
        for (final q in poly) c + (q - c) * scale,
      ], p);
    }

    if (current != null && inside(current)) return current;
    for (var i = 0; i < _keys.length; i++) {
      if (inside(i, scale: i == left ? _reentry : 1)) return i;
    }
    return null;
  }

  void _down(PointerDownEvent e) {
    final i = _hit(e.localPosition);
    _fingers[e.pointer] = (key: i, left: null);
    if (i != null) _keys[i].down(e.pointer);
  }

  /// 손가락으로 쓸면 지나가는 키가 차례로 눌렸다 올라온다 — 따다다닥.
  void _move(PointerMoveEvent e) {
    final f = _fingers[e.pointer];
    if (f == null) return;
    final i = _hit(e.localPosition, current: f.key, left: f.left);
    if (i == f.key) return;
    final from = f.key;
    if (from != null) _keys[from].up(e.pointer);
    if (i != null) _keys[i].down(e.pointer);
    _fingers[e.pointer] = (key: i, left: from ?? f.left);
  }

  void _up(PointerEvent e) {
    final i = _fingers.remove(e.pointer)?.key;
    if (i != null) _keys[i].up(e.pointer);
  }

  @override
  Widget build(BuildContext context) {
    _layout();
    final s = _s;
    final ring = widget.ring;
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2;
    final hook = _origin + KeycapScene.project(KeycapScene.hookPoint) * s;
    final ringW = KeycapScene.ringWidth * s;
    final ringH = ringW * KeycapScene.ringAspect;
    final presses = [for (final k in _keys) k.press];

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _down,
      onPointerMove: _move,
      onPointerUp: _up,
      onPointerCancel: _up,
      child: SizedBox.fromSize(
        size: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 쇠붙이 — 스위치 뒤로 걸려 들어간다.
            Positioned(
              left: hook.dx - KeycapScene.ringHookX * ringW,
              top: hook.dy - ringH / 2,
              width: ringW,
              height: ringH,
              child: Transform.rotate(
                angle: KeycapScene.ringAngle,
                alignment: Alignment(KeycapScene.ringHookX * 2 - 1, 0),
                child: Image.asset(
                  KeycapBoard.hardwareAsset,
                  fit: BoxFit.fill,
                  cacheWidth: (ringW * dpr).round(),
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
            // 바닥 그림자 — 한 번 그리고 다시 그리지 않는다.
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: KeycapRowPainter(
                    presses: presses,
                    colors: ring.colors,
                    s: s,
                    origin: _origin,
                    keys: const [],
                  ),
                ),
              ),
            ),
            // 키마다 한 층. 누른 키 층만 다시 그린다.
            for (var i = _keys.length - 1; i >= 0; i--)
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: KeycapRowPainter(
                      presses: presses,
                      colors: ring.colors,
                      s: s,
                      origin: _origin,
                      keys: [i],
                      shadow: false,
                    ),
                  ),
                ),
              ),
            for (var i = 0; i < _keys.length; i++) ...[
              // 윗면 그림·글자. 뒤 키부터 — 앞 키가 뒤 키 윗면을 가리는 일은 없다.
              AnimatedBuilder(
                animation: _keys[i].press,
                builder: (context, child) => Positioned(
                  left: 0,
                  top: 0,
                  child: Transform(
                    transform: KeycapScene.topFace(
                      i,
                      _keys[i].press.value,
                      s,
                      _origin,
                    ),
                    child: child,
                  ),
                ),
                child: IgnorePointer(
                  child: SizedBox(
                    width: KeycapScene.topWidth * s,
                    height: KeycapScene.topDepth * s,
                    child: _KeycapPrint(
                      keycap: ring.keys[i],
                      colors: ring.colors,
                      size: s,
                    ),
                  ),
                ),
              ),
              _semantics(i, s),
            ],
          ],
        ),
      ),
    );
  }

  /// 화면 낭독기와 테스트가 찾는 자리 — 윗면 가운데.
  Widget _semantics(int i, double s) {
    final k = widget.ring.keys[i];
    final c =
        _origin +
        KeycapScene.project(
              KeycapPoint(
                i * KeycapScene.pitch + 0.5,
                (KeycapScene.insetFront + 1 - KeycapScene.insetBack) / 2,
                KeycapScene.gap + KeycapScene.capHeight,
              ),
            ) *
            s;
    final r = s * 0.2;
    return Positioned(
      key: KeycapBoard.keyFor(i),
      left: c.dx - r,
      top: c.dy - r,
      width: 2 * r,
      height: 2 * r,
      child: Semantics(
        button: true,
        label: k.big == null ? k.label : '${k.label} ${k.big}',
        onTap: () {
          _keys[i]
            ..down(-1)
            ..up(-1);
        },
        excludeSemantics: true,
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// 윗면에 찍힌 그림과 글자.
class _KeycapPrint extends StatelessWidget {
  const _KeycapPrint({
    required this.keycap,
    required this.colors,
    required this.size,
  });

  final KeycapKey keycap;
  final KeycapColors colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = size;
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2;
    final iconSize = s * 0.58;
    final big = keycap.big;
    final mark = big != null
        ? Text(
            big,
            maxLines: 1,
            style: GoogleFonts.notoSansKr(
              fontSize: s * (big.length > 2 ? 0.26 : 0.32),
              height: 1,
              fontWeight: FontWeight.w900,
              color: keycap.bigColor ?? colors.ink,
              letterSpacing: -0.5,
            ),
          )
        : Image.asset(
            keycap.icon,
            width: iconSize,
            height: iconSize,
            cacheWidth: (iconSize * dpr).round(),
            filterQuality: FilterQuality.medium,
            // 그림이 오기 전에도 키는 눌린다.
            errorBuilder: (_, _, _) => SizedBox.square(dimension: iconSize),
          );
    return Padding(
      padding: EdgeInsets.fromLTRB(s * 0.04, s * 0.05, s * 0.04, s * 0.06),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Center(child: mark)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              keycap.label,
              maxLines: 1,
              style: GoogleFonts.notoSansKr(
                fontSize: s * 0.165,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: colors.ink,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 키링 고르기 — 키링 색을 닮은 작은 키 네 개.
class KeycapRingPicker extends StatelessWidget {
  const KeycapRingPicker({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < kKeycapRings.length; i++)
          Semantics(
            button: true,
            selected: i == selected,
            label: '키링 ${kKeycapRings[i].name}',
            excludeSemantics: true,
            child: InkResponse(
              onTap: () => onSelect(i),
              radius: 22,
              child: SizedBox.square(
                dimension: 44,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: i == selected ? 22 : 16,
                    height: i == selected ? 22 : 16,
                    decoration: BoxDecoration(
                      color: kKeycapRings[i].colors.top,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: i == selected
                            ? fg.withValues(alpha: 0.7)
                            : kKeycapRings[i].colors.wallBottom,
                        width: i == selected ? 1.6 : 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 키캡 하나를 작게 — 놀이 고르는 버튼에 쓴다. 놀이 화면과 같은 그리기로.
class KeycapIcon extends StatelessWidget {
  const KeycapIcon({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final b = KeycapScene.bounds(1, ring: false);
    final s = size / math.max(b.width, b.height);
    final origin =
        Offset((size - b.width * s) / 2, (size - b.height * s) / 2) -
        b.topLeft * s;
    return CustomPaint(
      size: Size.square(size),
      painter: KeycapRowPainter(
        presses: const [kAlwaysDismissedAnimation],
        colors: kKeycapRings.last.colors,
        s: s,
        origin: origin,
      ),
    );
  }
}
