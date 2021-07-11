# Chess Guess The Move Flutter App
This is our Flutter App for our Chess Guess The Move App created as part of our Bachelor Forschungsprojekt INF at University of Stuttgart.

## Creating an analyzed games bundle
Follow the instructions in the ```README.md``` file of the ```Python Game Preprocessing``` program to create a gzipped annotated analysis output file
from a pgn file containing multiple games. To use this gzipped file as an analyzed games bundle, you should copy it to the ```assets/analyzed_games``` directory of this app
and rename it to match the following format:
1. For an analyzed games bundle by grandmaster and year:
```<LAST_NAME>, <FIRST_NAME>_<YEAR>_compressed``` (especially note the space after the comma)

After you have done this, continue with the next section to regenerate the meta file for the app.

## (Re-) Generate meta file for analyzed games bundles and grandmasters
The app uses a generated meta file to get information about which analyzed games bundles and grandmasters
we have included in the bundles given in the ```assets/analyzed_games``` directory. Whenever we add, remove
or change a bundle, we must regenerate this meta file so that the app knows about the changes.
To (re-) generate this meta file, you should use the following command
```dart bin/generate_meta.dart```

## Regenerate usage of open source software file
To regenerate the file containing all used open source software (at least the software directly used by the app), you can run the following command
```flutter pub run flutter_oss_licenses:generate.dart```

## Execute all tests
To execute all tests (BLOC tests and DAO tests) implemented, you should run the following command
```flutter test```

## Execute debug version of the app
To execute a debug version of this app, simply run the following command
```flutter run```
To make the live analysis work, make sure that a local live analysis server is running. See the
README file of the Python preprocessing program for more information on how to run a local live
analysis server.

## Execute release version of the app
To execute a release version of this app that uses our deployed live analysis server, run the following command
```flutter run --release```
and select a device to run on.

## License
This project is licensed under the 3-Clause BSD License. You can find the full license text in the
```LICENSE.md``` file.