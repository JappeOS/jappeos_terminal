//  jappeos_terminal, A terminal emulator for JappeOS, built with Flutter.
//  Copyright (C) 2026  The JappeOS team.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Affero General Public License as
//  published by the Free Software Foundation, either version 3 of the
//  License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Affero General Public License for more details.
//
//  You should have received a copy of the GNU Affero General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:jappeos_terminal/src/terminal_widget.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'tabbed_window.dart';

class MainPageTabbed extends StatefulWidget {
  final String title;

  const MainPageTabbed({super.key, required this.title});

  @override
  State<MainPageTabbed> createState() => _MainPageTabbedState();
}

class _MainPageTabbedState extends State<MainPageTabbed> {
  String _title = 'Terminal';
  List<TabPaneData<Tab>> _tabs = [];
  int _focused = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _newTab();
  }

  @override
  Widget build(BuildContext context) {
    _title = _tabs.isNotEmpty ? _tabs[_focused].data.title : widget.title;
    final theme = Theme.of(context);
    return Scaffold(
      headers: [
      ],
      child: TabbedWindow<Tab>(
        items: _tabs,
        itemBuilder: (context, item, index) {
          return _buildTabItem(item);
        },
        focused: _focused,
        onFocused: (value) {
          setState(() {
            _focused = value;
          });
        },
        onSort: (value) {
          setState(() {
            _tabs = value;
          });
        },
        leading: [
          Padding(
            padding: EdgeInsets.all(4 * theme.scaling),
            child: Icon(Icons.terminal),
          ),
        ],
        trailing: [
          IconButton.ghost(
            icon: const Icon(Icons.add),
            density: ButtonDensity.iconDense,
            onPressed: () => _newTab(),
          ),
        ],
        child: IndexedStack(
          index: _focused,
          children: _tabs.map((e) => e.data.content).toList(),
        ),
      ),
    );
  }

  void _newTab() {
    setState(() {
      int max = _tabs.fold<int>(0, (previousValue, element) {
        return element.data.count > previousValue
            ? element.data.count
            : previousValue;
      });
      _tabs.add(
        TabPaneData(
          Tab(
            'Terminal ${max + 1}',
            max + 1,
            TerminalWidget(
              key: GlobalKey(),
              onTitleChanged: (p0) => setState(() {
                _tabs[max].data.title = p0;
              }),
            ),
          ),
        ),
      );
      _focused = _tabs.length - 1;
    });
  }

  void _closeTab(TabPaneData data) {
    setState(() => _tabs.remove(data));
    if (_tabs.isEmpty) {
      _newTab();
    }
    if (_focused >= _tabs.length) {
      setState(() => _focused = _tabs.length - 1);
    }
  }

  TabItem _buildTabItem(TabPaneData data) {
    return TabItem(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 150, maxWidth: 500),
        child: Label(
          leading: OutlinedContainer(
            backgroundColor: Colors.white,
            width: 18,
            height: 18,
            borderRadius: Theme.of(context).borderRadiusMd,
            child: Center(
              child: Text(
                data.data.count.toString(),
                style: const TextStyle(color: Colors.black),
              ).xSmall().bold(),
            ),
          ),
          trailing: IconButton.ghost(
            shape: ButtonShape.circle,
            size: ButtonSize.small,
            icon: const Icon(Icons.close),
            onPressed: () => _closeTab(data),
          ),
          child: Text(
            data.data.title,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class Tab {
  String title;
  final int count;
  final Widget content;
  Tab(this.title, this.count, this.content);

  @override
  String toString() {
    return 'TabData{title: $title, count: $count, content: $content}';
  }
}