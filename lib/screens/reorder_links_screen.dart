import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        Colors,
        ReorderableListView,
        ThemeData,
        Material,
        Theme,
        ListTile,
        ValueKey,
        ReorderableDragStartListener;

import '../models/social_link.dart';
import '../utils/app_state.dart';

class ReorderLinksScreen extends StatefulWidget {
  const ReorderLinksScreen({super.key});

  @override
  State<ReorderLinksScreen> createState() => _ReorderLinksScreenState();
}

class _ReorderLinksScreenState extends State<ReorderLinksScreen> {
  late List<SocialLink> _personalLinks;
  late List<SocialLink> _businessLinks;
  String _selectedCategory = 'personal';

  @override
  void initState() {
    super.initState();
    final allLinks = userLinksNotifier.value;
    _personalLinks = allLinks.where((l) => l.category == 'personal').toList();
    _businessLinks = allLinks.where((l) => l.category == 'business').toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0F172A),
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Sıralamayı Düzenle',
          style: TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Kaydet'),
          onPressed: () {
            userLinksNotifier.value = [..._personalLinks, ..._businessLinks];
            Navigator.pop(context);
          },
        ),
      ),
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Theme(
            data: ThemeData(canvasColor: const Color(0xFF0F172A)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CupertinoSlidingSegmentedControl<String>(
                    groupValue: _selectedCategory,
                    backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.5),
                    thumbColor: const Color(0xFF00D2FF),
                    children: {
                      'personal': const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Kişisel',
                          style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      'business': const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'İş',
                          style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    },
                    onValueChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: _selectedCategory == 'personal' ? _personalLinks.length : _businessLinks.length,
                    proxyDecorator: (Widget child, int index, Animation<double> animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (BuildContext context, Widget? child) {
                          final double animValue = Curves.easeInOut.transform(animation.value);
                          final double scale = 1.0 + (0.05 * animValue);
                          final double elevation = 10.0 * animValue;
                          return Transform.scale(
                            scale: scale,
                            child: Material(
                              elevation: elevation,
                              color: Colors.transparent,
                              shadowColor: Colors.black.withValues(alpha: 0.5),
                              child: child,
                            ),
                          );
                        },
                        child: child,
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) newIndex -= 1;
                        final targetList = _selectedCategory == 'personal' ? _personalLinks : _businessLinks;
                        final item = targetList.removeAt(oldIndex);
                        targetList.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final targetList = _selectedCategory == 'personal' ? _personalLinks : _businessLinks;
                      final link = targetList[index];
                      return Container(
                        key: ObjectKey(link),
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          leading: Icon(link.icon, color: link.color, size: 32),
                          title: Text(
                            link.platform,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            link.url,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: ReorderableDragStartListener(
                            index: index,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                CupertinoIcons.line_horizontal_3,
                                color: CupertinoColors.systemGrey,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
