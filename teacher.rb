require 'json'
require_relative 'user'

class Teacher < UserManager
   @attempts = []

   def create_quiz
       puts "Enter the quiz name:"
       quiz_name = gets.chomp
       questions = []
       loop do
         puts "Enter a question (or type 'done' to finish):"
         question = gets.chomp
         break if question == 'done'

         puts "Enter the answer:"
         answer = gets.chomp
         questions << { question: question, answer: answer }
       end

       quiz = { name: quiz_name, questions: questions, published: false, locked: false,
                start_time: nil, end_time: nil }
       File.open('quizzes.json', 'a') { |file| file.write("#{JSON.dump(quiz)}\n") }
       puts "Quiz '#{quiz_name}' created."
   end

   def edit_quiz
     puts "Enter the name of the quiz to edit:"
     quiz_name = gets.chomp

     quizzes = File.foreach('quizzes.json').map { |line| JSON.parse(line) }
     quiz = quizzes.find { |q| q['name'] == quiz_name }

     if quiz.nil?
       puts "Error: Quiz '#{quiz_name}' not found."
       return
     end

     loop do
       puts "Enter '1' to change the quiz name, '2' to edit a question, '3' to add a question, or 'done' to finish:"
       choice = gets.chomp
       case choice
       when '1'
         puts "Enter the new quiz name:"
         new_quiz_name = gets.chomp
         quiz['name'] = new_quiz_name
         puts "Quiz name changed to '#{new_quiz_name}'."
       when '2'
         puts "Enter the index of the question to edit (starting from 1):"
         index = gets.chomp.to_i - 1
         if index.negative? || index >= quiz['questions'].length
           puts "Error: Invalid index."
           next
         end
         puts "Enter the new question:"
         new_question = gets.chomp
         puts "Enter the new answer:"
         new_answer = gets.chomp
         quiz['questions'][index]['question'] = new_question
         quiz['questions'][index]['answer'] = new_answer
         puts "Question #{index + 1} updated."
       when '3'
         puts "Enter a new question:"
         new_question = gets.chomp
         puts "Enter the answer:"
         new_answer = gets.chomp
         quiz['questions'] << { question: new_question, answer: new_answer }
         puts "Question added."
       when 'done'
         break
       else
         puts "Error: Invalid choice."
       end
     end

     File.write('quizzes.json', quizzes.map { |q| "#{JSON.dump(q)}\n" }.join)
     puts "Quiz '#{quiz_name}' updated."
   end

   def view_attempts
     puts "Enter the name of the quiz you want to view attempts for:"
     quiz_name = gets.chomp

     if @attempts.nil?
       puts "There are no attempts for any quizzes."
     else
       quiz_attempts = @attempts.select { |attempt| attempt[:quiz_name] == quiz_name }
       if quiz_attempts.empty?
         puts "No attempts found for quiz '#{quiz_name}'."
       else
         puts "Attempts for quiz '#{quiz_name}':"
         quiz_attempts.each do |attempt|
           puts "Attempt #{attempt[:attempt_number]}: #{attempt[:score]} points"
         end
       end
     end
   end
end

teacher = Teacher.new('jhon')
loop do
  puts "Welcome to the teacher menu:"
  puts "1. Create Quiz"
  puts "2. Edit Quiz"
  puts "3. view attempts"
  puts "4. exit"

  # choice = gets.chomp.to_i
  choice = gets&.chomp&.to_i

  case choice
  when 1
    teacher.create_quiz
  when 2
    teacher.edit_quiz
  when 3
    teacher.view_attempts
  when 4
     puts "Goodbye!"

     break
  else
     puts "Invalid choice. Please try again."
  end
end


