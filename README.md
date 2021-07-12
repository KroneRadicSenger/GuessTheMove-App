# Chess Guess The Move Flutter App
This is our Flutter App for our Chess Guess The Move App created as part of our Bachelor Forschungsprojekt INF at University of Stuttgart.

## Creating an analyzed games bundle
Follow the instructions in the ```README.md``` file of the ```Python Game Preprocessing``` program to create a gzipped annotated analysis output file
from a pgn file containing multiple games. To use this gzipped file as an analyzed games bundle, you should copy it to the ```assets/analyzed_games``` directory of this app
and rename it to match the following format:
1. For an analyzed games bundle by grandmaster and year:
```<LAST_NAME>, <FIRST_NAME>_<YEAR>_compressed``` (especially note the space after the comma)

Your files should look like this:

<img width="336" alt="Bildschirmfoto 2021-07-12 um 08 40 07" src="https://user-images.githubusercontent.com/44426503/125242318-d1814000-e2ec-11eb-9723-2fc5eec6ddea.png">

After you have done this, continue with the next section to regenerate the meta file for the app.

## (Re-) Generate meta file for analyzed games bundles and grandmasters
The app uses a generated meta file to get information about which analyzed games bundles and grandmasters
we have included in the bundles given in the ```assets/analyzed_games``` directory. Whenever we add, remove
or change a bundle, we must regenerate this meta file so that the app knows about the changes.
To (re-) generate this meta file, you should use the following command
```dart bin/generate_meta.dart```

Example output:

<img width="790" alt="Bildschirmfoto 2021-07-12 um 08 39 06" src="https://user-images.githubusercontent.com/44426503/125243105-ec07e900-e2ed-11eb-9f92-cf07f6dc03d4.png">

```json
{
   "grandmasters":[
      {
         "fullName":"Kasparov, Garry",
         "latestEloRating":"2812"
      },
      {
         "fullName":"Fischer, Bobby",
         "latestEloRating":"2560"
      },
      {
         "fullName":"Carlsen, Magnus",
         "latestEloRating":"2862"
      }
   ],
   "analyzedGamesBundles":[
      {
         "type":"byGrandmasterAndYear",
         "grandmaster":{
            "fullName":"Kasparov, Garry",
            "latestEloRating":"-"
         },
         "year":2016
      },
      {
         "type":"byGrandmasterAndYear",
         "grandmaster":{
            "fullName":"Fischer, Bobby",
            "latestEloRating":"-"
         },
         "year":1992
      },
      {
         "type":"byGrandmasterAndYear",
         "grandmaster":{
            "fullName":"Carlsen, Magnus",
            "latestEloRating":"-"
         },
         "year":2020
      },
      {
         "type":"byGrandmasterAndYear",
         "grandmaster":{
            "fullName":"Carlsen, Magnus",
            "latestEloRating":"-"
         },
         "year":2001
      },
      {
         "type":"byGrandmasterAndYear",
         "grandmaster":{
            "fullName":"Kasparov, Garry",
            "latestEloRating":"-"
         },
         "year":2017
      }
   ],
   "gamesAmountByAnalyzedGamesBundleId":{
      "byGrandmasterAndYear_Kasparov, Garry_2016":23,
      "byGrandmasterAndYear_Fischer, Bobby_1992":11,
      "byGrandmasterAndYear_Carlsen, Magnus_2020":269,
      "byGrandmasterAndYear_Carlsen, Magnus_2001":13,
      "byGrandmasterAndYear_Kasparov, Garry_2017":5
   }
}
```

## Regenerate usage of open source software file
To regenerate the file containing all used open source software (at least the software directly used by the app), you can run the following command
```flutter pub run flutter_oss_licenses:generate.dart```

The generated file should look like this:

<img width="767" alt="Bildschirmfoto 2021-07-12 um 08 43 36" src="https://user-images.githubusercontent.com/44426503/125242669-4c4a5b00-e2ed-11eb-9260-4736e83be79d.png">

## Execute all tests
To execute all tests (BLOC tests and DAO tests) implemented, you should run the following command
```flutter test```

<img width="981" alt="Bildschirmfoto 2021-07-12 um 08 44 50" src="https://user-images.githubusercontent.com/44426503/125242991-be22a480-e2ed-11eb-994e-3741e985c9b5.png">

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
