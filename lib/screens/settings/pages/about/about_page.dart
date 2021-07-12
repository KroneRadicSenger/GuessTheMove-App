import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/screens/settings/pages/about/components/about_element.dart';
import 'package:guess_the_move/screens/settings/utils/show_confirmation_dialog.dart';
import 'package:guess_the_move/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';

const githubRepositoriesUrl = 'https://github.com/KroneRadicSenger';

class AboutPage extends StatelessWidget {
  AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, state) => Container(
          decoration: BoxDecoration(
            color: appTheme(context, state.userSettings.themeMode).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(30.0),
              topRight: const Radius.circular(30.0),
            ),
          ),
          child: TitledContainer.multipleChildren(
            title: 'Über diese App',
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 20),
              AboutElement(
                title: 'Projektrahmen',
                names: [
                  'Bachelor Forschungsprojekt INF',
                  'Universität Stuttgart',
                  'Formale Methoden der Informatik (FMI)',
                  'Bei Professor Manfred Kufleitner',
                  'Zeitraum: Januar 2021 - Juli 2021',
                ],
              ),
              AboutElement(
                title: 'Umsetzung',
                names: [
                  'Simon Krone',
                  'Andrijana Radic',
                  'Tobias Senger',
                  '',
                  'Wir sind alle drei Studentinnen und Studenten im B.Sc. Informatik ' +
                      'an der Universität Stuttgart und haben dieses Projekt mit viel Mühe und' +
                      ' Leidenschaft in die Tat umgesetzt. Wir hoffen, dass wir hiermit dem/r einen ' +
                      'oder anderen Schachspieler/in dabei helfen können, besser im Schachspielen zu werden. ' +
                      'Die App ist vollständig Open-Source und kann unter dem unten aufgeführten Link eingesehen werden. ' +
                      'Für Fragen und Anregungen kannst du gerne in unserem Github Repository vorbeischauen.',
                ],
              ),
              AboutElement(
                title: 'Github Repositories',
                names: [
                  'Du findest die Github Repositories zu diesem Projekt unter folgendem Link:',
                ],
                trailingWidgets: [
                  Container(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (await canLaunch(githubRepositoriesUrl)) {
                        await launch(
                          githubRepositoriesUrl,
                          forceSafariVC: false,
                          forceWebView: false,
                        );
                      } else {
                        showConfirmationDialog(
                          context,
                          GameModeEnum.findTheGrandmasterMoves,
                          state,
                          () {},
                          'Fehler',
                          'Die Webseite konnte nicht im Browser geöffnet werden!',
                          onlyConfirm: true,
                        );
                      }
                    },
                    child: const Text(githubRepositoriesUrl, textAlign: TextAlign.center),
                  ),
                ],
              ),
              Container(height: 20),
            ],
            trailing: null,
          ),
        ),
      );

  String getCurrentThemeText(String text) {
    return text.split('.').last.toUpperCase();
  }
}
