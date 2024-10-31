import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reproduction_amana/add_movie_page.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Firebase'),
        leading: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context){
                    return const AddPage();
                  },
                fullscreenDialog: true, // Ouvrir la page sous forme de modal
              ),
              );
            },
        ),
      ),
      body: const MoviesInformation(),
    );
  }
}

class MoviesInformation extends StatefulWidget {
  const MoviesInformation({super.key});

  @override
  State<MoviesInformation> createState() => _MoviesInformationState();
}

class _MoviesInformationState extends State<MoviesInformation> {
  final Stream<QuerySnapshot> _moviesStream = FirebaseFirestore.instance.collection('Movies').snapshots();

  void addLike(String docId, int likes){
    var newLikes = likes + 1;
    try {
      FirebaseFirestore.instance.collection('Movies').doc(docId).update({
        'likes': newLikes,
      }).then((value) => print('Données à jour'));

    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _moviesStream, // Utilisez simplement StreamBuilder pour récupérer les données
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text('Loading'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No movies found"));
        }

        // Si les données sont disponibles, affichez-les dans une ListView
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> movie = document.data()! as Map<String, dynamic>;

            String? posterUrl = movie['poster'];

            // Vérifier si l'URL est valide
            if (posterUrl == null || posterUrl.isEmpty) {
              posterUrl = 'https://example.com/default-image.png'; // Image par défaut si aucune URL n'est disponible
            }

            return Padding(
                padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  SizedBox(
                    width: 115,
                    child: Image.network(movie['poster']),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const Text('Année de production'),
                        Text(movie['year'].toString()),
                        Row(
                          children: [
                            for( final categories in movie['categories'])
                              Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Chip(
                                    label: Text(categories),
                                    backgroundColor: Colors.blueGrey,
                                  ),
                              )
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 20,
                                onPressed: () {
                                  addLike(document.id, movie['likes']);
                                },
                                icon: const Icon(Icons.favorite)
                            ),
                            Text(movie['likes'].toString())
                          ],
                        )
                      ],
                    ),

                  ),
                ],
              ),
            );
          }).toList(),
        );

      },
    );
  }
}
