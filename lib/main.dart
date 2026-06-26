import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'web_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FlexNotesApp());
}

const _channel = MethodChannel('com.flexnotes.app/storage');
const _ink = Color(0xFF080808);
const _paper = Color(0xFFF7F4EE);
const _blue = Color(0xFF438BFF);
const _green = Color(0xFF4DD663);
const _gold = Color(0xFFFFC84A);
const _pink = Color(0xFFD95AF3);
const _coral = Color(0xFFFF7F5C);

class FlexNotesApp extends StatefulWidget {
  const FlexNotesApp({super.key});

  @override
  State<FlexNotesApp> createState() => _FlexNotesAppState();
}

class _FlexNotesAppState extends State<FlexNotesApp> {
  final NotesStore store = NotesStore();
  bool ready = false;

  @override
  void initState() {
    super.initState();
    store.load().then((_) => setState(() => ready = true));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flex Notes',
          themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: _theme(false),
          darkTheme: _theme(true),
          home: ready ? Shell(store: store) : const SplashScreen(),
        );
      },
    );
  }

  ThemeData _theme(bool dark) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _blue,
      brightness: dark ? Brightness.dark : Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF101010) : _paper,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -1.1,
        ),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.6),
        titleMedium: TextStyle(fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(height: 1.45),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ink,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: NoiseLinesPainter())),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: Colors.white,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'FLEX NOTES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Private notes. Zero cloud. All yours.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
                ),
                const SizedBox(height: 82),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key, required this.store});

  final NotesStore store;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  String query = '';
  String filter = 'All';

  @override
  void initState() {
    super.initState();
    if (!widget.store.welcomeShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog();
      });
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(26),
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: _blue, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Welcome to Flex Notes',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Every remarkable achievement begins with a single thought.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _blue,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Flex Notes is more than a notebook—it\'s a space for your ideas, plans, goals, memories, and moments of inspiration. Designed with simplicity and elegance in mind, it helps you capture what matters, organize it effortlessly, and find it exactly when you need it.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Whether you\'re brainstorming your next business idea, planning a trip, studying for exams, writing a journal, or simply remembering today\'s tasks, Flex Notes grows alongside your journey.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Take your time exploring. Create your first space, write your first note, and make this place uniquely yours.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Because the best ideas deserve more than being forgotten—they deserve a home.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: const [
                    Icon(Icons.edit_note_rounded, color: _blue, size: 20),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Welcome to Flex Notes. Let\'s start creating something meaningful together. 💙',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      widget.store.setWelcomeShown();
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Let\'s get started',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      NotesHome(
        store: widget.store,
        query: query,
        filter: filter,
        onQuery: _setQuery,
        onFilter: _setFilter,
      ),
      CategoryScreen(store: widget.store),
      FavoritesScreen(store: widget.store),
      SettingsScreen(store: widget.store),
    ];
    return Scaffold(
      extendBody: true,
      body: pages[tab],
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavButton(
                icon: Icons.home_rounded,
                active: tab == 0,
                onTap: () => setState(() => tab = 0),
              ),
              _NavButton(
                icon: Icons.folder_rounded,
                active: tab == 1,
                onTap: () => setState(() => tab = 1),
              ),
              GestureDetector(
                onTap: () => _openEditor(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: _blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
              ),
              _NavButton(
                icon: Icons.favorite_rounded,
                active: tab == 2,
                onTap: () => setState(() => tab = 2),
              ),
              _NavButton(
                icon: Icons.tune_rounded,
                active: tab == 3,
                onTap: () => setState(() => tab = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setQuery(String value) => setState(() => query = value);

  void _setFilter(String value) => setState(() => filter = value);

  Future<void> _openEditor([FlexNote? note]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditor(store: widget.store, note: note),
      ),
    );
  }
}

class NotesHome extends StatelessWidget {
  const NotesHome({
    super.key,
    required this.store,
    required this.query,
    required this.filter,
    required this.onQuery,
    required this.onFilter,
  });

  final NotesStore store;
  final String query;
  final String filter;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onFilter;

  @override
  Widget build(BuildContext context) {
    final notes = store.filteredNotes(query, filter);
    final heroNote = notes.isEmpty ? null : notes.first;
    return AppScaffold(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderMark(store: store),
                const SizedBox(height: 18),
                Text(
                  'Your notes',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(fontSize: 42),
                ),
                const SizedBox(height: 8),
                Text(
                  '${store.activeNotes.length} notes live offline · ${store.categories.length} spaces',
                  style: mutedStyle(context),
                ),
                const SizedBox(height: 22),
                SearchBox(value: query, onChanged: onQuery),
                const SizedBox(height: 16),
                FilterRail(filter: filter, store: store, onFilter: onFilter),
                const SizedBox(height: 24),
                if (heroNote != null)
                  HeroNoteCard(note: heroNote, store: store),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Text(
                      'List Notes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: store.setSort,
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'updated',
                          child: Text('Newest edits'),
                        ),
                        PopupMenuItem(
                          value: 'created',
                          child: Text('Newest notes'),
                        ),
                        PopupMenuItem(value: 'title', child: Text('Title A-Z')),
                      ],
                      child: Row(
                        children: [
                          Text(store.sortLabel, style: mutedStyle(context)),
                          const Icon(Icons.unfold_more_rounded, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          notes.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    title: 'No notes found',
                    subtitle: 'Try another filter or create a fresh thought.',
                  ),
                )
              : SliverList.separated(
                  itemCount: notes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      NoteTile(note: notes[index], store: store),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 116)),
        ],
      ),
    );
  }
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, required this.store});

  final NotesStore store;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitle(
                  title: 'Categories',
                  action: IconButton.filled(
                    onPressed: () => showCategorySheet(context, store),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.92,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: store.categories.length,
            itemBuilder: (context, index) {
              final category = store.categories[index];
              final color = Color(category.color);
              final count = store.activeNotes
                  .where((note) => note.categoryId == category.id)
                  .length;
              return GestureDetector(
                onLongPress: () => showCategorySheet(context, store, category),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryDetailScreen(store: store, category: category),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: color.withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark
                          ? 0.22
                          : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FolderIcon(color: color, size: 76),
                      const SizedBox(height: 16),
                      Text(
                        category.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text('$count Notes', style: mutedStyle(context)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 116)),
        ],
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.store});

  final NotesStore store;

  @override
  Widget build(BuildContext context) {
    final notes = store.activeNotes.where((note) => note.favorite).toList();
    return AppScaffold(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: PageTitle(title: 'Favorite Notes')),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          notes.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    title: 'Nothing starred yet',
                    subtitle: 'Tap the heart on any note to keep it here.',
                  ),
                )
              : SliverList.separated(
                  itemCount: notes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      NoteTile(note: notes[index], store: store),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 116)),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});

  final NotesStore store;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const PageTitle(title: 'Settings'),
          const SizedBox(height: 24),
          SettingsCard(
            icon: Icons.wifi_off_rounded,
            title: 'Fully offline',
            subtitle:
                'Every note, category, favorite, archive and backup stays on this device.',
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            title: const Text('Dark studio mode'),
            subtitle: const Text('Black controls and low-light paper.'),
            value: store.darkMode,
            onChanged: store.setDarkMode,
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: kIsWeb
                ? () => snack(context, 'Local backup files are not supported on the web. Notes are automatically saved to LocalStorage.')
                : () async {
                    final path = await store.backup();
                    if (context.mounted) {
                      snack(context, 'Backup saved: $path');
                    }
                  },
            icon: const Icon(Icons.file_download_done_rounded),
            label: const Text('Create local backup'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: kIsWeb
                ? () => snack(context, 'Backup restoration is not supported on the web.')
                : () async {
                    final restored = await store.restoreLatestBackup();
                    if (context.mounted) {
                      snack(
                        context,
                        restored ? 'Latest backup restored' : 'No local backup found',
                      );
                    }
                  },
            icon: const Icon(Icons.restore_rounded),
            label: const Text('Restore latest backup'),
          ),
          SettingsCard(
            icon: Icons.archive_rounded,
            title: 'Archived Notes',
            subtitle: 'View, restore or permanently delete archived thoughts.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ArchivedNotesScreen(store: store),
                ),
              );
            },
          ),
          SettingsCard(
            icon: Icons.delete_outline_rounded,
            title: 'Recycle Bin',
            subtitle: 'View, restore or purge your trashed notes.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecycleBinScreen(store: store),
                ),
              );
            },
          ),
          SettingsCard(
            icon: Icons.bar_chart_rounded,
            title: 'Insights & Statistics',
            subtitle: 'Visualize word count, categories, and writing trends.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NoteStatsScreen(store: store),
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          SettingsCard(
            icon: Icons.storage_rounded,
            title: 'Local database',
            subtitle: store.storagePath.isEmpty
                ? 'Preparing storage path…'
                : store.storagePath,
          ),
          SettingsCard(
            icon: Icons.auto_awesome_rounded,
            title: 'Modern offline features',
            subtitle:
                'Search, tags, categories, pinned notes, favorites, archive, markdown helpers and JSON backups.',
          ),
          const SizedBox(height: 116),
        ],
      ),
    );
  }
}

