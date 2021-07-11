import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';

class HorizontalList extends StatefulWidget {
  final List<Widget> elements;
  final bool automaticallyScrollToEnd;
  final int scrollSpeedMillis;
  final double height;
  final EdgeInsets margin;
  final double spaceBetweenElements;

  HorizontalList(
      {required this.elements,
      this.height = 170,
      this.automaticallyScrollToEnd = false,
      this.scrollSpeedMillis = 500,
      this.margin = const EdgeInsets.symmetric(vertical: 20),
      this.spaceBetweenElements = 20,
      Key? key})
      : super(key: key);

  @override
  _HorizontalListState createState() => _HorizontalListState();
}

class _HorizontalListState extends State<HorizontalList> {
  final _controller = ScrollController();

  @override
  Widget build(BuildContext context) => BlocBuilder<UserSettingsBloc, UserSettingsState>(builder: (context, state) {
        if (widget.automaticallyScrollToEnd) {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            _controller.animateTo(
              _controller.position.maxScrollExtent,
              duration: Duration(milliseconds: widget.scrollSpeedMillis),
              curve: Curves.fastOutSlowIn,
            );
          });
        }

        return Container(
          height: widget.height,
          margin: widget.margin,
          child: ListView.separated(
            physics: BouncingScrollPhysics(),
            controller: _controller,
            scrollDirection: Axis.horizontal,
            itemCount: widget.elements.length,
            itemBuilder: (BuildContext context, int index) => widget.elements[index],
            separatorBuilder: (BuildContext context, int index) => SizedBox(width: widget.spaceBetweenElements),
          ),
        );
      });
}
