import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_move/bloc/user_settings_bloc.dart';
import 'package:guess_the_move/model/analyzed_game.dart';
import 'package:guess_the_move/model/analyzed_games_bundle.dart';
import 'package:guess_the_move/model/game_mode.dart';
import 'package:guess_the_move/model/player.dart';
import 'package:guess_the_move/screens/select_games/components/grandmaster_games_loading_indicator.dart';
import 'package:guess_the_move/theme/theme.dart';

const defaultELORangeValues = const RangeValues(2000, 3000);

class SearchGamesModalContents extends StatefulWidget {
  final Player grandmaster;
  final GameModeEnum gameMode;
  final AnalyzedGamesBundle selectedBundle;
  final Future<List<AnalyzedGame>> selectedBundleLoadFuture;
  final FilterOptions? currentFilterOptions;
  final Function(FilterOptions) onSubmitSearch;

  const SearchGamesModalContents(
      {Key? key,
      required this.grandmaster,
      required this.gameMode,
      required this.selectedBundle,
      required this.selectedBundleLoadFuture,
      required this.currentFilterOptions,
      required this.onSubmitSearch})
      : super(key: key);

  @override
  _SearchGamesModalContentsState createState() => _SearchGamesModalContentsState();
}

class _SearchGamesModalContentsState extends State<SearchGamesModalContents> {
  String? _selectedOpponent;
  String? _selectedOpening;
  String? _selectedEvent;
  final ValueNotifier<DateTime?> _selectedDateTimeNotifier = ValueNotifier(null);
  RangeValues _currentGrandmasterELORangeValues = defaultELORangeValues;
  RangeValues _currentOpponentELORangeValues = defaultELORangeValues;

