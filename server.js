const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static('public'));

// Sample quiz data
const quizzes = [
  {
    id: 1,
    title: "JavaScript Fundamentals",
    description: "Test your knowledge of JavaScript basics",
    questions: [
      {
        id: 1,
        question: "What is the correct way to declare a variable in JavaScript?",
        options: ["var x = 5;", "variable x = 5;", "v x = 5;", "dim x = 5;"],
        correctAnswer: 0
      },
      {
        id: 2,
        question: "Which of the following is NOT a JavaScript data type?",
        options: ["String", "Boolean", "Float", "Undefined"],
        correctAnswer: 2
      },
      {
        id: 3,
        question: "What does '===' operator do in JavaScript?",
        options: ["Assigns a value", "Compares value only", "Compares value and type", "Checks for null"],
        correctAnswer: 2
      }
    ]
  },
  {
    id: 2,
    title: "Web Development Basics",
    description: "Test your understanding of web development concepts",
    questions: [
      {
        id: 1,
        question: "What does HTML stand for?",
        options: ["Hyper Text Markup Language", "High Tech Modern Language", "Home Tool Markup Language", "Hyperlinks and Text Markup Language"],
        correctAnswer: 0
      },
      {
        id: 2,
        question: "Which CSS property is used to change text color?",
        options: ["text-color", "color", "font-color", "text-style"],
        correctAnswer: 1
      },
      {
        id: 3,
        question: "What is the purpose of the <head> tag in HTML?",
        options: ["Display main content", "Contains metadata", "Create headers", "Define navigation"],
        correctAnswer: 1
      }
    ]
  },
  {
    id: 3,
    title: "General Knowledge",
    description: "Test your general knowledge",
    questions: [
      {
        id: 1,
        question: "What is the capital of France?",
        options: ["London", "Berlin", "Paris", "Madrid"],
        correctAnswer: 2
      },
      {
        id: 2,
        question: "Which planet is known as the Red Planet?",
        options: ["Venus", "Mars", "Jupiter", "Saturn"],
        correctAnswer: 1
      },
      {
        id: 3,
        question: "Who wrote 'Romeo and Juliet'?",
        options: ["Charles Dickens", "William Shakespeare", "Jane Austen", "Mark Twain"],
        correctAnswer: 1
      }
    ]
  }
];

// API Routes
// Get all quizzes (list view)
app.get('/api/quizzes', (req, res) => {
  const quizList = quizzes.map(quiz => ({
    id: quiz.id,
    title: quiz.title,
    description: quiz.description,
    questionCount: quiz.questions.length
  }));
  res.json(quizList);
});

// Get a specific quiz
app.get('/api/quizzes/:id', (req, res) => {
  const quizId = parseInt(req.params.id);
  const quiz = quizzes.find(q => q.id === quizId);
  
  if (quiz) {
    // Return quiz without correct answers
    const quizData = {
      id: quiz.id,
      title: quiz.title,
      description: quiz.description,
      questions: quiz.questions.map(q => ({
        id: q.id,
        question: q.question,
        options: q.options
      }))
    };
    res.json(quizData);
  } else {
    res.status(404).json({ error: 'Quiz not found' });
  }
});

// Submit quiz answers
app.post('/api/quizzes/:id/submit', (req, res) => {
  const quizId = parseInt(req.params.id);
  const quiz = quizzes.find(q => q.id === quizId);
  
  if (!quiz) {
    return res.status(404).json({ error: 'Quiz not found' });
  }
  
  const userAnswers = req.body.answers;
  
  if (!userAnswers || !Array.isArray(userAnswers)) {
    return res.status(400).json({ error: 'Invalid answers format' });
  }
  
  if (userAnswers.length !== quiz.questions.length) {
    return res.status(400).json({ error: 'Answer count does not match question count' });
  }
  
  for (let i = 0; i < userAnswers.length; i++) {
    const answer = userAnswers[i];
    if (typeof answer !== 'number' || answer < 0 || answer >= quiz.questions[i].options.length) {
      return res.status(400).json({ error: `Invalid answer value at index ${i}` });
    }
  }
  
  let correctCount = 0;
  const results = quiz.questions.map((question, index) => {
    const userAnswer = userAnswers[index];
    const isCorrect = userAnswer === question.correctAnswer;
    if (isCorrect) correctCount++;
    
    return {
      questionId: question.id,
      question: question.question,
      userAnswer: userAnswer,
      correctAnswer: question.correctAnswer,
      isCorrect: isCorrect
    };
  });
  
  const score = Math.round((correctCount / quiz.questions.length) * 100);
  
  res.json({
    score: score,
    correctCount: correctCount,
    totalQuestions: quiz.questions.length,
    results: results
  });
});

// Serve main page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Quiz app platform running on http://localhost:${PORT}`);
});
