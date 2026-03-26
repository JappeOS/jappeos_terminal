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

import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'main_page_tabbed.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      title: 'Terminal',
      theme: _getTheme(false),
      darkTheme: _getTheme(true),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const MainPageTabbed(title: 'Terminal'),
    );
  }

  ThemeData _getTheme(bool dark) => ThemeData(
    colorScheme: dark
        ? ColorSchemes.darkDefaultColor
        : ColorSchemes.lightDefaultColor,
    radius: 0.9,
    surfaceOpacity: 0.85,
    surfaceBlur: 9,
  );
}