class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key, required this.store, this.note, this.categoryId});

  final NotesStore store;
  final FlexNote? note;
  final String? categoryId;

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late final TextEditingController title;
  late final TextEditingController body;
  late final TextEditingController tags;
  late String categoryId;
  late int color;
  int? color2;
  String? colorType;
  late bool favorite;
  late bool pinned;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    title = TextEditingController(text: note?.title ?? '');
    body = TextEditingController(text: note?.body ?? '');
    tags = TextEditingController(text: note?.tags.join(', ') ?? '');
    categoryId = note?.categoryId ??
        widget.categoryId ??
        (widget.store.categories.isNotEmpty ? widget.store.categories.first.id : '');
    color = note?.color ?? _pastelColors.first;
    color2 = note?.color2;
    colorType = note?.colorType ?? 'solid';
    favorite = note?.favorite ?? false;
    pinned = note?.pinned ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.store.categoryById(categoryId);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton.outlined(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const Spacer(),
                  Text(
                    widget.note == null ? 'New Note' : 'Edit Note',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton.filled(
                    onPressed: saving ? null : _save,
                    icon: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView(
                  children: [
                    TextField(
                      controller: title,
                      textCapitalization: TextCapitalization.sentences,
                      style: Theme.of(context).textTheme.titleLarge,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'A sharp title…',
                      ),
                    ),
                    Row(
                      children: [
                        if (widget.store.categories.isNotEmpty)
                          DropdownButton<String>(
                            value: widget.store.categories.any((c) => c.id == categoryId)
                                ? categoryId
                                : widget.store.categories.first.id,
                            underline: const SizedBox.shrink(),
                            items: widget.store.categories
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat.id,
                                    child: Text(cat.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => categoryId = value);
                              }
                            },
                          ),
                        const SizedBox(width: 8),
                        Container(
                          width: 5,
                          height: 18,
                          color: category == null
                              ? _blue
                              : Color(category.color),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: tags,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'tags, separated, by comma',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    TextField(
                      controller: body,
                      minLines: 13,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Write anything. It never leaves this phone.',
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ToolButton(
                        icon: Icons.format_bold_rounded,
                        onTap: () => insertWrap('**', '**'),
                      ),
                      ToolButton(
                        icon: Icons.format_italic_rounded,
                        onTap: () => insertWrap('_', '_'),
                      ),
                      ToolButton(
                        icon: Icons.format_list_bulleted_rounded,
                        onTap: () => insertPrefix('- '),
                      ),
                      ToolButton(
                        icon: Icons.check_box_outlined,
                        onTap: () => insertPrefix('- [ ] '),
                      ),
                      ToolButton(
                        icon: favorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        active: favorite,
                        onTap: () => setState(() => favorite = !favorite),
                      ),
                      ToolButton(
                        icon: pinned ? Icons.push_pin : Icons.push_pin_outlined,
                        active: pinned,
                        onTap: () => setState(() => pinned = !pinned),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            showDragHandle: true,
                            builder: (context) => NoteColorPickerSheet(
                              initialColor: color,
                              initialColor2: color2,
                              initialColorType: colorType,
                              onChanged: (newColor, newColor2, newColorType) {
                                setState(() {
                                  color = newColor;
                                  color2 = newColor2;
                                  colorType = newColorType;
                                });
                              },
                            ),
                          );
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: colorType == 'gradient' && color2 != null
                                ? LinearGradient(
                                    colors: [Color(color), Color(color2!)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: colorType == 'gradient' && color2 != null ? null : Color(color),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black26,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 3,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => saving = true);
    final now = DateTime.now();
    final cleanTitle = title.text.trim().isEmpty
        ? 'Untitled note'
        : title.text.trim();
    final note = FlexNote(
      id: widget.note?.id ?? id(),
      title: cleanTitle,
      body: body.text.trim(),
      categoryId: categoryId,
      tags: tags.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList(),
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
      favorite: favorite,
      pinned: pinned,
      archived: widget.note?.archived ?? false,
      color: color,
      color2: color2,
      colorType: colorType,
    );
    await widget.store.upsertNote(note);
    if (mounted) Navigator.pop(context);
  }

  void insertWrap(String before, String after) {
    final selection = body.selection;
    final text = body.text;
    if (!selection.isValid) {
      body.text = '$text$before$after';
      return;
    }
    final selected = text.substring(selection.start, selection.end);
    final next = text.replaceRange(
      selection.start,
      selection.end,
      '$before$selected$after',
    );
    body.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(
        offset: selection.end + before.length + after.length,
      ),
    );
  }

  void insertPrefix(String prefix) {
    final selection = body.selection;
    final offset = selection.isValid ? selection.start : body.text.length;
    final lineStart = body.text.lastIndexOf('\n', max(0, offset - 1)) + 1;
    body.value = TextEditingValue(
      text: body.text.replaceRange(lineStart, lineStart, prefix),
      selection: TextSelection.collapsed(offset: offset + prefix.length),
    );
  }
}

class NoteTile extends StatelessWidget {
  const NoteTile({super.key, required this.note, required this.store});

  final FlexNote note;
  final NotesStore store;

  @override
  Widget build(BuildContext context) {
    final category = store.categoryById(note.categoryId);
    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 22),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: _coral,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.archive_rounded, color: Colors.white),
      ),
      confirmDismiss: (direction) async => true,
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          store.trashNote(note.id);
          snack(context, 'Note moved to Recycle Bin');
        } else {
          store.archive(note.id);
          snack(context, 'Note archived');
        }
      },
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NoteEditor(store: store, note: note),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: note.colorType == 'gradient' && note.color2 != null
                ? LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [
                            Color(note.color).withValues(alpha: 0.38),
                            Color(note.color2!).withValues(alpha: 0.38),
                          ]
                        : [
                            Color(note.color).withValues(alpha: 0.92),
                            Color(note.color2!).withValues(alpha: 0.92),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [
                            Color(note.color).lighten(0.05).withValues(alpha: 0.38),
                            Color(note.color).withValues(alpha: 0.38),
                            Color(note.color).darken(0.05).withValues(alpha: 0.38),
                          ]
                        : [
                            Color(note.color).lighten(0.08).withValues(alpha: 0.92),
                            Color(note.color).withValues(alpha: 0.92),
                            Color(note.color).darken(0.08).withValues(alpha: 0.92),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.05,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: note.pinned
                  ? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : _ink)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08)),
              width: note.pinned ? 1.6 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (note.pinned) const Icon(Icons.push_pin_rounded, size: 16),
                  IconButton(
                    onPressed: () => store.toggleFavorite(note.id),
                    icon: Icon(
                      note.favorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: note.favorite ? _coral : null,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (value) async {
                      if (value == 'copy') {
                        await store.duplicateNote(note);
                        if (context.mounted) {
                          snack(context, 'Note duplicated');
                        }
                      } else if (value == 'move') {
                        final chosenCategoryId = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Move to Space'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: store.categories.map((cat) {
                                return ListTile(
                                  leading: const Icon(Icons.folder_rounded),
                                  title: Text(cat.name),
                                  onTap: () => Navigator.pop(context, cat.id),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                        if (chosenCategoryId != null) {
                          final index = store.notes.indexWhere((item) => item.id == note.id);
                          if (index != -1) {
                            store.notes[index] = store.notes[index].copyWith(
                              categoryId: chosenCategoryId,
                              updatedAt: DateTime.now(),
                            );
                            await store.save();
                            if (context.mounted) {
                              snack(context, 'Note moved successfully');
                            }
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'copy',
                        child: Row(
                          children: [
                            Icon(Icons.copy_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Copy Note'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'move',
                        child: Row(
                          children: [
                            Icon(Icons.drive_file_move_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Move Note'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (note.body.isNotEmpty) ...[
                const SizedBox(height: 6),
                MarkdownPreview(
                  text: note.body,
                  interactiveStore: store,
                  note: note,
                  maxLines: 3,
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (category != null) MiniChip(label: category.name),
                  ...note.tags
                      .where((tag) => category == null || tag.toLowerCase() != category.name.toLowerCase())
                      .take(3)
                      .map((tag) => MiniChip(label: tag)),
                  MiniChip(label: shortDate(note.updatedAt)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeroNoteCard extends StatelessWidget {
  const HeroNoteCard({super.key, required this.note, required this.store});

  final FlexNote note;
  final NotesStore store;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NoteEditor(store: store, note: note),
        ),
      ),
      child: Container(
        height: 190,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: const LinearGradient(
            colors: [Color(0xFF1D1D1F), Color(0xFF36302A), Color(0xFFD7C6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -36,
              child: CustomPaint(
                size: const Size(130, 130),
                painter: DotHaloPainter(),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                    const Spacer(),
                    Text(
                      shortDate(note.updatedAt),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  note.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  note.body.isEmpty ? 'Tap to keep writing.' : note.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.76)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: SoftGridPainter(
              dark: Theme.of(context).brightness == Brightness.dark,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: child,
          ),
        ),
      ],
    );
  }
}

class HeaderMark extends StatelessWidget {
  const HeaderMark({super.key, required this.store});

  final NotesStore store;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _ink,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.edit_note_rounded,
            color: Colors.white,
            size: 31,
          ),
        ),
        const SizedBox(width: 12),
        Text('Flex Notes', style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        IconButton.outlined(
          onPressed: () => _showFlashNoteDialog(context, store),
          icon: const Icon(Icons.offline_bolt_rounded),
        ),
      ],
    );
  }
}

void _showFlashNoteDialog(BuildContext context, NotesStore store) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Flash Note',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Capture an idea instantly before it fades away.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "What's on your mind?...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white54.withValues(alpha: 0.05) : Colors.black54.withValues(alpha: 0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        final lines = text.split('\n');
                        String title = lines.first;
                        if (title.length > 30) {
                          title = '${title.substring(0, 30)}...';
                        }
                        
                        final note = FlexNote(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          title: title,
                          body: text,
                          categoryId: store.categories.isNotEmpty ? store.categories.first.id : '',
                          tags: ['Flash'],
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          favorite: false,
                          pinned: false,
                          archived: false,
                          color: 0xFFFFA07A,
                          color2: 0xFFFF4500,
                          colorType: 'gradient',
                        );
                        await store.upsertNote(note);
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.flash_on_rounded, size: 16),
                    label: const Text('Save Flash'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class PageTitle extends StatelessWidget {
  const PageTitle({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search titles, text or tags',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.72),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}

class FilterRail extends StatelessWidget {
  const FilterRail({
    super.key,
    required this.filter,
    required this.store,
    required this.onFilter,
  });

  final String filter;
  final NotesStore store;
  final ValueChanged<String> onFilter;

  @override
  Widget build(BuildContext context) {
    final labels = [
      'All',
      'Pinned',
      'Recent',
      ...store.categories.map((category) => category.name),
    ];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final label = labels[index];
          final active = label == filter;
          return ChoiceChip(
            selected: active,
            showCheckmark: false,
            label: Text(label),
            onSelected: (_) => onFilter(label),
            selectedColor: _ink,
            labelStyle: TextStyle(
              color: active ? Colors.white : null,
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide.none,
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: labels.length,
      ),
    );
  }
}

class MiniChip extends StatelessWidget {
  const MiniChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF67615A),
        ),
      ),
    );
  }
}

class ToolButton extends StatelessWidget {
  const ToolButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: active ? _blue : Colors.transparent,
      ),
      color: Colors.white,
      icon: Icon(icon),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 26, color: active ? Colors.white : Colors.white54),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _ink,
              foregroundColor: Colors.white,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: mutedStyle(context)),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.note_alt_outlined, size: 54),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: mutedStyle(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

Future<void> showCategorySheet(
  BuildContext context,
  NotesStore store, [
  NoteCategory? category,
]) async {
  final controller = TextEditingController(text: category?.name ?? '');
  int color =
      category?.color ??
      _categoryColors[store.categories.length % _categoryColors.length];
  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    category == null ? 'New category' : 'Edit category',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  if (category != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Category'),
                            content: const Text('Are you sure you want to delete this category? The notes in it will remain but become uncategorized.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await store.deleteCategory(category.id);
                          if (context.mounted) {
                            Navigator.pop(context); // Close bottom sheet
                          }
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Category name'),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: _categoryColors
                    .map(
                      (value) => GestureDetector(
                        onTap: () => setState(() => color = value),
                        child: CircleAvatar(
                          backgroundColor: Color(value),
                          child: color == value
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;
                  store.upsertCategory(
                    NoteCategory(
                      id: category?.id ?? id(),
                      name: name,
                      color: color,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save category'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class NotesStore extends ChangeNotifier {
  final List<FlexNote> notes = [];
  final List<NoteCategory> categories = [];
  String sort = 'updated';
  bool darkMode = false;
  String storagePath = '';
  bool welcomeShown = false;

  List<FlexNote> get activeNotes {
    final list = notes.where((note) => !note.archived && !note.trashed).toList();
    _sort(list);
    return list;
  }

  List<FlexNote> get trashedNotes {
    final list = notes.where((note) => note.trashed).toList();
    list.sort((a, b) => (b.trashedAt ?? DateTime.now()).compareTo(a.trashedAt ?? DateTime.now()));
    return list;
  }

  Future<void> trashNote(String noteId) async {
    final index = notes.indexWhere((note) => note.id == noteId);
    if (index == -1) return;
    notes[index] = notes[index].copyWith(
      trashed: true,
      trashedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await save();
  }

  Future<void> restoreNote(String noteId) async {
    final index = notes.indexWhere((note) => note.id == noteId);
    if (index == -1) return;
    notes[index] = notes[index].copyWith(
      trashed: false,
      trashedAt: null,
      updatedAt: DateTime.now(),
    );
    await save();
  }

  Future<void> emptyTrash() async {
    notes.removeWhere((note) => note.trashed);
    await save();
  }

  String get sortLabel => switch (sort) {
    'created' => 'Created',
    'title' => 'A-Z',
    _ => 'Recent',
  };

  Future<void> load() async {
    if (kIsWeb) {
      storagePath = 'Web LocalStorage';
      try {
        final dataStr = await WebStorage.load('flex_notes');
        if (dataStr == null) {
          _seed();
          await save();
          return;
        }
        final data = jsonDecode(dataStr) as Map<String, dynamic>;
        categories
          ..clear()
          ..addAll(
            (data['categories'] as List? ?? []).map(
              (item) => NoteCategory.fromJson(item),
            ),
          );
        notes
          ..clear()
          ..addAll(
            (data['notes'] as List? ?? []).map((item) => FlexNote.fromJson(item)),
          );
        sort = data['sort'] as String? ?? 'updated';
        darkMode = data['darkMode'] as bool? ?? false;
        welcomeShown = data['welcomeShown'] as bool? ?? false;
        if (categories.isEmpty) _seedCategories();
        _ensureFlashCategory();
        notifyListeners();
      } catch (_) {
        _seed();
        await save();
      }
      return;
    }

    final base = await _basePath();
    storagePath = '$base/flex_notes.json';
    final file = File(storagePath);
    if (!await file.exists()) {
      _seed();
      await save();
      return;
    }
    try {
      final data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      categories
        ..clear()
        ..addAll(
          (data['categories'] as List? ?? []).map(
            (item) => NoteCategory.fromJson(item),
          ),
        );
      notes
        ..clear()
        ..addAll(
          (data['notes'] as List? ?? []).map((item) => FlexNote.fromJson(item)),
        );
      sort = data['sort'] as String? ?? 'updated';
      darkMode = data['darkMode'] as bool? ?? false;
      welcomeShown = data['welcomeShown'] as bool? ?? false;
      if (categories.isEmpty) _seedCategories();
      _ensureFlashCategory();
      notifyListeners();
    } catch (_) {
      _seed();
      await save();
    }
  }

  Future<void> save() async {
    final dataMap = {
      'version': 1,
      'darkMode': darkMode,
      'sort': sort,
      'welcomeShown': welcomeShown,
      'categories': categories.map((category) => category.toJson()).toList(),
      'notes': notes.map((note) => note.toJson()).toList(),
    };

    if (kIsWeb) {
      storagePath = 'Web LocalStorage';
      await WebStorage.save('flex_notes', const JsonEncoder.withIndent('  ').convert(dataMap));
      notifyListeners();
      return;
    }

    final file = File(
      storagePath.isEmpty
          ? '${await _basePath()}/flex_notes.json'
          : storagePath,
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(dataMap),
    );
    notifyListeners();
  }

  Future<void> setWelcomeShown() async {
    welcomeShown = true;
    await save();
  }

  List<FlexNote> filteredNotes(String query, String filter) {
    final q = query.trim().toLowerCase();
    final list = activeNotes.where((note) {
      final category = categoryById(note.categoryId)?.name ?? '';
      final text = '${note.title} ${note.body} ${note.tags.join(' ')} $category'
          .toLowerCase();
      final filterMatch =
          filter == 'All' ||
          (filter == 'Pinned' && note.pinned) ||
          (filter == 'Recent' &&
              DateTime.now().difference(note.updatedAt).inDays <= 7) ||
          category == filter;
      return filterMatch && (q.isEmpty || text.contains(q));
    }).toList();
    _sort(list);
    return list;
  }

  NoteCategory? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  Future<void> upsertNote(FlexNote note) async {
    final index = notes.indexWhere((item) => item.id == note.id);
    if (index == -1) {
      notes.add(note);
    } else {
      notes[index] = note;
    }
    await save();
  }

  Future<void> upsertCategory(NoteCategory category) async {
    final index = categories.indexWhere((item) => item.id == category.id);
    if (index == -1) {
      categories.add(category);
    } else {
      categories[index] = category;
    }
    await save();
  }

  Future<void> deleteCategory(String categoryId) async {
    categories.removeWhere((cat) => cat.id == categoryId);
    for (var i = 0; i < notes.length; i++) {
      if (notes[i].categoryId == categoryId) {
        notes[i] = notes[i].copyWith(
          categoryId: '',
          updatedAt: DateTime.now(),
        );
      }
    }
    await save();
  }

  Future<void> duplicateNote(FlexNote note) async {
    final dup = FlexNote(
      id: id(),
      title: '${note.title} (Copy)',
      body: note.body,
      categoryId: note.categoryId,
      tags: List.from(note.tags),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      favorite: note.favorite,
      pinned: note.pinned,
      archived: note.archived,
      color: note.color,
      color2: note.color2,
      colorType: note.colorType,
    );
    notes.add(dup);
    await save();
  }

  Future<void> toggleFavorite(String noteId) async {
    final index = notes.indexWhere((note) => note.id == noteId);
    if (index == -1) return;
    notes[index] = notes[index].copyWith(
      favorite: !notes[index].favorite,
      updatedAt: DateTime.now(),
    );
    await save();
  }

  Future<void> archive(String noteId) async {
    final index = notes.indexWhere((note) => note.id == noteId);
    if (index == -1) return;
    notes[index] = notes[index].copyWith(
      archived: true,
      updatedAt: DateTime.now(),
    );
    await save();
  }

  Future<void> unarchive(String noteId) async {
    final index = notes.indexWhere((note) => note.id == noteId);
    if (index == -1) return;
    notes[index] = notes[index].copyWith(
      archived: false,
      updatedAt: DateTime.now(),
    );
    await save();
  }

  Future<void> deleteNote(String noteId) async {
    notes.removeWhere((note) => note.id == noteId);
    await save();
  }

  Future<void> setSort(String value) async {
    sort = value;
    await save();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    await save();
  }

  Future<String> backup() async {
    if (kIsWeb) {
      return 'Web backups not supported';
    }
    final base = await _basePath();
    final backupDir = Directory('$base/backups');
    await backupDir.create(recursive: true);
    final backupPath =
        '${backupDir.path}/flex_notes_${DateTime.now().millisecondsSinceEpoch}.json';
    await File(storagePath).copy(backupPath);
    return backupPath;
  }

  Future<bool> restoreLatestBackup() async {
    if (kIsWeb) {
      return false;
    }
    final base = await _basePath();
    final backupDir = Directory('$base/backups');
    if (!await backupDir.exists()) return false;
    final backups =
        backupDir
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.json'))
            .toList()
          ..sort(
            (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
          );
    if (backups.isEmpty) return false;
    await backups.first.copy(storagePath);
    await load();
    return true;
  }

  void _sort(List<FlexNote> list) {
    list.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return switch (sort) {
        'created' => b.createdAt.compareTo(a.createdAt),
        'title' => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        _ => b.updatedAt.compareTo(a.updatedAt),
      };
    });
  }

  void _seed() {
    _seedCategories();
    _ensureFlashCategory();
    final now = DateTime.now();
    notes
      ..clear()
      ..addAll([
        FlexNote(
          id: id(),
          title: 'Welcome to Flash Note ⚡',
          body: 'This note was automatically created in your Flash folder! Tap the lightning bolt icon in the top header at any time to capture quick thoughts instantly.',
          categoryId: 'flash_category',
          tags: ['Flash'],
          createdAt: now,
          updatedAt: now,
          favorite: true,
          pinned: false,
          archived: false,
          color: 0xFFFFA07A,
          color2: 0xFFFF4500,
          colorType: 'gradient',
        ),
        FlexNote(
          id: id(),
          title: 'How to draw a professional wireframe?',
          body:
              'Start with the screen goal, sketch the core path, then add only the controls that make the next action obvious. Use this as a compact project checklist.',
          categoryId: categories[1].id,
          tags: ['Design', 'Wireframe'],
          createdAt: now.subtract(const Duration(days: 4)),
          updatedAt: now.subtract(const Duration(hours: 2)),
          favorite: true,
          pinned: true,
          archived: false,
          color: 0xFFE9F3FF,
        ),
        FlexNote(
          id: id(),
          title: 'Ways to succeed early',
          body:
              '- [ ] Pick one task\n- [ ] Finish the smallest useful version\n- [ ] Review the result before adding scope',
          categoryId: categories[2].id,
          tags: ['Goals'],
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 1)),
          favorite: false,
          pinned: false,
          archived: false,
          color: 0xFFFFF3D9,
        ),
        FlexNote(
          id: id(),
          title: 'Scientific facts of space',
          body:
              'A quiet place for strange facts, telescope ideas, and things worth reading later.',
          categoryId: categories[3].id,
          tags: ['Scientific', 'Space'],
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
          favorite: false,
          pinned: false,
          archived: false,
          color: 0xFFE2FFE6,
        ),
      ]);
  }

  void _seedCategories() {
    categories
      ..clear()
      ..addAll([
        NoteCategory(id: 'flash_category', name: 'Flash', color: const Color(0xFFFFB300).toARGB32()),
        NoteCategory(id: id(), name: 'Design', color: _blue.toARGB32()),
        NoteCategory(id: id(), name: 'Success', color: _gold.toARGB32()),
        NoteCategory(id: id(), name: 'Scientific', color: _green.toARGB32()),
        NoteCategory(id: id(), name: 'Freelancer', color: _pink.toARGB32()),
      ]);
  }

  void _ensureFlashCategory() {
    final hasFlash = categories.any((c) => c.name.toLowerCase() == 'flash' || c.id == 'flash_category');
    if (!hasFlash) {
      categories.insert(0, NoteCategory(id: 'flash_category', name: 'Flash', color: const Color(0xFFFFB300).toARGB32()));
    }
  }
}

class FlexNote {
  const FlexNote({
    required this.id,
    required this.title,
    required this.body,
    required this.categoryId,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.favorite,
    required this.pinned,
    required this.archived,
    required this.color,
    this.color2,
    this.colorType = 'solid',
    this.trashed = false,
    this.trashedAt,
  });

  final String id;
  final String title;
  final String body;
  final String categoryId;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool favorite;
  final bool pinned;
  final bool archived;
  final int color;
  final int? color2;
  final String? colorType;
  final bool trashed;
  final DateTime? trashedAt;

  factory FlexNote.fromJson(dynamic raw) {
    final json = raw as Map<String, dynamic>;
    return FlexNote(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled note',
      body: json['body'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      tags: (json['tags'] as List? ?? []).map((tag) => tag.toString()).toList(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      favorite: json['favorite'] as bool? ?? false,
      pinned: json['pinned'] as bool? ?? false,
      archived: json['archived'] as bool? ?? false,
      color: (json['color'] as num?)?.toInt() ?? _pastelColors.first,
      color2: (json['color2'] as num?)?.toInt(),
      colorType: json['colorType'] as String? ?? 'solid',
      trashed: json['trashed'] as bool? ?? false,
      trashedAt: json['trashedAt'] != null ? DateTime.tryParse(json['trashedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'categoryId': categoryId,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'favorite': favorite,
    'pinned': pinned,
    'archived': archived,
    'color': color,
    'color2': color2,
    'colorType': colorType,
    'trashed': trashed,
    'trashedAt': trashedAt?.toIso8601String(),
  };

  FlexNote copyWith({
    String? title,
    String? body,
    String? categoryId,
    List<String>? tags,
    bool? favorite,
    bool? pinned,
    bool? archived,
    DateTime? updatedAt,
    int? color,
    int? color2,
    String? colorType,
    bool? trashed,
    DateTime? trashedAt,
  }) {
    return FlexNote(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      favorite: favorite ?? this.favorite,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      color: color ?? this.color,
      color2: color2 ?? this.color2,
      colorType: colorType ?? this.colorType,
      trashed: trashed ?? this.trashed,
      trashedAt: trashedAt ?? this.trashedAt,
    );
  }
}

class NoteCategory {
  const NoteCategory({
    required this.id,
    required this.name,
    required this.color,
  });

  final String id;
  final String name;
  final int color;

  factory NoteCategory.fromJson(dynamic raw) {
    final json = raw as Map<String, dynamic>;
    return NoteCategory(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Notes',
      color: (json['color'] as num?)?.toInt() ?? _blue.toARGB32(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'color': color};
}

class SoftGridPainter extends CustomPainter {
  SoftGridPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = (dark ? Colors.white : Colors.black).withValues(alpha: 0.035);
    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.16),
      size.width * 0.55,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 1.05, size.height * 0.15),
      size.width * 0.72,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant SoftGridPainter oldDelegate) =>
      oldDelegate.dark != dark;
}

class NoiseLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(10);
    final paint = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.055);
    for (var i = 0; i < 140; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawLine(Offset(x, y), Offset(x + 40, y + 90), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DotHaloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.18);
    for (var i = 0; i < 24; i++) {
      final angle = i / 24 * pi * 2;
      final radius = 22 + (i.isEven ? 18 : 4);
      canvas.drawCircle(
        Offset(
          size.width / 2 + cos(angle) * radius,
          size.height / 2 + sin(angle) * radius,
        ),
        3.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

TextStyle mutedStyle(BuildContext context) {
  return TextStyle(
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.58),
    fontWeight: FontWeight.w600,
  );
}

void snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}

String id() =>
    DateTime.now().microsecondsSinceEpoch.toString() +
    Random().nextInt(9999).toString();

String shortDate(DateTime date) =>
    '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

Future<String> _basePath() async {
  if (kIsWeb) return 'web';
  if (Platform.isAndroid) {
    return await _channel.invokeMethod<String>('filesDir') ??
        Directory.systemTemp.path;
  }
  return Directory.current.path;
}

const _pastelColors = [
  0xFF90CAF9, // Sky Blue
  0xFFFFE082, // Warm Gold
  0xFFA5D6A7, // Fresh Green
  0xFFF48FB1, // Rose Pink
  0xFFFFCC80, // Coral Orange
  0xFFB39DDB, // Soft Purple
];
final _categoryColors = [
  _blue.toARGB32(),
  _gold.toARGB32(),
  _green.toARGB32(),
  _pink.toARGB32(),
  _coral.toARGB32(),
];

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({super.key, required this.store, required this.category});

  final NotesStore store;
  final NoteCategory category;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final categoryNotes = widget.store.activeNotes
            .where((note) => note.categoryId == widget.category.id)
            .toList();

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton.outlined(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                widget.category.name,
                                style: Theme.of(context).textTheme.headlineMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton.filled(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => NoteEditor(
                                      store: widget.store,
                                      categoryId: widget.category.id,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '${categoryNotes.length} notes in this space',
                          style: mutedStyle(context),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                categoryNotes.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          title: 'No notes here',
                          subtitle: 'Create a note in this space by tapping the + icon above.',
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList.separated(
                          itemCount: categoryNotes.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              NoteTile(note: categoryNotes[index], store: widget.store),
                        ),
                      ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ArchivedNotesScreen extends StatefulWidget {
  const ArchivedNotesScreen({super.key, required this.store});

  final NotesStore store;

  @override
  State<ArchivedNotesScreen> createState() => _ArchivedNotesScreenState();
}

class _ArchivedNotesScreenState extends State<ArchivedNotesScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final archivedNotes = widget.store.notes
            .where((note) => note.archived && !note.trashed)
            .toList();

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton.outlined(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Archived Notes',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '${archivedNotes.length} archived thoughts',
                          style: mutedStyle(context),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                archivedNotes.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          title: 'No archived notes',
                          subtitle: 'Swipe left on active notes to archive them.',
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList.separated(
                          itemCount: archivedNotes.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final note = archivedNotes[index];
                            return Container(
                              padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  gradient: note.colorType == 'gradient' && note.color2 != null
                                      ? LinearGradient(
                                          colors: Theme.of(context).brightness == Brightness.dark
                                              ? [
                                                  Color(note.color).withValues(alpha: 0.38),
                                                  Color(note.color2!).withValues(alpha: 0.38),
                                                ]
                                              : [
                                                  Color(note.color).withValues(alpha: 0.92),
                                                  Color(note.color2!).withValues(alpha: 0.92),
                                                ],
                                        )
                                      : null,
                                  color: note.colorType == 'gradient' && note.color2 != null
                                      ? null
                                      : (Theme.of(context).brightness == Brightness.dark
                                          ? Color(note.color).withValues(alpha: 0.38)
                                          : Color(note.color).withValues(alpha: 0.92)),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : Colors.black.withValues(alpha: 0.08),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.05,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          note.title,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.unarchive_rounded),
                                        tooltip: 'Restore Note',
                                        onPressed: () async {
                                          await widget.store.unarchive(note.id);
                                          if (context.mounted) {
                                            snack(context, 'Note restored to active notes');
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                                        tooltip: 'Delete Permanently',
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Permanently'),
                                              content: const Text('Are you sure you want to permanently delete this note? This action cannot be undone.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await widget.store.trashNote(note.id);
                                            if (context.mounted) {
                                              snack(context, 'Note moved to Recycle Bin');
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  if (note.body.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      note.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: mutedStyle(context),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FolderIcon extends StatelessWidget {
  const FolderIcon({super.key, required this.color, this.size = 64});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tabWidth = size * 0.45;
    final tabHeight = size * 0.16;
    final borderRadius = size * 0.12;

    return SizedBox(
      width: size * 1.15,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Back flap (tab)
          Positioned(
            left: size * 0.08,
            top: 0,
            child: Container(
              width: tabWidth,
              height: tabHeight * 1.6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius * 0.8),
                  topRight: Radius.circular(borderRadius * 0.8),
                ),
              ),
            ),
          ),
          // 2. Back body base
          Positioned(
            left: size * 0.08,
            top: tabHeight,
            right: size * 0.08,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.80),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
          // 3. Document paper peeking out
          Positioned(
            left: size * 0.13,
            right: size * 0.13,
            top: tabHeight * 0.5,
            height: size * 0.28,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius * 0.4),
                  topRight: Radius.circular(borderRadius * 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 1.5,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
            ),
          ),
          // 4. Front Cover with gradient
          Positioned(
            left: size * 0.08,
            top: tabHeight * 1.15,
            right: size * 0.08,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.95),
                    color,
                    color.darken(0.16),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 3,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MarkdownPreview extends StatelessWidget {
  const MarkdownPreview({
    super.key,
    required this.text,
    this.interactiveStore,
    this.note,
    this.maxLines,
  });

  final String text;
  final NotesStore? interactiveStore;
  final FlexNote? note;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final List<Widget> children = [];

    int charOffset = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      if (maxLines != null && children.length >= maxLines!) {
        break;
      }

      if (line.startsWith('- [ ] ') || line.startsWith('- [x] ')) {
        final isChecked = line.startsWith('- [x] ');
        final content = line.substring(6);
        final lineIndex = i;

        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (interactiveStore != null && note != null) {
                      final updatedLines = List<String>.from(lines);
                      if (isChecked) {
                        updatedLines[lineIndex] = '- [ ] $content';
                      } else {
                        updatedLines[lineIndex] = '- [x] $content';
                      }
                      final newBody = updatedLines.join('\n');
                      interactiveStore!.upsertNote(note!.copyWith(
                        body: newBody,
                        updatedAt: DateTime.now(),
                      ));
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(top: 2, right: 8),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isChecked
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: isChecked
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).brightness == Brightness.dark
                                ? Colors.white54
                                : Colors.black45,
                        width: 1.5,
                      ),
                    ),
                    child: isChecked
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: _parseInlineStyles(
                      content,
                      context,
                      isChecked ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey) : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('# ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: RichText(
              text: _parseInlineStyles(
                line.substring(2),
                context,
                Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: RichText(
              text: _parseInlineStyles(
                line.substring(3),
                context,
                Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: RichText(
              text: _parseInlineStyles(
                line.substring(4),
                context,
                Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 6, right: 10),
                  child: Icon(Icons.circle_rounded, size: 6, color: Colors.grey),
                ),
                Expanded(
                  child: RichText(
                    text: _parseInlineStyles(line.substring(2), context, null),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 8));
      } else {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: RichText(
              text: _parseInlineStyles(line, context, null),
            ),
          ),
        );
      }
      
      charOffset += line.length + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  TextSpan _parseInlineStyles(String text, BuildContext context, TextStyle? baseStyle) {
    final defaultStyle = baseStyle ?? Theme.of(context).textTheme.bodyMedium;
    final List<TextSpan> spans = [];
    
    int index = 0;
    while (index < text.length) {
      if (text.startsWith('**', index)) {
        final end = text.indexOf('**', index + 2);
        if (end != -1) {
          spans.add(TextSpan(
            text: text.substring(index + 2, end),
            style: defaultStyle?.copyWith(fontWeight: FontWeight.bold),
          ));
          index = end + 2;
          continue;
        }
      }
      if (text.startsWith('*', index)) {
        final end = text.indexOf('*', index + 1);
        if (end != -1) {
          spans.add(TextSpan(
            text: text.substring(index + 1, end),
            style: defaultStyle?.copyWith(fontStyle: FontStyle.italic),
          ));
          index = end + 1;
          continue;
        }
      }
      if (text.startsWith('`', index)) {
        final end = text.indexOf('`', index + 1);
        if (end != -1) {
          spans.add(TextSpan(
            text: text.substring(index + 1, end),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: (defaultStyle?.fontSize ?? 14) - 1,
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white12 
                  : Colors.black.withValues(alpha: 0.06),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.amber.shade200
                  : Colors.red.shade800,
            ),
          ));
          index = end + 1;
          continue;
        }
      }
      
      int nextSpecial = text.length;
      for (final marker in ['**', '*', '`']) {
        final pos = text.indexOf(marker, index);
        if (pos != -1 && pos < nextSpecial) {
          nextSpecial = pos;
        }
      }
      
      spans.add(TextSpan(
        text: text.substring(index, nextSpecial),
        style: defaultStyle,
      ));
      index = nextSpecial;
    }

    return TextSpan(children: spans);
  }
}

class CategoryRingChart extends StatelessWidget {
  const CategoryRingChart({
    super.key,
    required this.name,
    required this.count,
    required this.total,
    required this.color,
  });

  final String name;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double percentage = total > 0 ? count / total : 0.0;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 7,
                backgroundColor: color.withValues(alpha: 0.15),
                color: color,
              ),
            ),
            Text(
              '${(percentage * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$count notes',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}

class NoteStatsScreen extends StatelessWidget {
  const NoteStatsScreen({super.key, required this.store});

  final NotesStore store;

  @override
  Widget build(BuildContext context) {
    final totalCount = store.notes.where((n) => !n.trashed).length;

    int totalWords = 0;
    for (final note in store.notes) {
      if (!note.trashed) {
        totalWords += note.body.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
        totalWords += note.title.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      }
    }

    final readTimeMinutes = (totalWords / 200).ceil();

    final categoryCounts = <String, int>{};
    for (final cat in store.categories) {
      categoryCounts[cat.id] = 0;
    }
    for (final note in store.notes) {
      if (!note.trashed && categoryCounts.containsKey(note.categoryId)) {
        categoryCounts[note.categoryId] = categoryCounts[note.categoryId]! + 1;
      }
    }

    int solidCount = 0;
    int gradientCount = 0;
    for (final note in store.notes) {
      if (!note.trashed) {
        if (note.colorType == 'gradient') {
          gradientCount++;
        } else {
          solidCount++;
        }
      }
    }

    final double solidPercent = totalCount > 0 ? solidCount / totalCount : 0.0;
    final double gradientPercent = totalCount > 0 ? gradientCount / totalCount : 0.0;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton.outlined(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Insights & Stats',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.notes_rounded,
                            color: Colors.blue,
                            value: '$totalCount',
                            label: 'Total Notes',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.menu_book_rounded,
                            color: Colors.amber,
                            value: '$totalWords',
                            label: 'Total Words',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.timer_rounded,
                            color: Colors.green,
                            value: '$readTimeMinutes min',
                            label: 'Reading Time',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.folder_open_rounded,
                            color: Colors.purple,
                            value: '${store.categories.length}',
                            label: 'Spaces',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Spaces Distribution',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: store.categories.map((cat) {
                            final count = categoryCounts[cat.id] ?? 0;
                            return Padding(
                              padding: const EdgeInsets.only(right: 22),
                              child: CategoryRingChart(
                                name: cat.name,
                                count: count,
                                total: totalCount,
                                color: Color(cat.color),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Note Styling Styles',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Solid Color Notes', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text('$solidCount (${(solidPercent * 100).round()}%)', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: solidPercent,
                              minHeight: 8,
                              backgroundColor: Colors.grey.withValues(alpha: 0.15),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Gradient Color Notes', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text('$gradientCount (${(gradientPercent * 100).round()}%)', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: gradientPercent,
                              minHeight: 8,
                              backgroundColor: Colors.grey.withValues(alpha: 0.15),
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bolt_rounded, color: Colors.cyan, size: 28),
                              SizedBox(width: 8),
                              Text(
                                'Motivation',
                                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Writing clears the mind. By journaling thoughts or planning projects, you build clear thinking routines. Keep going! ⚡',
                            style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key, required this.store});

  final NotesStore store;

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final trashedNotes = widget.store.trashedNotes;

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton.outlined(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Recycle Bin',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (trashedNotes.isNotEmpty)
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Empty Recycle Bin'),
                                      content: const Text('Are you sure you want to permanently delete all notes in the Recycle Bin? This action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          child: const Text('Empty'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await widget.store.emptyTrash();
                                  }
                                },
                                icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                                label: const Text('Empty'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '${trashedNotes.length} notes in Recycle Bin · auto-saved local storage',
                          style: mutedStyle(context),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                if (trashedNotes.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 64,
                            color: Colors.grey.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Recycle Bin is empty',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Notes you delete will appear here.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: trashedNotes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final note = trashedNotes[index];
                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: note.colorType == 'gradient' && note.color2 != null
                                ? LinearGradient(
                                    colors: Theme.of(context).brightness == Brightness.dark
                                        ? [
                                            Color(note.color).withValues(alpha: 0.38),
                                            Color(note.color2!).withValues(alpha: 0.38),
                                          ]
                                        : [
                                            Color(note.color).withValues(alpha: 0.92),
                                            Color(note.color2!).withValues(alpha: 0.92),
                                          ],
                                  )
                                : null,
                            color: note.colorType == 'gradient' && note.color2 != null
                                ? null
                                : (Theme.of(context).brightness == Brightness.dark
                                    ? Color(note.color).withValues(alpha: 0.38)
                                    : Color(note.color).withValues(alpha: 0.92)),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.08),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.05,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      note.title,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.restore_rounded),
                                    tooltip: 'Restore Note',
                                    onPressed: () async {
                                      await widget.store.restoreNote(note.id);
                                      if (mounted) {
                                        snack(context, 'Note restored to notes list');
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_forever_rounded),
                                    tooltip: 'Delete Permanently',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Permanently'),
                                          content: const Text('Are you sure you want to permanently delete this note? This action cannot be undone.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await widget.store.deleteNote(note.id);
                                        if (mounted) {
                                          snack(context, 'Note deleted permanently');
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                              if (note.body.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  note.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: mutedStyle(context),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

const _presetGradients = [
  [0xFFFFA07A, 0xFFFF4500], // Sunset Orange
  [0xFF90CAF9, 0xFF0D47A1], // Ocean Blue
  [0xFFA5D6A7, 0xFF1B5E20], // Forest Green
  [0xFFE100FF, 0xFF7F00FF], // Lavender Dream
  [0xFF80DEEA, 0xFF006064], // Sky Teal
  [0xFFFF8A80, 0xFFFF1744], // Crimson Red
];

class NoteColorPickerSheet extends StatefulWidget {
  const NoteColorPickerSheet({
    super.key,
    required this.initialColor,
    required this.initialColor2,
    required this.initialColorType,
    required this.onChanged,
  });

  final int initialColor;
  final int? initialColor2;
  final String? initialColorType;
  final void Function(int color, int? color2, String? colorType) onChanged;

  @override
  State<NoteColorPickerSheet> createState() => _NoteColorPickerSheetState();
}

class _NoteColorPickerSheetState extends State<NoteColorPickerSheet> {
  int activeTab = 0; // 0: Preset Solids, 1: Preset Gradients, 2: Custom Solid, 3: Custom Gradient

  late double solidH, solidS, solidV;
  late double gradStartH, gradStartS, gradStartV;
  late double gradEndH, gradEndS, gradEndV;
  int activeGradColorIndex = 0; // 0: Start, 1: End

  @override
  void initState() {
    super.initState();
    if (widget.initialColorType == 'gradient') {
      activeTab = 1;
    } else {
      activeTab = 0;
    }

    final hsvSolid = HSVColor.fromColor(Color(widget.initialColor));
    solidH = hsvSolid.hue;
    solidS = hsvSolid.saturation;
    solidV = hsvSolid.value;

    final hsvStart = HSVColor.fromColor(Color(widget.initialColor));
    gradStartH = hsvStart.hue;
    gradStartS = hsvStart.saturation;
    gradStartV = hsvStart.value;

    final hsvEnd = HSVColor.fromColor(Color(widget.initialColor2 ?? widget.initialColor));
    gradEndH = hsvEnd.hue;
    gradEndS = hsvEnd.saturation;
    gradEndV = hsvEnd.value;
  }

  Widget _buildTabButton(int index, String label) {
    final active = activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => activeTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildHsvSliders({
    required double h,
    required double s,
    required double v,
    required ValueChanged<double> onH,
    required ValueChanged<double> onS,
    required ValueChanged<double> onV,
  }) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 44,
              child: Text('Hue', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            ),
            Expanded(
              child: Slider(
                value: h,
                min: 0.0,
                max: 360.0,
                activeColor: HSVColor.fromAHSV(1.0, h, 1.0, 1.0).toColor(),
                inactiveColor: Colors.grey.withValues(alpha: 0.2),
                onChanged: onH,
              ),
            ),
            Text('${h.round()}°', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Row(
          children: [
            const SizedBox(
              width: 44,
              child: Text('Sat', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            ),
            Expanded(
              child: Slider(
                value: s,
                min: 0.0,
                max: 1.0,
                activeColor: HSVColor.fromAHSV(1.0, h, s, 1.0).toColor(),
                inactiveColor: Colors.grey.withValues(alpha: 0.2),
                onChanged: onS,
              ),
            ),
            Text('${(s * 100).round()}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Row(
          children: [
            const SizedBox(
              width: 44,
              child: Text('Val', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            ),
            Expanded(
              child: Slider(
                value: v,
                min: 0.2,
                max: 1.0,
                activeColor: HSVColor.fromAHSV(1.0, h, 0.5, v).toColor(),
                inactiveColor: Colors.grey.withValues(alpha: 0.2),
                onChanged: onV,
              ),
            ),
            Text('${(v * 100).round()}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final solidColor = HSVColor.fromAHSV(1.0, solidH, solidS, solidV).toColor();
    final gradStartColor = HSVColor.fromAHSV(1.0, gradStartH, gradStartS, gradStartV).toColor();
    final gradEndColor = HSVColor.fromAHSV(1.0, gradEndH, gradEndS, gradEndV).toColor();

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select note color',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabButton(0, 'Presets'),
                const SizedBox(width: 8),
                _buildTabButton(1, 'Gradients'),
                const SizedBox(width: 8),
                _buildTabButton(2, 'Custom Color'),
                const SizedBox(width: 8),
                _buildTabButton(3, 'Custom Gradient'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (activeTab == 0) ...[
            // Preset Solids
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _pastelColors.map((value) {
                final active = widget.initialColorType != 'gradient' && widget.initialColor == value;
                return GestureDetector(
                  onTap: () {
                    widget.onChanged(value, null, 'solid');
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Color(value),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: active
                            ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.white30 : Colors.black12),
                        width: active ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: active
                        ? Icon(
                            Icons.check_rounded,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.black : const Color(0xFF67615A),
                            size: 22,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ] else if (activeTab == 1) ...[
            // Preset Gradients
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _presetGradients.map((grad) {
                final active = widget.initialColorType == 'gradient' &&
                    widget.initialColor == grad[0] &&
                    widget.initialColor2 == grad[1];
                return GestureDetector(
                  onTap: () {
                    widget.onChanged(grad[0], grad[1], 'gradient');
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(grad[0]), Color(grad[1])],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: active
                            ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.white30 : Colors.black12),
                        width: active ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: active
                        ? Icon(
                            Icons.check_rounded,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.black : const Color(0xFF67615A),
                            size: 22,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ] else if (activeTab == 2) ...[
            // Custom Solid
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: solidColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black12,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildHsvSliders(
              h: solidH,
              s: solidS,
              v: solidV,
              onH: (val) => setState(() => solidH = val),
              onS: (val) => setState(() => solidS = val),
              onV: (val) => setState(() => solidV = val),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  widget.onChanged(solidColor.toARGB32(), null, 'solid');
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('Apply Custom Color'),
              ),
            ),
          ] else if (activeTab == 3) ...[
            // Custom Gradient
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => activeGradColorIndex = 0),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: gradStartColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: activeGradColorIndex == 0
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black26,
                            width: activeGradColorIndex == 0 ? 3.0 : 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('Start Color', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  width: 50,
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [gradStartColor, gradEndColor]),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: () => setState(() => activeGradColorIndex = 1),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: gradEndColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: activeGradColorIndex == 1
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black26,
                            width: activeGradColorIndex == 1 ? 3.0 : 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('End Color', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (activeGradColorIndex == 0)
              _buildHsvSliders(
                h: gradStartH,
                s: gradStartS,
                v: gradStartV,
                onH: (val) => setState(() => gradStartH = val),
                onS: (val) => setState(() => gradStartS = val),
                onV: (val) => setState(() => gradStartV = val),
              )
            else
              _buildHsvSliders(
                h: gradEndH,
                s: gradEndS,
                v: gradEndV,
                onH: (val) => setState(() => gradEndH = val),
                onS: (val) => setState(() => gradEndS = val),
                onV: (val) => setState(() => gradEndV = val),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  widget.onChanged(gradStartColor.toARGB32(), gradEndColor.toARGB32(), 'gradient');
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('Apply Custom Gradient'),
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

extension ColorExtensions on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}
