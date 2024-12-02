import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'quiz_screen.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _numQuestions = 5;
  String? _selectedCategory;
  String _selectedDifficulty = 'easy';
  String _selectedType = 'multiple';
  List<Map<String, String>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    try {
      final categories = await ApiService.fetchCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customize Your Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Number of Questions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _numQuestions.toDouble(),
                    min: 5,
                    max: 15,
                    divisions: 2,
                    label: '$_numQuestions',
                    onChanged: (value) {
                      setState(() {
                        _numQuestions = value.toInt();
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Select Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    hint: Text('Choose a category'),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category['id'],
                        child: Text(category['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Select Difficulty',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedDifficulty,
                    items: ['easy', 'medium', 'hard'].map((difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDifficulty = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Select Question Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedType,
                    items: ['multiple', 'boolean'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type == 'multiple' ? 'Multiple Choice' : 'True/False'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select a category')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            numQuestions: _numQuestions,
                            category: _selectedCategory,
                            difficulty: _selectedDifficulty,
                            type: _selectedType,
                          ),
                        ),
                      );
                    },
                    child: Text('Start Quiz'),
                  ),
                ],
              ),
      ),
    );
  }
}