import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/components/titled_container.dart';
import 'package:guess_the_move/screens/settings/pages/about/components/about_element.dart';
import 'package:guess_the_move/theme/theme.dart';

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
                title: 'Github Repository',
                names: [
                  'Du findest das Github Repository zu diesem Projekt unter folgendem Link:',
                  '',
                  'https://github.com/TODO', // TODO Add repository url
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
