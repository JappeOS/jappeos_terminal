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

import 'dart:async';

import 'package:flutter/gestures.dart' hide kDoubleTapMinTime;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:yaru_window/yaru_window.dart';

class TabbedWindow<T> extends StatefulWidget {
  /// List of tab data items to display in the tab pane.
  ///
  /// Type: `List<TabPaneData<T>>`. Each item contains the data for one tab
  /// and will be passed to the [itemBuilder] to create the visual representation.
  final List<TabPaneData<T>> items;

  /// Builder function to create tab child widgets from data items.
  ///
  /// Type: `TabPaneItemBuilder<T>`. Called for each tab item to create the
  /// visual representation in the tab bar. Should return a TabChild widget.
  final TabPaneItemBuilder<T> itemBuilder;

  /// Callback invoked when tabs are reordered through drag-and-drop.
  ///
  /// Type: `ValueChanged<List<TabPaneData<T>>>?`. Called with the new tab
  /// order when sorting operations complete. If null, sorting is disabled.
  final ValueChanged<List<TabPaneData<T>>>? onSort;

  /// Index of the currently focused/selected tab.
  ///
  /// Type: `int`. Zero-based index of the active tab. The focused tab receives
  /// special visual styling and its content is typically displayed.
  final int focused;

  /// Callback invoked when the focused tab changes.
  ///
  /// Type: `ValueChanged<int>`. Called when a tab is selected either through
  /// user interaction or programmatic changes during sorting operations.
  final ValueChanged<int> onFocused;

  /// Widgets displayed at the leading edge of the tab bar.
  ///
  /// Type: `List<Widget>`, default: `[]`. These widgets appear before the
  /// scrollable tab area, useful for controls or branding elements.
  final List<Widget> leading;

  /// Widgets displayed at the trailing edge of the tab bar.
  ///
  /// Type: `List<Widget>`, default: `[]`. These widgets appear after the
  /// scrollable tab area, useful for actions or controls.
  final List<Widget> trailing;

  /// Background color for the content area and active tabs.
  ///
  /// Type: `Color?`. If null, uses the theme's card background color.
  /// Provides consistent styling across the tab pane components.
  final Color? backgroundColor;

  /// Border styling for the tab pane container.
  ///
  /// Type: `BorderSide?`. If null, uses theme defaults for border appearance
  /// around the entire tab pane structure.
  final BorderSide? border;

  /// Whether the title bar visualized as active.
  final bool? isActive;

  /// Whether the title bar shows a close button.
  final bool? isClosable;

  /// Whether the title bar can be dragged to move the window.
  final bool? isDraggable;

  /// Whether the title bar shows a maximize button.
  final bool? isMaximizable;

  /// Whether the title bar shows a minimize button.
  final bool? isMinimizable;

  /// Whether the title bar shows a restore button.
  final bool? isRestorable;

  /// Called when the close button is pressed.
  final FutureOr<void> Function(BuildContext)? onClose;

  /// Called when the title bar is dragged to move the window.
  final FutureOr<void> Function(BuildContext)? onDrag;

  /// Called when the maximize button is pressed or the title bar is
  /// double-clicked while the window is not maximized.
  final FutureOr<void> Function(BuildContext)? onMaximize;

  /// Called when the minimize button is pressed.
  final FutureOr<void> Function(BuildContext)? onMinimize;

  /// Called when the restore button is pressed or the title bar is
  /// double-clicked while the window is maximized.
  final FutureOr<void> Function(BuildContext)? onRestore;

  /// Called when the secondary mouse button is pressed.
  final FutureOr<void> Function(BuildContext)? onShowMenu;

  /// The main content widget displayed in the content area.
  ///
  /// Type: `Widget`. This widget fills the content area above the tab bar
  /// and typically shows content related to the currently focused tab.
  final Widget child;

  /// Creates a tabbed window with the given configuration.
  const TabbedWindow({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.focused = 0,
    required this.onFocused,
    this.leading = const [],
    this.trailing = const [],
    this.backgroundColor,
    this.border,
    this.onSort,
    this.isActive,
    this.isClosable,
    this.isDraggable,
    this.isMaximizable,
    this.isMinimizable,
    this.isRestorable,
    this.onClose = YaruWindow.close,
    this.onDrag = YaruWindow.drag,
    this.onMaximize = YaruWindow.maximize,
    this.onMinimize = YaruWindow.minimize,
    this.onRestore = YaruWindow.restore,
    this.onShowMenu = YaruWindow.showMenu,
    required this.child,
  });

  @override
  State<TabbedWindow<T>> createState() => _TabbedWindowState<T>();

  /// Ensures that the window is initialized.
  static Future<void> ensureInitialized() {
    _TabbedWindowState._windowStates.clear();
    return YaruWindow.ensureInitialized().then((window) => window.hideTitle());
  }
}

class _TabbedWindowState<T> extends State<TabbedWindow<T>> {
  static final _windowStates = <YaruWindowInstance, YaruWindowState>{};

