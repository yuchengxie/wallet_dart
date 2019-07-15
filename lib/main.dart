import 'package:flutter/material.dart';
import 'package:nbc_wallet/api/provider/stateModel.dart';
import 'package:nbc_wallet/pages/tabs.dart';
import 'route.dart';
import 'package:provider/provider.dart';

main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return MultiProvider(
    //   providers: [
    //     // Provider<>
    //   ],
    //   child: MaterialApp(
    //     home: Tab(),
    //     initialRoute: '/',
    //     // onGenerateRoute: onGenerateRoute,
    //   ),
    // );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (_) => StateModel()),
      ],
      child: Consumer<StateModel>(
        builder: (context, stateModel, _) {
          return MaterialApp(
            supportedLocales: const [Locale('en')],
            home: Tabs(),
            initialRoute: '/blue',
            onGenerateRoute: onGenerateRoute,
            theme: ThemeData(
              brightness: stateModel.walletTheme.brightness,
              appBarTheme: AppBarTheme(
                  // color: stateModel.walletTheme.appBarbackColor,
                  color: stateModel.walletTheme.brightness == Brightness.dark
                      ? Colors.black12
                      : Colors.cyan),
            ),
          );
        },
      ),
    );
  }
}
