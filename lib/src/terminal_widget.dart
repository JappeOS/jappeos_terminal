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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:xterm/xterm.dart';

class TerminalWidget extends StatefulWidget {
  final void Function(String)? onTitleChanged;

  const TerminalWidget({super.key, this.onTitleChanged});

  @override
  State<TerminalWidget> createState() => _TerminalWidgetState();
}

class _TerminalWidgetState extends State<TerminalWidget> {
  late final Terminal _terminal;

  final _terminalController = TerminalController();
  final _scrollController = ScrollController();
  late final Pty _pty;

  @override
  void initState() {
    super.initState();
    _terminal = Terminal(
      maxLines: 10000,
      onTitleChange: widget.onTitleChanged,
    );
    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) _startPty();
      },
    );
    //_terminal.write('JappeOS Terminal v.1.0.0\n\n');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scrollbar(
      controller: _scrollController,
      child: TerminalView(
        _terminal,
        controller: _terminalController,
        scrollController: _scrollController,
        autofocus: true,
        backgroundOpacity: 0,
        padding: EdgeInsets.all(2 * theme.scaling),
        textStyle: TerminalStyle(fontSize: theme.typography.normal.fontSize ?? 14),
        onSecondaryTapDown: (details, offset) async {
          final selection = _terminalController.selection;
          if (selection != null) {
            final text = _terminal.buffer.getText(selection);
            _terminalController.clearSelection();
            await Clipboard.setData(ClipboardData(text: text));
          } else {
            final data = await Clipboard.getData('text/plain');
            final text = data?.text;
            if (text != null) {
              _terminal.paste(text);
            }
          }
        },
      ),
    );
  }

  void _startPty() {
    _pty = Pty.start(
      shell,
      columns: _terminal.viewWidth,
      rows: _terminal.viewHeight,
    );

    _pty.output
        .cast<List<int>>()
        .transform(Utf8Decoder())
        .listen(_terminal.write);

    _pty.exitCode.then((code) {
      _terminal.write('the process exited with exit code $code');
    });

    _terminal.onOutput = (data) {
      _pty.write(const Utf8Encoder().convert(data));
    };

    _terminal.onResize = (w, h, pw, ph) {
      _pty.resize(h, w);
    };
  }
}

String get shell {
  if (Platform.isMacOS || Platform.isLinux) {
    return Platform.environment['SHELL'] ?? 'bash';
  }

  if (Platform.isWindows) {
    return 'cmd.exe';
  }

  return 'sh';
}