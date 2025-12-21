# Quiz App Platform

A modern, interactive web-based quiz application platform built with Node.js and Express.

## Features

- 📚 Multiple quiz categories (JavaScript, Web Development, General Knowledge)
- 🎨 Beautiful, responsive UI with gradient design
- ✅ Interactive quiz-taking experience
- 📊 Instant results with detailed feedback
- 🔄 Easy navigation between quizzes
- 💯 Score calculation and performance tracking

## Tech Stack

- **Backend**: Node.js, Express.js
- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Architecture**: RESTful API

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd quiz_apps
```

2. Install dependencies:
```bash
npm install
```

3. Start the server:
```bash
npm start
```

4. Open your browser and navigate to:
```
http://localhost:3000
```

## API Endpoints

### Get All Quizzes
```
GET /api/quizzes
```
Returns a list of all available quizzes with basic information.

**Response:**
```json
[
  {
    "id": 1,
    "title": "JavaScript Fundamentals",
    "description": "Test your knowledge of JavaScript basics",
    "questionCount": 3
  }
]
```

### Get Quiz by ID
```
GET /api/quizzes/:id
```
Returns a specific quiz with all questions (without correct answers).

**Response:**
```json
{
  "id": 1,
  "title": "JavaScript Fundamentals",
  "description": "Test your knowledge of JavaScript basics",
  "questions": [
    {
      "id": 1,
      "question": "What is the correct way to declare a variable in JavaScript?",
      "options": ["var x = 5;", "variable x = 5;", "v x = 5;", "dim x = 5;"]
    }
  ]
}
```

### Submit Quiz Answers
```
POST /api/quizzes/:id/submit
```
Submit answers for a quiz and receive results.

**Request Body:**
```json
{
  "answers": [0, 2, 1]
}
```

**Response:**
```json
{
  "score": 67,
  "correctCount": 2,
  "totalQuestions": 3,
  "results": [
    {
      "questionId": 1,
      "question": "What is the correct way to declare a variable in JavaScript?",
      "userAnswer": 0,
      "correctAnswer": 0,
      "isCorrect": true
    }
  ]
}
```

## Project Structure

```
quiz_apps/
├── server.js           # Express server and API routes
├── package.json        # Project dependencies
├── public/
│   ├── index.html     # Main HTML file
│   ├── style.css      # Styling
│   └── app.js         # Frontend JavaScript
└── README.md          # This file
```

## Usage

1. **Browse Quizzes**: The home page displays all available quizzes
2. **Take a Quiz**: Click on any quiz card to start
3. **Answer Questions**: Select one answer for each question
4. **Submit**: Click "Submit Quiz" when finished
5. **View Results**: See your score and detailed feedback for each question
6. **Return**: Navigate back to browse more quizzes

## Screenshots

### Quiz List
![Quiz List](https://github.com/user-attachments/assets/be62073b-84ee-41b0-9e4a-5b20985699be)

### Taking a Quiz
![Quiz Taking](https://github.com/user-attachments/assets/b6fe2a3a-56d5-450a-80d9-8db6a1911411)

### Quiz Results
![Quiz Results](https://github.com/user-attachments/assets/9c4449c1-b902-46cf-b268-f62356b154d7)

## Contributing

Feel free to submit issues and enhancement requests!

## License

MIT
