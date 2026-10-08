import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 폰트는 assets/google_fonts/ 에 넣어 두었다. 내려받지 않는다.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(_fontLicenses);
  runApp(const ProviderScope(child: BucheoApp()));
}

Stream<LicenseEntry> _fontLicenses() async* {
  for (final (family, file) in [
    ('Noto Sans KR', 'OFL_NotoSansKR.txt'),
    ('Gowun Batang', 'OFL_GowunBatang.txt'),
  ]) {
    final text = await rootBundle.loadString('assets/google_fonts/$file');
    yield LicenseEntryWithLineBreaks([family], text);
  }
}
