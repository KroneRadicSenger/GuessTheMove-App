import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';

class VerticalList extends StatelessWidget {
  final List<Widget> elements;
  VerticalList({required this.elements, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, state) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 30.0),
            child: ListView.separated(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: elements.length,
              itemBuilder: (BuildContext context, int index) => elements[index],
              separatorBuilder: (BuildContext context, int index) => SizedBox(height: 20),
            ),
          ),
        );
      });
}