  @override
  Widget build(BuildContext context) {
    final window = YaruWindow.of(context);
    final gestureSettings = MediaQuery.maybeOf(context)?.gestureSettings;
    final theme = Theme.of(context);
    const bSpacing = 0.0;
    final bPadding = EdgeInsets.only(left: 4 * theme.scaling);

    final closeButton = ShadeWindowControl(
      icon: Icons.close_sharp,
      onTap: widget.onClose != null ? () => widget.onClose!(context) : null,
    );

    return StreamBuilder<YaruWindowState>(
      stream: window.states(),
      initialData: _windowStates[window],
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _windowStates[window] = snapshot.data!;
        }
        final state = snapshot.data;
        final isActive = widget.isActive ?? state?.isActive;
        final isClosable = widget.isClosable ?? state?.isClosable;
        final isDraggable = widget.isDraggable ?? state?.isMovable;
        final isMaximizable = widget.isMaximizable ?? state?.isMaximizable;
        final isMinimizable = widget.isMinimizable ?? state?.isMinimizable;
        final isRestorable = widget.isRestorable ?? state?.isRestorable;

        Widget? backdropEffect(Widget? child) {
          if (child == null) return null;
          return AnimatedOpacity(
            opacity: isActive == true ? 1 : 0.75,
            duration: const Duration(milliseconds: 100),
            child: child,
          );
        }

        Widget buildWindowControls() => Padding(
          padding: bPadding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: bSpacing,
            children: [
              if (isMinimizable == true)
                ShadeWindowControl(
                  icon: Icons.minimize_sharp,
                  onTap: widget.onMinimize != null ? () => widget.onMinimize!(context) : null,
                ),
              if (isRestorable == true)
                ShadeWindowControl(
                  icon: Icons.fullscreen_exit_sharp,
                  onTap: widget.onRestore != null ? () => widget.onRestore!(context) : null,
                ),
              if (isMaximizable == true)
                ShadeWindowControl(
                  icon: Icons.square_outlined,
                  onTap: widget.onMaximize != null ? () => widget.onMaximize!(context) : null,
                ),
              if (isClosable == true)
                isMaximizable == true
                    ? closeButton
                    : ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(6),
                        ),
                        child: closeButton,
                      ),
            ],
          ),
        );

        return RawGestureDetector(
          behavior: HitTestBehavior.translucent,
          gestures: {
            PanGestureRecognizer: GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
              PanGestureRecognizer.new,
              (instance) => instance
                ..gestureSettings = gestureSettings
                //..onDown = ((p0) => widget.onDragStart?.call(context, p0))
                //..onEnd = ((p0) => widget.onDragEnd?.call(context, p0))
                ..onUpdate = ((p0) => widget.onDrag?.call(context/*, p0*/)),
            ),
            _PassiveTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<_PassiveTapGestureRecognizer>(
              _PassiveTapGestureRecognizer.new,
              (instance) => instance
                ..onDoubleTap = (() => isMaximizable == true
                    ? widget.onMaximize?.call(context)
                    : isRestorable == true
                        ? widget.onRestore?.call(context)
                        : null)
                ..onSecondaryTap = widget.onShowMenu != null ? () => widget.onShowMenu!(context) : null
                ..gestureSettings = gestureSettings,
            ),
          },
          child: TabPane<T>(
            items: widget.items,
            itemBuilder: widget.itemBuilder,
            focused: widget.focused,
            onFocused: widget.onFocused,
            onSort: widget.onSort,
            leading: widget.leading,
            trailing: [
              Gap(8 * theme.scaling),
              ...widget.trailing,
              Gap(8 * theme.scaling),
              if (isMinimizable == true || isRestorable == true || isMaximizable == true || isClosable == true)
                backdropEffect(buildWindowControls())!,
            ],
            borderRadius: BorderRadius.circular(8 * theme.scaling), // Border radius controls the padding of the tab bar.
            backgroundColor: widget.backgroundColor,
            border: widget.border,
            barHeight: 45.0,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _PassiveTapGestureRecognizer extends TapGestureRecognizer {
  _PassiveTapGestureRecognizer() {
    onTapUp = (_) {};
    onTapCancel = () {};
  }

  GestureDoubleTapCallback? onDoubleTap;

  PointerDownEvent? _firstTapDown;
  PointerUpEvent? _firstTapUp;

  @protected
  @override
  void handleTapUp({
    required PointerDownEvent down,
    required PointerUpEvent up,
  }) {
    super.handleTapUp(down: down, up: up);
    if (onDoubleTap != null && _firstTapDown != null && _firstTapUp != null && down.buttons == kPrimaryButton) {
      // the time from the first tap down to the second tap down
      final interval = down.timeStamp - _firstTapDown!.timeStamp;
      // the time from the first tap up to the second tap down
      final timeBetween = down.timeStamp - _firstTapUp!.timeStamp;
      // the distance between the first tap down and the first tap up
      final slop = (_firstTapDown!.position - _firstTapUp!.position).distance;
      // the distance between the first tap down and the second tap down
      final secondSlop = (_firstTapDown!.position - down.position).distance;
      if (interval < kDoubleTapTimeout && timeBetween >= kDoubleTapMinTime && slop <= kDoubleTapTouchSlop && secondSlop <= kDoubleTapSlop) {
        invokeCallback<void>('onDoubleTap', onDoubleTap!);
        _firstTapDown = null;
        _firstTapUp = null;
        return;
      }
    }
    _firstTapDown = down;
    _firstTapUp = up;
  }

  @protected
  @override
  void handleTapCancel({
    required PointerDownEvent down,
    PointerCancelEvent? cancel,
    required String reason,
  }) {
    super.handleTapCancel(down: down, cancel: cancel, reason: reason);
    _firstTapDown = null;
    _firstTapUp = null;
  }
}