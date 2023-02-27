# class Student
require 'json'
require_relative 'user'

class Student < UserManager
  def attempt_quiz
    puts "Enter the name of the quiz to attempt:"
    quiz_name = gets.chomp

    quizzes = File.foreach('quizzes.json').map { |line| JSON.parse(line) }
    quiz = quizzes.find { |q| q['name'] == quiz_name }

    if quiz.nil?
      puts "Error: Quiz '#{quiz_name}' not found."
      return
    end

    score = 0
    quiz['questions'].each_with_index do |q, i|
      puts "Question #{i + 1}: #{q['question']}"
      answer = gets.chomp
      if answer == q['answer']
        score += 1
        puts "Correct!"
      else
        puts "Incorrect."
      end
    end

    attempt = { quiz_name: quiz_name, student_name: @username, score: score }
    File.open('attempts.json', 'a') { |file| file.write("#{JSON.dump(attempt)}\n") }
    puts "Quiz '#{quiz_name}' attempted. Score: #{score}/#{quiz['questions'].length}."
  end

  def view_attempts
    attempts = File.foreach('attempts.json').map { |line| JSON.parse(line) }
    student_attempts = attempts.select { |a| a['student_name'] == @username }

    if student_attempts.empty?
      puts "No attempts found for student '#{@username}'."
    else
      puts "Attempts for student '#{@username}':"
      student_attempts.each do |attempt|
        puts "  Quiz name: #{attempt['quiz_name']}, Score: #{attempt['score']}"
      end
    end
  end

  def view_quizzes_on_date
    puts "Enter the date to view quizzes on (YYYY-MM-DD):"
    date = gets.chomp

    quizzes = File.foreach('quizzes.json').map { |line| JSON.parse(line) }
    quizzes_on_date = quizzes.select { |q| q['start_time']&.start_with?(date) }

    if quizzes_on_date.empty?
      puts "No quizzes found on #{date}."
    else
      puts "Quizzes on #{date}:"
      quizzes_on_date.each do |quiz|
        puts "  Quiz name: #{quiz['name']}"
      end
    end
  end
end

student = Student.new('jhon')
loop do
    puts "Welcome to the student menu:"
    puts "1. Attempt Quiz"
    puts "2. View Attempt"
    puts "3. View Quizzes on Date"
    puts "4. exit"

    # choice = gets.chomp.to_i
    choice = gets&.chomp&.to_i

    case choice
    when 1
      student.attempt_quiz
    when 2

      student.view_attempts
    when 3
      student.view_quizzes_on_date
    when 4
       puts "Goodbye!"

       break
    else
       puts "Invalid choice. Please try again."
    end
end

# student.attempt_quiz

# student.view_attempts
# student.view_quizzes_on_date
