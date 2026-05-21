import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pertemuan_3/main.dart';

void main() {
  testWidgets('alur catatan berjalan sesuai checklist', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Belajar Flutter'), findsOneWidget);
    expect(find.text('Belum ada catatan'), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Catatan'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pump();

    expect(find.text('Judul wajib diisi'), findsOneWidget);
    expect(find.text('Isi wajib diisi'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'AB');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pump();

    expect(find.text('Minimal 3 karakter'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Catatan Baru');
    await tester.enterText(
      find.byType(TextFormField).last,
      'Isi catatan baru untuk praktikum mobile.',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan Mahasiswa'), findsOneWidget);
    expect(find.text('Belajar Flutter'), findsOneWidget);
    expect(find.text('Catatan Baru'), findsOneWidget);
    expect(find.text('Catatan "Catatan Baru" ditambahkan'), findsOneWidget);

    await tester.tap(find.text('Catatan Baru'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Catatan'), findsOneWidget);
    expect(find.text('Catatan Baru'), findsOneWidget);
    expect(find.text('Kuliah'), findsOneWidget);
    expect(find.text('Isi catatan baru untuk praktikum mobile.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Kembali ke Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan Mahasiswa'), findsOneWidget);

    await tester.tap(_deleteButtonFor(tester, 'Catatan Baru'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan Baru'), findsNothing);
    expect(find.text('Belajar Flutter'), findsOneWidget);

    await tester.tap(_deleteButtonFor(tester, 'Belajar Flutter'));
    await tester.pumpAndSettle();

    expect(find.text('Belajar Flutter'), findsNothing);
    expect(find.text('Belum ada catatan'), findsOneWidget);
  });
}

Finder _deleteButtonFor(WidgetTester tester, String title) {
  final tile = find.ancestor(
    of: find.text(title),
    matching: find.byType(ListTile),
  );

  return find.descendant(of: tile, matching: find.byIcon(Icons.delete));
}
