require 'json'

class UserManager
  def initialize(user_file)
    @user_file = user_file
    @users = load_users
  end

  def signup(role)
    puts "Please enter your name:"
    name = gets.chomp.strip

    puts "Please enter a username:"
    username = gets.chomp.strip.downcase

    while @users.any? { |user| user[:username] == username }
      puts "That username is already taken. Please choose another one:"
      username = gets.chomp.strip.downcase
    end

    puts "Please enter a password:"
    password = gets.chomp.strip

    puts "Please enter your email address:"
    email = gets.chomp.strip

    @users << { name: name, username: username, password: password, email: email, role: role }
    save_users

    puts "Signup successful!"
  end

  def login(role)
    puts "Please enter your username:"
    username = gets.chomp.strip.downcase

    puts "Please enter your password:"
    password = gets.chomp.strip

    user = @users.find do |user|
   user[:username] == username && user[:password] == password && user[:role] == role
    end

    if user.nil?
      puts "Invalid username or password. Please try again."
      return
    end

    puts "Login successful! Welcome, #{user[:name]} (#{user[:email]})."
  end

  private

  def load_users
    if File.exist?(@user_file)
      JSON.parse(File.read(@user_file), symbolize_names: true)
    else
      []
    end
  end

  def save_users
    File.write(@user_file, JSON.generate(@users))
  end
end

user_manager = UserManager.new('users.json')

loop do
  puts "Welcome to the quiz system! Please choose an option:"
  puts "1. Signup as teacher"
  puts "2. Signup as student"
  puts "3. Login as teacher"
  puts "4. Login as student"
  puts "5. Exit"

  # choice = gets.chomp.to_i
  choice = gets&.chomp&.to_i

  case choice
  when 1
    user_manager.signup('teacher')
  when 2
    user_manager.signup('student')
  when 3
    user_manager.login('teacher')
  when 4
    user_manager.login('student')
  when 5
    puts "Goodbye!"
    break
  else
    puts "Invalid choice. Please try again."
  end
end