  @override
  void initState() {
    _selectedOpponent = widget.currentFilterOptions == null ? null : widget.currentFilterOptions!.selectedOpponent;
    _selectedOpening = widget.currentFilterOptions == null ? null : widget.currentFilterOptions!.selectedOpening;
    _selectedEvent = widget.currentFilterOptions == null ? null : widget.currentFilterOptions!.selectedEvent;
    _selectedDateTimeNotifier.value = widget.currentFilterOptions == null ? null : widget.currentFilterOptions!.selectedDate;
    if (widget.currentFilterOptions != null) {
      _currentGrandmasterELORangeValues = widget.currentFilterOptions!.selectedGrandmasterELORange!;
      _currentOpponentELORangeValues = widget.currentFilterOptions!.selectedOpponentELORange!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, state) {
        return FutureBuilder<List<AnalyzedGame>>(
            future: widget.selectedBundleLoadFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return GrandmasterGamesLoadingIndicator(userSettingsState: state);
              }

              final opponentNames = snapshot.data!
                  .map((analyzedGame) => analyzedGame.whitePlayer != widget.grandmaster ? analyzedGame.whitePlayer : analyzedGame.blackPlayer)
                  .map((player) => player.getFirstAndLastName())
                  .toSet()
                  .toList();
              opponentNames.sort();

              final openings = snapshot.data!.map((analyzedGame) => analyzedGame.gameAnalysis.opening.name).toSet().toList();
              openings.sort();

              final events = snapshot.data!.map((analyzedGame) => analyzedGame.gameInfo.event).toSet().toList();
              events.sort();

              return Column(
                children: [
                  _buildDropdownSearch<String>(
                      context: context,
                      state: state,
                      icon: Icons.person,
                      labelText: 'Gegner auswählen',
                      searchHintText: 'Name des Gegners eingeben',
                      items: opponentNames,
                      selectedItem: _selectedOpponent,
                      onChanged: (newOponnentSelected) => setState(() => _selectedOpponent = newOponnentSelected)),
                  _buildDropdownSearch<String>(
                      context: context,
                      state: state,
                      icon: Icons.arrow_forward,
                      labelText: 'Eröffnung auswählen',
                      searchHintText: 'Name der Eröfnnung eingeben',
                      items: openings,
                      selectedItem: _selectedOpening,
                      onChanged: (newOpeningSelected) => setState(() => _selectedOpening = newOpeningSelected)),
                  _buildDropdownSearch<String>(
                      context: context,
                      state: state,
                      icon: Icons.emoji_events,
                      labelText: 'Event auswählen',
                      searchHintText: 'Name des Events eingeben',
                      items: events,
                      selectedItem: _selectedEvent,
                      onChanged: (newEventSelected) => setState(() => _selectedEvent = newEventSelected)),
                  _buildDateDialogButton(context, state, snapshot.data!),
                  _buildGrandmasterELOInputFields(context, state),
                  _buildOpponentELOInputFields(context, state),
                  _buildSearchButton(context, state),
                ],
              );
            });
      },
    );
  }

  Widget _buildDropdownSearch<ItemType>(
      {required BuildContext context,
      required UserSettingsState state,
      required IconData icon,
      required String labelText,
      required final String searchHintText,
      required List<ItemType> items,
      required ItemType? selectedItem,
      required Function(ItemType?) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: DropdownSearch<ItemType>(
        mode: Mode.DIALOG,
        showSearchBox: true,
        autoFocusSearchBox: true,
        enabled: true,
        items: items,
        label: labelText,
        hint: labelText,
        onChanged: onChanged,
        clearButton: Icon(Icons.clear, color: appTheme(context, state.userSettings.themeMode).textColor),
        dropDownButton: Icon(Icons.arrow_drop_down, color: appTheme(context, state.userSettings.themeMode).textColor),
        showClearButton: true,
        showSelectedItem: true,
        selectedItem: selectedItem,
        dropdownSearchDecoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(icon, color: appTheme(context, state.userSettings.themeMode).textColor),
          ),
        ),
        searchBoxDecoration: InputDecoration(
          hintText: searchHintText,
          prefixIcon: Icon(Icons.search, color: appTheme(context, state.userSettings.themeMode).textColor),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  // TODO Use localization for datepicker

  Widget _buildDateDialogButton(final BuildContext context, final UserSettingsState state, final List<AnalyzedGame> games) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ValueListenableBuilder<DateTime?>(
        valueListenable: _selectedDateTimeNotifier,
        builder: (context, DateTime? data, wt) {
          return GestureDetector(
            onTap: () async {
              final firstGameDate = games.map((game) => game.gameInfo.date).reduce((a, b) => a.isBefore(b) ? a : b);
              final lastGameDate = games.map((game) => game.gameInfo.date).reduce((a, b) => a.isAfter(b) ? a : b);

              final DateTime? dateTimeSelected = await showDatePicker(
                context: context,
                cancelText: 'Abbrechen',
                confirmText: 'Auswählen',
                helpText: 'Spieldatum auswählen',
                initialDate: lastGameDate,
                firstDate: firstGameDate,
                lastDate: lastGameDate,
                selectableDayPredicate: (datetime) => games.any((game) => game.gameInfo.date == datetime),
              );
              if (!mounted) {
                return;
              }
              setState(() => _selectedDateTimeNotifier.value = dateTimeSelected);
            },
            child: FormField(
              initialValue: _selectedDateTimeNotifier.value,
              builder: (FormFieldState formState) {
                return InputDecorator(
                  isEmpty: data == null,
                  decoration: (InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.calendar_today, color: appTheme(context, state.userSettings.themeMode).textColor),
                    ),
                    contentPadding: const EdgeInsets.all(25),
                  )).applyDefaults(Theme.of(formState.context).inputDecorationTheme).copyWith(
                      labelText: 'Datum auswählen',
                      hintText: 'Datum auswählen',
                      suffixIcon: data == null
                          ? null
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.clear, color: appTheme(context, state.userSettings.themeMode).textColor),
                                  onPressed: () => setState(() => _selectedDateTimeNotifier.value = null),
                                ),
                              ],
                            ),
                      errorText: formState.errorText),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: Text(data == null ? '' : germanDateTimeFormatShort.format(data))),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrandmasterELOInputFields(final BuildContext context, final UserSettingsState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: FormField(
        builder: (FormFieldState formState) {
          return InputDecorator(
            isEmpty: false,
            decoration: (InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.whatshot, color: appTheme(context, state.userSettings.themeMode).textColor),
              ),
              contentPadding: const EdgeInsets.all(25),
            )).applyDefaults(Theme.of(formState.context).inputDecorationTheme).copyWith(
                  labelText: 'Großmeister ELO einschränken',
                  hintText: 'Großmeister ELO einschränken',
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: RangeSlider(
                        values: _currentGrandmasterELORangeValues,
                        min: 2000,
                        max: 3000,
                        onChanged: (RangeValues values) {
                          setState(() {
                            _currentGrandmasterELORangeValues = values;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_currentGrandmasterELORangeValues.start.toInt().toString()),
                    Text(' - '),
                    Text(_currentGrandmasterELORangeValues.end.toInt().toString()),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOpponentELOInputFields(final BuildContext context, final UserSettingsState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: FormField(
        builder: (FormFieldState formState) {
          return InputDecorator(
            isEmpty: false,
            decoration: (InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.whatshot_outlined, color: appTheme(context, state.userSettings.themeMode).textColor),
              ),
              contentPadding: const EdgeInsets.all(25),
            )).applyDefaults(Theme.of(formState.context).inputDecorationTheme).copyWith(
                  labelText: 'Gegner ELO einschränken',
                  hintText: 'Gegner ELO einschränken',
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: RangeSlider(
                        values: _currentOpponentELORangeValues,
                        min: 2000,
                        max: 3000,
                        onChanged: (RangeValues values) {
                          setState(() {
                            _currentOpponentELORangeValues = values;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_currentOpponentELORangeValues.start.toInt().toString()),
                    Text(' - '),
                    Text(_currentOpponentELORangeValues.end.toInt().toString()),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchButton(final BuildContext context, final UserSettingsState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: () => widget.onSubmitSearch(FilterOptions(
                  selectedOpponent: _selectedOpponent,
                  selectedOpening: _selectedOpening,
                  selectedEvent: _selectedEvent,
                  selectedDate: _selectedDateTimeNotifier.value,
                  selectedGrandmasterELORange: _currentGrandmasterELORangeValues,
                  selectedOpponentELORange: _currentOpponentELORangeValues)),
              icon: Icon(Icons.search),
              label: Text('Spiele suchen'),
              style: TextButton.styleFrom(
                primary: appTheme(context, state.userSettings.themeMode).scaffoldBackgroundColor,
                backgroundColor: appTheme(context, state.userSettings.themeMode).gameModeThemes[widget.gameMode]!.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterOptions {
  String? selectedOpponent;
  String? selectedOpening;
  String? selectedEvent;
  DateTime? selectedDate;
  RangeValues? selectedGrandmasterELORange;
  RangeValues? selectedOpponentELORange;

  FilterOptions(
      {Key? key,
      required this.selectedOpponent,
      required this.selectedOpening,
      required this.selectedEvent,
      required this.selectedDate,
      required this.selectedGrandmasterELORange,
      required this.selectedOpponentELORange});

  bool hasAnyFilter() => hasOpponentFilter() || hasOpeningFilter() || hasEventFilter() || hasDateFilter() || hasGrandmasterELORangeFilter() || hasOpponentELORangeFilter();

  bool hasOpponentFilter() => selectedOpponent != null && selectedOpponent!.isNotEmpty;

  bool hasOpeningFilter() => selectedOpening != null && selectedOpening!.isNotEmpty;

  bool hasEventFilter() => selectedEvent != null && selectedEvent!.isNotEmpty;

  bool hasDateFilter() => selectedDate != null;

  bool hasGrandmasterELORangeFilter() =>
      selectedGrandmasterELORange != null && (selectedGrandmasterELORange!.start != defaultELORangeValues.start || selectedGrandmasterELORange!.end != defaultELORangeValues.end);

  bool hasOpponentELORangeFilter() =>
      selectedOpponentELORange != null && (selectedOpponentELORange!.start != defaultELORangeValues.start || selectedOpponentELORange!.end != defaultELORangeValues.end);

  FilterOptions removeOpponentFilter() {
    return FilterOptions(
        selectedOpponent: null,
        selectedOpening: this.selectedOpening,
        selectedEvent: this.selectedEvent,
        selectedDate: this.selectedDate,
        selectedGrandmasterELORange: this.selectedGrandmasterELORange,
        selectedOpponentELORange: this.selectedOpponentELORange);
  }

  FilterOptions removeOpeningFilter() {
    return FilterOptions(
        selectedOpponent: this.selectedOpponent,
        selectedOpening: null,
        selectedEvent: this.selectedEvent,
        selectedDate: this.selectedDate,
        selectedGrandmasterELORange: this.selectedGrandmasterELORange,
        selectedOpponentELORange: this.selectedOpponentELORange);
  }

  FilterOptions removeEventFilter() {
    return FilterOptions(
        selectedOpponent: this.selectedOpponent,
        selectedOpening: this.selectedOpening,
        selectedEvent: null,
        selectedDate: this.selectedDate,
        selectedGrandmasterELORange: this.selectedGrandmasterELORange,
        selectedOpponentELORange: this.selectedOpponentELORange);
  }

  FilterOptions removeDateFilter() {
    return FilterOptions(
        selectedOpponent: this.selectedOpponent,
        selectedOpening: this.selectedOpening,
        selectedEvent: this.selectedEvent,
        selectedDate: null,
        selectedGrandmasterELORange: this.selectedGrandmasterELORange,
        selectedOpponentELORange: this.selectedOpponentELORange);
  }

  FilterOptions removeGrandmasterELORangeFilter() {
    return FilterOptions(
        selectedOpponent: this.selectedOpponent,
        selectedOpening: this.selectedOpening,
        selectedEvent: this.selectedEvent,
        selectedDate: this.selectedDate,
        selectedGrandmasterELORange: defaultELORangeValues,
        selectedOpponentELORange: this.selectedOpponentELORange);
  }

  FilterOptions removeOpponentELORangeFilter() {
    return FilterOptions(
        selectedOpponent: this.selectedOpponent,
        selectedOpening: this.selectedOpening,
        selectedEvent: this.selectedEvent,
        selectedDate: this.selectedDate,
        selectedGrandmasterELORange: this.selectedGrandmasterELORange,
        selectedOpponentELORange: defaultELORangeValues);
  }
}
