import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';

class AdminManagementScreen extends ConsumerStatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  ConsumerState<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends ConsumerState<AdminManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _loading = false;
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _accommodations = [];
  List<Map<String, dynamic>> _ads = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    Future.microtask(_refresh);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated || auth.role != 'admin') return;
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final responses = await Future.wait([
        api.client.get('/admin/locations'),
        api.client.get('/admin/accommodations'),
        api.client.get('/admin/ads'),
      ]);
      _locations = _items(responses[0]);
      _accommodations = _items(responses[1]);
      _ads = _items(responses[2]);
    } catch (e) {
      if (mounted) _message('admin_load_failed'.tr(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _items(Response<dynamic> response) {
    final body = Map<String, dynamic>.from(response.data as Map);
    final data = body['data'];
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  Future<void> _delete(String endpoint, String id, String label) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('admin_delete'.tr()),
        content: Text('${'admin_delete_confirm'.tr()} $label'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('cancel'.tr())),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text('admin_delete'.tr())),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await ref.read(apiClientProvider).client.delete('$endpoint/$id');
      _message('admin_saved'.tr());
      await _refresh();
    } catch (_) {
      _message('admin_save_failed'.tr(), error: true);
    }
  }

  void _message(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: error ? Theme.of(context).colorScheme.error : null),
    );
  }

  String _name(Map<String, dynamic> item) {
    final locale = context.locale.languageCode;
    final key = locale == 'ar' ? 'name_ar' : locale == 'en' ? 'name_en' : 'name_ckb';
    return (item[key] ?? item['name_ckb'] ?? item['title_ckb'] ?? item['title_en'] ?? '').toString();
  }

  Future<void> _locationDialog({Map<String, dynamic>? item}) async {
    final nameCkb = TextEditingController(text: item?['name_ckb']?.toString() ?? '');
    final nameAr = TextEditingController(text: item?['name_ar']?.toString() ?? '');
    final nameEn = TextEditingController(text: item?['name_en']?.toString() ?? '');
    final descCkb = TextEditingController(text: item?['description_ckb']?.toString() ?? '');
    final descAr = TextEditingController(text: item?['description_ar']?.toString() ?? '');
    final descEn = TextEditingController(text: item?['description_en']?.toString() ?? '');
    final lat = TextEditingController(text: item?['latitude']?.toString() ?? '');
    final lng = TextEditingController(text: item?['longitude']?.toString() ?? '');
    var category = item?['category']?.toString() ?? 'nature_reserve';
    const categories = ['mountain','cave','lake','river','waterfall','spring','historical','archaeological','nature_reserve','other'];
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(item == null ? 'admin_add_location'.tr() : 'admin_edit_location'.tr()),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    items: categories.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) => setLocal(() => category = v ?? category),
                    decoration: InputDecoration(labelText: 'admin_category'.tr()),
                  ),
                  _field(nameCkb, 'name_ckb'.tr(), required: true),
                  _field(nameAr, 'name_ar'.tr()),
                  _field(nameEn, 'name_en'.tr()),
                  _field(descCkb, 'description_ckb'.tr(), maxLines: 3),
                  _field(descAr, 'description_ar'.tr(), maxLines: 3),
                  _field(descEn, 'description_en'.tr(), maxLines: 3),
                  _field(lat, 'admin_latitude'.tr(), keyboard: TextInputType.number),
                  _field(lng, 'admin_longitude'.tr(), keyboard: TextInputType.number),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
            FilledButton(
              onPressed: () async {
                if (nameCkb.text.trim().isEmpty) return;
                final payload = {
                  'category': category,
                  'name_ckb': nameCkb.text.trim(), 'name_ar': nameAr.text.trim(), 'name_en': nameEn.text.trim(),
                  'description_ckb': descCkb.text.trim(), 'description_ar': descAr.text.trim(), 'description_en': descEn.text.trim(),
                  if (double.tryParse(lat.text) != null && double.tryParse(lng.text) != null) ...{
                    'latitude': double.parse(lat.text),
                    'longitude': double.parse(lng.text),
                  },
                };
                try {
                  final api = ref.read(apiClientProvider).client;
                  if (item == null) {
                    await api.post('/admin/locations', data: payload);
                  } else {
                    await api.patch('/admin/locations/${item['id']}', data: payload);
                  }
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  _message('admin_saved'.tr());
                  await _refresh();
                } catch (_) {
                  _message('admin_save_failed'.tr(), error: true);
                }
              },
              child: Text('admin_save'.tr()),
            ),
          ],
        ),
      ),
    );
    for (final c in [nameCkb,nameAr,nameEn,descCkb,descAr,descEn,lat,lng]) { c.dispose(); }
  }

  Future<void> _accommodationDialog({Map<String, dynamic>? item}) async {
    final c = <String, TextEditingController>{
      'name_ckb': TextEditingController(text: item?['name_ckb']?.toString() ?? ''),
      'name_ar': TextEditingController(text: item?['name_ar']?.toString() ?? ''),
      'name_en': TextEditingController(text: item?['name_en']?.toString() ?? ''),
      'description_ckb': TextEditingController(text: item?['description_ckb']?.toString() ?? ''),
      'description_ar': TextEditingController(text: item?['description_ar']?.toString() ?? ''),
      'description_en': TextEditingController(text: item?['description_en']?.toString() ?? ''),
      'city_ckb': TextEditingController(text: item?['city_ckb']?.toString() ?? ''),
      'city_ar': TextEditingController(text: item?['city_ar']?.toString() ?? ''),
      'city_en': TextEditingController(text: item?['city_en']?.toString() ?? ''),
      'price': TextEditingController(text: item?['price_per_night']?.toString() ?? ''),
      'lat': TextEditingController(text: item?['latitude']?.toString() ?? ''),
      'lng': TextEditingController(text: item?['longitude']?.toString() ?? ''),
    };
    var type = item?['type']?.toString() ?? 'hotel';
    const types = ['hotel','house','cabin','chalet'];
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(item == null ? 'admin_add_accommodation'.tr() : 'admin_edit_accommodation'.tr()),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(children: [
                DropdownButtonFormField<String>(
                  initialValue: type, items: types.map((v) => DropdownMenuItem(value: v, child: Text(v.tr()))).toList(),
                  onChanged: (v) => setLocal(() => type = v ?? type),
                  decoration: InputDecoration(labelText: 'admin_type'.tr()),
                ),
                _field(c['name_ckb']!, 'name_ckb'.tr(), required: true),
                _field(c['name_ar']!, 'name_ar'.tr()), _field(c['name_en']!, 'name_en'.tr()),
                _field(c['description_ckb']!, 'description_ckb'.tr(), maxLines: 3),
                _field(c['description_ar']!, 'description_ar'.tr(), maxLines: 3),
                _field(c['description_en']!, 'description_en'.tr(), maxLines: 3),
                _field(c['city_ckb']!, 'city_ckb'.tr()), _field(c['city_ar']!, 'city_ar'.tr()), _field(c['city_en']!, 'city_en'.tr()),
                _field(c['price']!, 'admin_price'.tr(), keyboard: TextInputType.number),
                _field(c['lat']!, 'admin_latitude'.tr(), keyboard: TextInputType.number),
                _field(c['lng']!, 'admin_longitude'.tr(), keyboard: TextInputType.number),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
            FilledButton(
              onPressed: () async {
                if (c['name_ckb']!.text.trim().isEmpty || (item == null && (double.tryParse(c['lat']!.text) == null || double.tryParse(c['lng']!.text) == null))) return;
                final payload = {
                  'type': type,
                  'name_ckb': c['name_ckb']!.text.trim(), 'name_ar': c['name_ar']!.text.trim(), 'name_en': c['name_en']!.text.trim(),
                  'description_ckb': c['description_ckb']!.text.trim(), 'description_ar': c['description_ar']!.text.trim(), 'description_en': c['description_en']!.text.trim(),
                  'city_ckb': c['city_ckb']!.text.trim(), 'city_ar': c['city_ar']!.text.trim(), 'city_en': c['city_en']!.text.trim(),
                  'price_per_night': double.tryParse(c['price']!.text) ?? 0,
                  if (double.tryParse(c['lat']!.text) != null && double.tryParse(c['lng']!.text) != null) ...{
                    'latitude': double.parse(c['lat']!.text),
                    'longitude': double.parse(c['lng']!.text),
                  },
                };
                try {
                  final api = ref.read(apiClientProvider).client;
                  if (item == null) {
                    await api.post('/admin/accommodations', data: payload);
                  } else {
                    await api.patch('/admin/accommodations/${item['id']}', data: payload);
                  }
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  _message('admin_saved'.tr());
                  await _refresh();
                } catch (_) { _message('admin_save_failed'.tr(), error: true); }
              },
              child: Text('admin_save'.tr()),
            ),
          ],
        ),
      ),
    );
    for (final v in c.values) { v.dispose(); }
  }

  Future<void> _adDialog({Map<String, dynamic>? item}) async {
    final c = <String, TextEditingController>{
      'title_ckb': TextEditingController(text: item?['title_ckb']?.toString() ?? ''),
      'title_ar': TextEditingController(text: item?['title_ar']?.toString() ?? ''),
      'title_en': TextEditingController(text: item?['title_en']?.toString() ?? ''),
      'description_ckb': TextEditingController(text: item?['description_ckb']?.toString() ?? ''),
      'description_ar': TextEditingController(text: item?['description_ar']?.toString() ?? ''),
      'description_en': TextEditingController(text: item?['description_en']?.toString() ?? ''),
      'target_url': TextEditingController(text: item?['target_url']?.toString() ?? ''),
      'price': TextEditingController(text: item?['price_iqd']?.toString() ?? '10000'),
      'starts_at': TextEditingController(text: item?['starts_at']?.toString() ?? DateTime.now().toIso8601String()),
      'ends_at': TextEditingController(text: item?['ends_at']?.toString() ?? DateTime.now().add(const Duration(days: 1)).toIso8601String()),
    };
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'admin_add_ad'.tr() : 'admin_edit_ad'.tr()),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(children: [
              _field(c['title_ckb']!, 'title_ckb'.tr(), required: true),
              _field(c['title_ar']!, 'title_ar'.tr()), _field(c['title_en']!, 'title_en'.tr()),
              _field(c['description_ckb']!, 'description_ckb'.tr(), maxLines: 3),
              _field(c['description_ar']!, 'description_ar'.tr(), maxLines: 3),
              _field(c['description_en']!, 'description_en'.tr(), maxLines: 3),
              _field(c['target_url']!, 'admin_target_url'.tr()),
              _field(c['price']!, 'admin_price'.tr(), keyboard: TextInputType.number),
              _field(c['starts_at']!, 'admin_starts_at'.tr()),
              _field(c['ends_at']!, 'admin_ends_at'.tr()),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
          FilledButton(
            onPressed: () async {
              if (c['title_ckb']!.text.trim().isEmpty) return;
              final payload = {
                'title_ckb': c['title_ckb']!.text.trim(), 'title_ar': c['title_ar']!.text.trim(), 'title_en': c['title_en']!.text.trim(),
                'description_ckb': c['description_ckb']!.text.trim(), 'description_ar': c['description_ar']!.text.trim(), 'description_en': c['description_en']!.text.trim(),
                'target_url': c['target_url']!.text.trim(),
                'price_iqd': double.tryParse(c['price']!.text) ?? 10000,
                'starts_at': c['starts_at']!.text.trim(), 'ends_at': c['ends_at']!.text.trim(),
              };
              try {
                final api = ref.read(apiClientProvider).client;
                if (item == null) {
                  await api.post('/admin/ads', data: payload);
                } else {
                  await api.patch('/admin/ads/${item['id']}', data: payload);
                }
                if (!context.mounted) return;
                Navigator.pop(context);
                _message('admin_saved'.tr());
                await _refresh();
              } catch (_) { _message('admin_save_failed'.tr(), error: true); }
            },
            child: Text('admin_save'.tr()),
          ),
        ],
      ),
    );
    for (final v in c.values) { v.dispose(); }
  }

  Future<void> _uploadAdImage(Map<String, dynamic> ad) async {
    final picked = await FilePicker.platform.pickFiles(withData: true, type: FileType.image);
    if (picked == null || picked.files.single.bytes == null) return;
    try {
      final file = picked.files.single;
      final form = FormData.fromMap({'image': MultipartFile.fromBytes(file.bytes!, filename: file.name)});
      await ref.read(apiClientProvider).client.post('/admin/ads/${ad['id']}/image', data: form);
      _message('admin_uploaded'.tr());
      await _refresh();
    } catch (_) { _message('admin_upload_failed'.tr(), error: true); }
  }

  Widget _field(TextEditingController controller, String label, {bool required = false, int maxLines = 1, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(controller: controller, maxLines: maxLines, keyboardType: keyboard, decoration: InputDecoration(labelText: '$label${required ? ' *' : ''}', border: const OutlineInputBorder())),
    );
  }

  Widget _listCard(Map<String, dynamic> item, {required VoidCallback edit, required VoidCallback remove, VoidCallback? upload, String? subtitle}) {
    return Card(
      child: ListTile(
        title: Text(_name(item).isEmpty ? '—' : _name(item)),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: Wrap(children: [
          if (upload != null) IconButton(onPressed: upload, tooltip: 'admin_upload'.tr(), icon: const Icon(Icons.upload_file_outlined)),
          IconButton(onPressed: edit, tooltip: 'admin_edit'.tr(), icon: const Icon(Icons.edit_outlined)),
          IconButton(onPressed: remove, tooltip: 'admin_delete'.tr(), icon: const Icon(Icons.delete_outline)),
        ]),
      ),
    );
  }

  Widget _locationsTab() => _tabList(
    items: _locations,
    add: () => _locationDialog(),
    card: (x) => _listCard(x, edit: () => _locationDialog(item: x), remove: () => _delete('/admin/locations', x['id'].toString(), _name(x))),
  );

  Widget _accommodationsTab() => _tabList(
    items: _accommodations,
    add: () => _accommodationDialog(),
    card: (x) => _listCard(x, edit: () => _accommodationDialog(item: x), remove: () => _delete('/admin/accommodations', x['id'].toString(), _name(x)), subtitle: '${x['type'] ?? ''} • ${x['price_per_night'] ?? 0} IQD'),
  );

  Widget _adsTab() => _tabList(
    items: _ads,
    add: () => _adDialog(),
    card: (x) => _listCard(x, edit: () => _adDialog(item: x), remove: () => _delete('/admin/ads', x['id'].toString(), _name(x)), upload: () => _uploadAdImage(x), subtitle: '${x['price_iqd'] ?? 10000} IQD'),
  );

  Widget _tabList({required List<Map<String, dynamic>> items, required VoidCallback add, required Widget Function(Map<String,dynamic>) card}) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Align(alignment: AlignmentDirectional.centerEnd, child: FilledButton.icon(onPressed: add, icon: const Icon(Icons.add), label: Text('admin_add'.tr()))),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('admin_empty'.tr()))),
          ...items.map(card),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated || auth.role != 'admin') {
      return Scaffold(appBar: AppBar(title: Text('admin_panel'.tr())), body: Center(child: Text('admin_only'.tr())));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('admin_crud'.tr()),
        actions: [IconButton(onPressed: _loading ? null : _refresh, icon: const Icon(Icons.refresh_rounded))],
        bottom: TabBar(controller: _tabs, tabs: [
          Tab(text: 'admin_places'.tr(), icon: const Icon(Icons.place_outlined)),
          Tab(text: 'admin_accommodations'.tr(), icon: const Icon(Icons.hotel_outlined)),
          Tab(text: 'admin_ads'.tr(), icon: const Icon(Icons.campaign_outlined)),
        ]),
      ),
      body: Stack(children: [
        TabBarView(controller: _tabs, children: [_locationsTab(), _accommodationsTab(), _adsTab()]),
        if (_loading) const Align(alignment: Alignment.topCenter, child: LinearProgressIndicator()),
      ]),
    );
  }
}
