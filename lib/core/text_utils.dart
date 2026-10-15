import '../l10n/l10n.dart';

/// 한글이 단어 중간에서 줄바뀌지 않게 한다 (CSS `word-break: keep-all`).
///
/// Flutter 는 한글을 글자 단위로 줄바꿈해서 「망친 / 다.」처럼 끊긴다.
/// 단어 안 글자 사이에 WORD JOINER(U+2060)를 넣어 띄어쓰기에서만 줄이 바뀌게
/// 한다. 화면에는 보이지 않는다. 한 단어가 한 줄보다 길면 넘쳐서 잘린다.
///
/// 한국어일 때만 한다. 띄어쓰기가 없는 언어(일본어 등)에 걸면 문장 전체가
/// 한 덩어리가 되고, 라틴 문자는 원래 단어 단위로 줄바꿈된다.
String keepAll(String text) {
  if (!L.current.localeName.startsWith('ko')) return text;
  return text
      .split(' ')
      .map((word) => word.split('').join('⁠'))
      .join(' ');
}
