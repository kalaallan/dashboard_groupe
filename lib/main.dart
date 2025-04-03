import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Padding(
            padding: EdgeInsets.only(left: 10, top: 30, bottom: 5),
            child: const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
        )
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    SizedBox(
                      width: constraints.maxWidth * 0.5,
                      height: constraints.maxHeight,
                      child: Container( // Pour la carte
                        margin: EdgeInsets.only(top: 30, left: 20),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(3, 169, 244, 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            bottom: BorderSide(
                              color: Color.fromRGBO(3, 169, 244, 1), // Couleur de la bordure
                              width: 1, // Épaisseur de la bordure
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 30, left: 50, right: 50),
                            height: constraints.maxHeight * 0.3,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(3, 169, 244, 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                bottom: BorderSide(
                                  color: Color.fromRGBO(3, 169, 244, 1), // Couleur de la bordure
                                  width: 1, // Épaisseur de la bordure
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 15, left: 50, right: 50),
                            height: constraints.maxHeight * 0.3,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(3, 169, 244, 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                bottom: BorderSide(
                                  color: Color.fromRGBO(3, 169, 244, 1), // Couleur de la bordure
                                  width: 1, // Épaisseur de la bordure
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 15, left: 50, right: 50),
                            height: constraints.maxHeight * 0.3,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(3, 169, 244, 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                bottom: BorderSide(
                                  color: Color.fromRGBO(3, 169, 244, 1), // Couleur de la bordure
                                  width: 1, // Épaisseur de la bordure
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                );
              }
          ),

        ),
      ),
    );
  }
}
