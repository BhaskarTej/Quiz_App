import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:google_fonts/google_fonts.dart';

class QuizScreen extends StatefulWidget {
  final int numQuestions;
  final String? category;
  final String difficulty;
  final String type;

  const QuizScreen({
    required this.numQuestions,
    required this.category,
    required this.difficulty,
    required this.type,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _isAnswered = false;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  String decodeHtml(String htmlString) {
    return html_parser.parse(htmlString).body?.text ?? htmlString;
  }

  Future<void> _fetchQuestions() async {
    final url = Uri.parse(
        'https://opentdb.com/api.php?amount=${widget.numQuestions}&category=${widget.category}&difficulty=${widget.difficulty}&type=${widget.type}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _questions = data['results'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching questions: $e')),
      );
    }
  }

  void _submitAnswer(String selectedAnswer) {
    final correctAnswer = _questions[_currentQuestionIndex]['correct_answer'];
    setState(() {
      _isAnswered = true;
      if (selectedAnswer == correctAnswer) {
        _feedback = 'Correct!';
        _score++;
      } else {
        _feedback = 'Incorrect. Correct answer: $correctAnswer';
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _isAnswered = false;
      _feedback = null;
      _currentQuestionIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.purple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _currentQuestionIndex >= _questions.length
                ? _buildQuizComplete()
                : _buildQuizContent(),
      ),
    );
  }

  Widget _buildQuizComplete() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Quiz Complete!',
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Your score: $_score/${_questions.length}',
            style: GoogleFonts.roboto(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Return to Main Screen'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    final question = _questions[_currentQuestionIndex];
    final questionText = decodeHtml(question['question']);
    final options = [
      ...question['incorrect_answers'].map((answer) => decodeHtml(answer)),
      decodeHtml(question['correct_answer'])
    ]..shuffle();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            'Question ${_currentQuestionIndex + 1}/${_questions.length}',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            questionText,
            style: GoogleFonts.roboto(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 30),
          ...options.map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAnswered ? Colors.grey : Colors.white,
                  foregroundColor: Colors.blue.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _isAnswered ? null : () => _submitAnswer(option),
                child: Text(option),
              ),
            );
          }).toList(),
          if (_isAnswered) ...[
            SizedBox(height: 20),
            Text(
              _feedback!,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _feedback == 'Correct!' ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _nextQuestion,
              child: Text('Next Question'),
            ),
          ],
        ],
      ),
    );
  }
}