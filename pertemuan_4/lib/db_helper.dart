import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart' show Catatan;

/// Repository akses penyimpanan — singleton menggunakan SharedPreferences.
/// Meniru interface SQLite sebelumnya agar main.dart tidak perlu diubah.
class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  static const _keyCatatan = 'catatan_list';
  static const _keyLastId  = 'catatan_last_id';

  static SharedPreferences? _prefs;

  // ── init() — panggil di main() sebelum runApp() ──────────────
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    final p = _prefs;
    if (p == null) {
      throw StateError('DbHelper belum diinisialisasi. Panggil DbHelper.init() terlebih dahulu.');
    }
    return p;
  }

  // ============================================================
  // CRUD
  // ============================================================

  Future<int> insert(Catatan c) async {
    final list = await getAll();
    
    // Auto-increment ID manual
    final lastId = prefs.getInt(_keyLastId) ?? 0;
    final newId = lastId + 1;
    await prefs.setInt(_keyLastId, newId);

    final baru = Catatan(
      id: newId,
      judul: c.judul,
      isi: c.isi,
      kategori: c.kategori,
      dibuatPada: c.dibuatPada,
    );

    list.add(baru);
    await _saveAll(list);
    return newId;
  }

  Future<List<Catatan>> getAll() async {
    final jsonStr = prefs.getString(_keyCatatan);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      final list = decoded.map((item) {
        return Catatan.fromMap(Map<String, Object?>.from(item as Map));
      }).toList();
      
      // Urutkan berdasarkan dibuatPada DESC (catatan terbaru di atas)
      list.sort((a, b) => b.dibuatPada.compareTo(a.dibuatPada));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<int> update(Catatan c) async {
    if (c.id == null) {
      throw ArgumentError('ID catatan tidak boleh null saat update.');
    }
    final list = await getAll();
    final index = list.indexWhere((item) => item.id == c.id);
    if (index != -1) {
      list[index] = c;
      await _saveAll(list);
      return 1;
    }
    return 0;
  }

  Future<int> delete(int id) async {
    final list = await getAll();
    final initialLength = list.length;
    list.removeWhere((item) => item.id == id);
    if (list.length < initialLength) {
      await _saveAll(list);
      return 1;
    }
    return 0;
  }

  Future<void> _saveAll(List<Catatan> list) async {
    final encoded = list.map((c) => c.toMap()).toList();
    await prefs.setString(_keyCatatan, jsonEncode(encoded));
  }

  Future<void> close() async {
    // Tidak ada koneksi DB yang perlu ditutup untuk SharedPreferences.
  }
}
