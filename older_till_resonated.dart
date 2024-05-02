import 'package:flutter/material.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Characteristics',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MovieCharacteristicsScreen(),
    );
  }
}

class MovieCharacteristic {
  final String name;
  final String description;
  bool isSelected;

  MovieCharacteristic({
    required this.name,
    required this.description,
    this.isSelected = false,
  });
}

class MoviePattern {
  final String patternName;
  // Mock data: list of movies and characteristics showing this pattern
  final List<Map<String, String>> details;

  MoviePattern({required this.patternName, required this.details});
}

class MovieCharacteristicsScreen extends StatefulWidget {
  @override
  _MovieCharacteristicsScreenState createState() => _MovieCharacteristicsScreenState();
}

class _MovieCharacteristicsScreenState extends State<MovieCharacteristicsScreen> with TickerProviderStateMixin {
  late TabController _characteristicsTabController;
  final List<String> _moviesList = [];
  final Map<String, dynamic> _movieCharacteristics = {};
  String _selectedMovie = '';
  final TextEditingController _controller = TextEditingController();
  final List<MoviePattern> _patterns = []; // List to hold patterns
  final List<String> _resonatedCharacteristics = []; // List to hold resonated characteristics

  @override
  void initState() {
    super.initState();
    _characteristicsTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _characteristicsTabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void addMovie(String movieName) {
    if (!_moviesList.contains(movieName)) {
      setState(() {
        _moviesList.add(movieName);
        _selectedMovie = movieName;
        _controller.clear();
      });
      fetchCharacteristics(movieName);
    }
  }

  void removeMovie(String movieName) {
    setState(() {
      _moviesList.remove(movieName);
      _movieCharacteristics.remove(movieName);
      if (_selectedMovie == movieName) {
        _selectedMovie = '';
        _characteristicsTabController.index = 0;
      }
    });
  }

  void selectMovie(String movieName) {
    setState(() {
      _selectedMovie = movieName;
    });
  }

  void toggleCharacteristic(String movieName, String category, int index) {
    setState(() {
      var characteristics = _movieCharacteristics[movieName]['characteristics'][category];
      var characteristic = characteristics[index];
      characteristic.isSelected = !characteristic.isSelected;

      if (characteristic.isSelected) {
        _resonatedCharacteristics.add(characteristic.name);
      } else {
        _resonatedCharacteristics.remove(characteristic.name);
      }
    });
  }

  void fetchCharacteristics(String movieName) {
    // Sample JSON response
    String jsonResponse = '''
    {
      "movie_name": "$movieName",
      "protagonist_name": "Dominic Cobb",
      "characteristics": {
        "flaws": [
          {
            "name": "Guilt-ridden",
            "description": "Dominic struggles with deep-seated guilt over his wife's tragic end."
          },
          {
            "name": "Obsessed",
            "description": "His obsession with inception leads him to take extreme risks."
          }
        ],
        "strengths": [
          {
            "name": "Highly Skilled Extractor",
            "description": "Dominic is an exceptionally skilled extractor, able to navigate complex dreamscapes."
          },
          {
            "name": "Creative Problem Solver",
            "description": "He exhibits remarkable creativity in solving problems within the dream world."
          }
        ],
        "desires": [
          {
            "name": "Reunion",
            "description": "He desires to be reunited with his children and to resolve his legal issues."
          },
          {
            "name": "Closure",
            "description": "Dominic yearns for closure regarding his turbulent past with his wife."
          }
        ],
        "beliefs": [
          {
            "name": "Subjective Reality",
            "description": "He holds a firm belief that one's perception shapes their reality, especially within dreams."
          },
          {
            "name": "Power of an Idea",
            "description": "Dominic believes in the transformative power of a single idea to change a person."
          }
        ]
      }
    }
    ''';

    var data = jsonDecode(jsonResponse);

    setState(() {
      _movieCharacteristics[movieName] = {
        'protagonist_name': data['protagonist_name'],
        'characteristics': {
          'Flaws': (data['characteristics']['flaws'] as List).map((item) => MovieCharacteristic(name: item['name'], description: item['description'])).toList(),
          'Strengths': (data['characteristics']['strengths'] as List).map((item) => MovieCharacteristic(name: item['name'], description: item['description'])).toList(),
          'Desires': (data['characteristics']['desires'] as List).map((item) => MovieCharacteristic(name: item['name'], description: item['description'])).toList(),
          'Beliefs': (data['characteristics']['beliefs'] as List).map((item) => MovieCharacteristic(name: item['name'], description: item['description'])).toList(),
        }
      };
    });
  }

  void fetchPatterns() {
    if (_moviesList.length > 1) {
      setState(() {
        _patterns.clear();
        _patterns.add(MoviePattern(patternName: "Common Pattern 1", details: [
          {"movie": "Inception", "characteristic": "Guilt-ridden"},
          // ...more details
        ]));
      });
    } else {
      setState(() {
        _patterns.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Protagonist Characteristics'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Movie Name',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      addMovie(_controller.text);
                    }
                  },
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  addMovie(value);
                }
              },
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: buildMoviesListSection(),
                ),
                VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  flex: 4,
                  child: buildCharacteristicsSection(),
                ),
                VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  flex: 4,
                  child: buildPatternsSection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMoviesListSection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.blueGrey[100],
          width: double.infinity,
          child: Text(
            'Your Movies',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _moviesList.length,
            itemBuilder: (context, index) {
              String movie = _moviesList[index];
              return ListTile(
                title: Text(movie),
                trailing: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => removeMovie(movie),
                ),
                selected: movie == _selectedMovie,
                onTap: () => selectMovie(movie),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildCharacteristicsSection() {
    return Column(
      children: [
        if (_selectedMovie.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              _movieCharacteristics[_selectedMovie]?['protagonist_name'] ?? '',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
        if (_selectedMovie.isNotEmpty)
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _characteristicsTabController,
              tabs: [
                Tab(text: 'Flaws'),
                Tab(text: 'Strengths'),
                Tab(text: 'Desires'),
                Tab(text: 'Beliefs'),
              ],
              indicatorColor: Colors.blue,
              labelColor: Colors.black,
            ),
          ),
        Expanded(
          child: _selectedMovie.isNotEmpty
              ? TabBarView(
            controller: _characteristicsTabController,
            children: [
              buildCharacteristicList(_selectedMovie, 'Flaws'),
              buildCharacteristicList(_selectedMovie, 'Strengths'),
              buildCharacteristicList(_selectedMovie, 'Desires'),
              buildCharacteristicList(_selectedMovie, 'Beliefs'),
            ],
          )
              : Center(child: Text('Select a movie to see characteristics')),
        ),
      ],
    );
  }

  Widget buildCharacteristicList(String movieName, String category) {
    var characteristics = _movieCharacteristics[movieName]?['characteristics'][category] ?? [];
    return ListView.builder(
      itemCount: characteristics.length,
      itemBuilder: (context, index) {
        var characteristic = characteristics[index];
        return CheckboxListTile(
          value: characteristic.isSelected,
          onChanged: (_) => toggleCharacteristic(movieName, category, index),
          title: Text(characteristic.name),
          subtitle: Text(characteristic.description),
        );
      },
    );
  }

  Widget buildPatternsSection() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: fetchPatterns,
            child: Text('Get Patterns'),
          ),
        ),
        TabBar(
          controller: _characteristicsTabController,
          tabs: [
            Tab(text: 'Flaws'),
            Tab(text: 'Strengths'),
            Tab(text: 'Desires'),
            Tab(text: 'Beliefs'),
          ],
        ),
        Expanded(
          child: _moviesList.length > 1
              ? TabBarView(
            controller: _characteristicsTabController,
            children: [
              buildPatternList('Flaws'),
              buildPatternList('Strengths'),
              buildPatternList('Desires'),
              buildPatternList('Beliefs'),
            ],
          )
              : Center(child: Text('Add more movies to see patterns')),
        ),
        SizedBox(height: 20), // Add some space between Patterns and Resonated sections
        Text(
          'Resonated', // Header for Resonated section
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: SingleChildScrollView( // Wrap the resonated list with SingleChildScrollView
            child: buildResonatedList(), // Show Resonated list
          ),
        ),
      ],
    );
  }

  Widget buildPatternList(String characteristic) {
    return ListView.builder(
      itemCount: _patterns.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_patterns[index].patternName),
          onTap: () {
            print(_patterns[index].patternName);
          },
        );
      },
    );
  }

  Widget buildResonatedList() {
    return ListView.builder(
      shrinkWrap: true, // Add shrinkWrap to the ListView
      itemCount: _resonatedCharacteristics.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_resonatedCharacteristics[index]),
        );
      },
    );
  }
}
