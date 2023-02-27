require 'json'
require 'rspec'

# require_relative 'main'
require_relative 'teacher'

describe Teacher do
  describe '#create_quiz' do
    let(:teacher) { Teacher.new('Ali') }

    context 'when creating a new quiz with valid inputs' do
      let(:quiz_name) { 'Test Quiz' }
      let(:questions) do
 [{ question: 'What is 1+1?', answer: '2' },
  { question: 'What is the capital of France?', answer: 'Paris' }]
      end

      before do
        allow_any_instance_of(Kernel).to receive(:gets).and_return(quiz_name,
                                                                   questions[0][:question], questions[0][:answer], questions[1][:question], questions[1][:answer], 'done')
        teacher.create_quiz
      end

      it 'adds the quiz to quizzes.json file' do
        quizzes = File.foreach('quizzes.json').map { |line| JSON.parse(line) }
        expect(quizzes.last['name']).to eq(quiz_name)
        # expect(quizzes.last['questions']).to eq(questions)
        expect(quizzes.last['published']).to be false
        expect(quizzes.last['locked']).to be false
        expect(quizzes.last['start_time']).to be nil
        expect(quizzes.last['end_time']).to be nil
      end

      it 'prints the success message' do
        expect { teacher.create_quiz }.to output(/Quiz '#{quiz_name}' created./).to_stdout
      end
    end

    context 'when attempting to create a quiz with an existing name' do
      let(:quiz_name) { 'Existing Quiz' }
      let(:questions) { [] }

      before do
        quizzes = [{ 'name' => quiz_name, 'questions' => [], 'published' => false,
                     'locked' => false, 'start_time' => nil, 'end_time' => nil }]
        File.open('quizzes.json', 'w') do |file|
          quizzes.each do |quiz|
            file.write("#{JSON.dump(quiz)}\n")
          end
        end
        allow_any_instance_of(Kernel).to receive(:gets).and_return(quiz_name, 'done')
      end

      it 'does not add the quiz to quizzes.json file' do
        expect { teacher.create_quiz }.not_to change { File.foreach('quizzes.json').count }
      end

      it 'prints an error message' do
        expect do
          teacher.create_quiz
        end.to output(/Error: Quiz '#{quiz_name}' already exists./).to_stdout
      end
    end
  end
end
