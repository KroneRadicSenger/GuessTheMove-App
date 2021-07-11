import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/oss_licenses.dart';
import 'package:guess_the_move/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class OssLicensesPage extends StatelessWidget {
  static Future<List<String>> loadLicenses() async {
    ossLicenses["Cburnett Schachfiguren"] = {
      "name": "Cburnett Schachfiguren",
      "description": "SVG chess pieces",
      "homepage": "https://commons.wikimedia.org/wiki/Category:SVG_chess_pieces",
      "authors": ["Cburnett"],
      "version": "",
      "license":
          "Copyright © Cburnett (https://commons.wikimedia.org/wiki/Category:SVG_chess_pieces)\n\nRedistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n\n1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n3. Neither the name of The author nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.\n\nTHIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.",
      "isMarkdown": false,
      "isSdk": false,
      "isDirectDependency": true
    };

    ossLicenses["Game Icons"] = {
      "name": "game-icons.net icons",
      "description": "SVG game icons",
      "homepage": "https://game-icons.net/",
      "authors": ["Delapouite", "Lorc"],
      "version": "",
      "license": "" +
          "Confirmed icon (https://game-icons.net/1x1/delapouite/confirmed.html) by Delapouite under CC BY 3.0\n\nHalf dead icon (https://game-icons.net/1x1/delapouite/half-dead.html) by Delapouite under CC BY 3.0\n\nJigsaw piece icon (https://game-icons.net/1x1/lorc/jigsaw-piece.html) by Lorc under CC BY 3.0\n\nStars stack icon (https://game-icons.net/1x1/delapouite/stars-stack.html) by Delapouite under CC BY 3.0\n\nThrone king icon (https://game-icons.net/1x1/delapouite/throne-king.html) by Delapouite under CC BY 3.0\n\nTime trap icon (https://game-icons.net/1x1/lorc/time-trap.html) by Lorc under CC BY 3.0\n\nTwo coins icon (https://game-icons.net/1x1/delapouite/two-coins.html) by Delapouite under CC BY 3.0",
      "isMarkdown": false,
      "isSdk": false,
      "isDirectDependency": true
    };

    // merging non-dart based dependency list using LicenseRegistry.
    final ossKeys = ossLicenses.keys.toList();
    final lm = <String, List<String>>{};
    await for (var l in LicenseRegistry.licenses) {
      for (var p in l.packages) {
        if (!ossKeys.contains(p)) {
          final lp = lm.putIfAbsent(p, () => []);
          lp.addAll(l.paragraphs.map((p) => p.text));
          ossKeys.add(p);
        }
      }
    }
    for (var key in lm.keys) {
      ossLicenses[key] = {'license': lm[key]!.join('\n')};
    }

    return ossKeys..sort();
  }

  static final _licenses = loadLicenses();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _licenses,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return TitledContainer(
            title: 'Open-Source-Software',
            titleSize: 22,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            child: Container(
              margin: const EdgeInsets.only(top: 30),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return TitledContainer.multipleChildren(
          title: 'Open-Source-Software',
          titleSize: 22,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: !snapshot.hasData
              ? []
              : [
                  Container(height: 30),
                  ...snapshot.data!.map(
                    (final key) {
                      final licenseJson = ossLicenses[key];
                      final version = licenseJson['version'];
                      final desc = licenseJson['description'];

                      return ListTile(
                        title: Text('$key ${version ?? ''}'),
                        subtitle: desc != null ? Text(desc) : null,
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => MiscOssLicenseSingle(name: key, json: licenseJson))),
                      );
                    },
                  ).toList(),
                ],
        );
      },
    );
  }
}

class MiscOssLicenseSingle extends StatelessWidget {
  final String name;
  final Map<String, dynamic> json;

  String? get version => json['version'];
  String? get description => json['description'];
  String? get licenseText => json['license'];
  String? get homepage => json['homepage'];

  MiscOssLicenseSingle({required this.name, required this.json});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, userSettingsState) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '$name ${version ?? ''}',
            style: TextStyle(
              color: appTheme(context, userSettingsState.userSettings.themeMode).textColor,
            ),
          ),
          backgroundColor: appTheme(context, userSettingsState.userSettings.themeMode).cardBackgroundColor,
        ),
        body: Container(
          color: Theme.of(context).canvasColor,
          child: ListView(
            children: [
              if (description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                  child: Text(
                    description!,
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              if (homepage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                  child: InkWell(
                    child: Text(homepage!, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                    onTap: () => launch(homepage!),
                  ),
                ),
              if (description != null || homepage != null) const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                child: Text(_bodyText(), style: Theme.of(context).textTheme.bodyText2),
              ),
              Container(height: 30),
            ],
          ),
        ),
      );
    });
  }

  String _bodyText() {
    if (licenseText == null) {
      return '';
    }
    return licenseText!.split('\n').map((line) {
      if (line.startsWith('//')) line = line.substring(2);
      line = line.trim();
      return line;
    }).join('\n');
  }
}
