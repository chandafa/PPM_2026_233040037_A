import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Catatan {
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;

  Catatan({
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
      routes: {'/tambah': (context) => const TambahCatatanPage()},
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Catatan> _catatan = [
    Catatan(
      judul: 'Belajar Flutter',
      isi: 'Mempelajari Stateful Widget, Form, dan Navigation.',
      kategori: 'Kuliah',
      dibuatPada: DateTime.now(),
    ),
  ];

  String _filterKategori = 'Semua';

  final List<String> _filterOpsi = const [
    'Semua',
    'Kuliah',
    'Tugas',
    'Pribadi',
    'Lainnya',
  ];

  List<Catatan> get _catatanTampil {
    if (_filterKategori == 'Semua') {
      return _catatan;
    }

    return _catatan.where((catatan) {
      return catatan.kategori == _filterKategori;
    }).toList();
  }

  Future<void> _bukaTambahCatatan() async {
    final hasil = await Navigator.pushNamed(context, '/tambah');

    if (hasil is Catatan) {
      setState(() {
        _catatan.add(hasil);
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan "${hasil.judul}" berhasil ditambahkan'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _hapusCatatan(Catatan catatan) {
    setState(() {
      _catatan.remove(catatan);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Catatan "${catatan.judul}" dihapus'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _bukaDetail(Catatan catatan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailCatatanPage(catatan: catatan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catatanTampil = _catatanTampil;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filterKategori,
                icon: const Icon(Icons.filter_list),
                borderRadius: BorderRadius.circular(12),
                items: _filterOpsi.map((kategori) {
                  return DropdownMenuItem<String>(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value == null) return;

                  setState(() {
                    _filterKategori = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),

      body: _catatan.isEmpty
          ? const Center(
              child: Text(
                'Belum ada catatan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : catatanTampil.isEmpty
          ? Center(
              child: Text(
                'Tidak ada catatan kategori $_filterKategori',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: catatanTampil.length,
              itemBuilder: (context, index) {
                final catatan = catatanTampil[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.note_alt_outlined),
                    ),
                    title: Text(
                      catatan.judul,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(catatan.kategori),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      onPressed: () {
                        _hapusCatatan(catatan);
                      },
                    ),
                    onTap: () {
                      _bukaDetail(catatan);
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _bukaTambahCatatan,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TambahCatatanPage extends StatefulWidget {
  const TambahCatatanPage({super.key});

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _formKey = GlobalKey<FormState>();

  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();

  String _kategori = 'Kuliah';

  final List<String> _kategoriOpsi = const [
    'Kuliah',
    'Tugas',
    'Pribadi',
    'Lainnya',
  ];

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final catatanBaru = Catatan(
      judul: _judulCtrl.text.trim(),
      isi: _isiCtrl.text.trim(),
      kategori: _kategori,
      dibuatPada: DateTime.now(),
    );

    Navigator.pop(context, catatanBaru);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Catatan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul wajib diisi';
                }

                if (value.trim().length < 3) {
                  return 'Minimal 3 karakter';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _kategoriOpsi.map((kategori) {
                return DropdownMenuItem<String>(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value == null) return;

                setState(() {
                  _kategori = value;
                });
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _isiCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Isi',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Isi wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailCatatanPage extends StatelessWidget {
  final Catatan catatan;

  const DetailCatatanPage({super.key, required this.catatan});

  String _formatTanggal(DateTime tanggal) {
    return '${tanggal.day}/${tanggal.month}/${tanggal.year} '
        '${tanggal.hour.toString().padLeft(2, '0')}:'
        '${tanggal.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              catatan.judul,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(label: Text(catatan.kategori)),
                Text(
                  _formatTanggal(catatan.dibuatPada),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),

            const Divider(height: 32),

            Text(
              catatan.isi,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali ke Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}
