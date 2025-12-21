// State management
let currentQuiz = null;
let quizzes = [];

// DOM Elements
const quizListView = document.getElementById('quiz-list-view');
const quizView = document.getElementById('quiz-view');
const resultsView = document.getElementById('results-view');
const quizList = document.getElementById('quiz-list');
const quizTitle = document.getElementById('quiz-title');
const quizDescription = document.getElementById('quiz-description');
const questionsContainer = document.getElementById('questions-container');
const submitButton = document.getElementById('submit-quiz');
const backToListButton = document.getElementById('back-to-list');
const backToListResultsButton = document.getElementById('back-to-list-results');
const scoreDisplay = document.getElementById('score-display');
const detailedResults = document.getElementById('detailed-results');

// Initialize app
async function init() {
    await loadQuizzes();
    setupEventListeners();
}

// Setup event listeners
function setupEventListeners() {
    submitButton.addEventListener('click', submitQuiz);
    backToListButton.addEventListener('click', showQuizList);
    backToListResultsButton.addEventListener('click', showQuizList);
}

// Load all quizzes
async function loadQuizzes() {
    try {
        const response = await fetch('/api/quizzes');
        quizzes = await response.json();
        displayQuizzes();
    } catch (error) {
        console.error('Error loading quizzes:', error);
        quizList.innerHTML = '<p>Error loading quizzes. Please try again later.</p>';
    }
}

// Display quiz list
function displayQuizzes() {
    quizList.innerHTML = '';
    quizzes.forEach(quiz => {
        const quizCard = document.createElement('div');
        quizCard.className = 'quiz-card';
        quizCard.innerHTML = `
            <h3>${quiz.title}</h3>
            <p>${quiz.description}</p>
            <div class="quiz-info">📝 ${quiz.questionCount} questions</div>
        `;
        quizCard.addEventListener('click', () => loadQuiz(quiz.id));
        quizList.appendChild(quizCard);
    });
}

// Load a specific quiz
async function loadQuiz(quizId) {
    try {
        const response = await fetch(`/api/quizzes/${quizId}`);
        currentQuiz = await response.json();
        displayQuiz();
        showView('quiz-view');
    } catch (error) {
        console.error('Error loading quiz:', error);
        alert('Error loading quiz. Please try again.');
    }
}

// Display quiz questions
function displayQuiz() {
    quizTitle.textContent = currentQuiz.title;
    quizDescription.textContent = currentQuiz.description;
    questionsContainer.innerHTML = '';

    currentQuiz.questions.forEach((question, questionIndex) => {
        const questionDiv = document.createElement('div');
        questionDiv.className = 'question';
        
        const questionHTML = `
            <h3>Question ${questionIndex + 1}</h3>
            <p>${question.question}</p>
            <div class="options">
                ${question.options.map((option, optionIndex) => `
                    <div class="option">
                        <input type="radio" 
                               id="q${questionIndex}-o${optionIndex}" 
                               name="question-${questionIndex}" 
                               value="${optionIndex}">
                        <label for="q${questionIndex}-o${optionIndex}">${option}</label>
                    </div>
                `).join('')}
            </div>
        `;
        
        questionDiv.innerHTML = questionHTML;
        questionsContainer.appendChild(questionDiv);
    });
}

// Submit quiz answers
async function submitQuiz() {
    const answers = [];
    let allAnswered = true;

    // Collect answers
    currentQuiz.questions.forEach((question, index) => {
        const selected = document.querySelector(`input[name="question-${index}"]:checked`);
        if (selected) {
            answers.push(parseInt(selected.value));
        } else {
            answers.push(null);
            allAnswered = false;
        }
    });

    if (!allAnswered) {
        alert('Please answer all questions before submitting.');
        return;
    }

    try {
        const response = await fetch(`/api/quizzes/${currentQuiz.id}/submit`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ answers })
        });

        const results = await response.json();
        displayResults(results);
        showView('results-view');
    } catch (error) {
        console.error('Error submitting quiz:', error);
        alert('Error submitting quiz. Please try again.');
    }
}

// Display results
function displayResults(results) {
    // Display score
    scoreDisplay.innerHTML = `
        <h3>${results.score}%</h3>
        <p>You got ${results.correctCount} out of ${results.totalQuestions} questions correct!</p>
    `;

    // Display detailed results
    detailedResults.innerHTML = '<h3>Detailed Results:</h3>';
    results.results.forEach((result, index) => {
        const resultDiv = document.createElement('div');
        resultDiv.className = `result-item ${result.isCorrect ? 'correct' : 'incorrect'}`;
        
        resultDiv.innerHTML = `
            <span class="result-label ${result.isCorrect ? 'correct' : 'incorrect'}">
                ${result.isCorrect ? '✓ Correct' : '✗ Incorrect'}
            </span>
            <h4>Question ${index + 1}: ${result.question}</h4>
            ${!result.isCorrect ? `
                <p><strong>Your answer:</strong> ${currentQuiz.questions[index].options[result.userAnswer]}</p>
                <p><strong>Correct answer:</strong> ${currentQuiz.questions[index].options[result.correctAnswer]}</p>
            ` : `
                <p><strong>Your answer:</strong> ${currentQuiz.questions[index].options[result.userAnswer]} ✓</p>
            `}
        `;
        
        detailedResults.appendChild(resultDiv);
    });
}

// Show specific view
function showView(viewId) {
    document.querySelectorAll('.view').forEach(view => {
        view.classList.remove('active');
    });
    document.getElementById(viewId).classList.add('active');
}

// Show quiz list
function showQuizList() {
    currentQuiz = null;
    showView('quiz-list-view');
}

// Start the app
init();
