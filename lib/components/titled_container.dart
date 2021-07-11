import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/theme/theme.dart';

class TitledContainer extends StatelessWidget {
  final String? title;
  final double titleSize;
  final String? subtitle;
  final double subtitleSize;
  final double subtitleSpacing;
  final bool subtitleAboveTitle;
  final bool showBackArrow;
  final List<Widget> children;
  final Widget? trailing;
  final Widget? subTitleTrailing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final TextAlign textAlign;

  TitledContainer(
      {this.title,
      this.titleSize = 20,
      this.subtitle,
      this.subtitleSize = 13,
      this.subtitleSpacing = 4,
      this.subtitleAboveTitle = false,
      this.showBackArrow = false,
      this.textAlign = TextAlign.left,
      required final Widget child,
      this.trailing,
      this.subTitleTrailing,
      this.crossAxisAlignment = CrossAxisAlignment.start,
      this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
      Key? key})
      : this.children = [child];

  TitledContainer.multipleChildren(
      {this.title,
      this.titleSize = 20,
      this.subtitle,
      this.subtitleSize = 15,
      this.subtitleSpacing = 4,
      this.subtitleAboveTitle = false,
      this.showBackArrow = false,
      required this.children,
      this.trailing,
      this.subTitleTrailing,
      this.crossAxisAlignment = CrossAxisAlignment.start,
      this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
      this.textAlign = TextAlign.left,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: crossAxisAlignment,
            children: [
              if (subtitle != null && subtitleAboveTitle) _buildSubtitle(context, state),
              Row(
                mainAxisAlignment: mainAxisAlignment,
                children: [
                  if (showBackArrow)
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          minimumSize: Size(35, 30),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: appTheme(context, state.userSettings.themeMode).textColor,
                        ),
                      ),
                    ),
                  if (title != null) _buildTitle(context, state),
                  if (trailing != null) trailing!,
                ],
              ),
              if (subtitle != null && !subtitleAboveTitle) _buildSubtitle(context, state),
              ...children,
            ],
          );
        },
      );

  Widget _buildTitle(final BuildContext context, final UserSettingsState userSettingsState) {
    return Flexible(
      flex: trailing != null ? 4 : 1,
      child: Text(
        title!,
        textAlign: textAlign,
        style: TextStyle(fontSize: titleSize, color: appTheme(context, userSettingsState.userSettings.themeMode).textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubtitle(final BuildContext context, final UserSettingsState userSettingsState) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Flexible(
          flex: subTitleTrailing != null ? 4 : 1,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: subtitleSpacing),
            child: Text(
              subtitle!,
              style: TextStyle(
                fontSize: subtitleSize,
                color: appTheme(context, userSettingsState.userSettings.themeMode).textColor.withOpacity(.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (subTitleTrailing != null) subTitleTrailing!,
      ],
    );
  }
}
