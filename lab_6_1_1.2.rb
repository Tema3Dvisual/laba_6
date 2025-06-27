# Подзадание 1
def task1
  puts "ЗАДАНИЕ 1: Квадратная матрица N×N (N чётное), значения от 100 до 200"
  print "Введите N: "
  n = gets.chomp.to_i

  # Проверка корректности ввода
  if n <= 0 || n % 2 != 0
    puts "Ошибка: N должно быть положительным чётным числом."
    return
  end

  # Создание матрицы из целых чисел
  matrix = Array.new(n) { Array.new(n) }
  srand(Time.now.to_i) # Инициализация генератора текущим временем

  puts "\nМатрица:"
  n.times do |i|
    row_sum = 0 # Переменная для подсчета сумм в строке
    n.times do |j|
      matrix[i][j] = 100 + rand(101) # Случайное число от 100 до 200
      row_sum += matrix[i][j]
      print "%5d" % matrix[i][j] # Выводим число с шириной поля 5 символов
    end
    puts " | Сумма строки: #{row_sum}"
  end

  puts "\nСуммы столбцов:"
  n.times do |j|
    col_sum = 0 # Переменная для элементов столбца
    n.times do |i|
      col_sum += matrix[i][j]
    end
    puts "Столбец #{j + 1}: #{col_sum}"
  end
end

# Подзадание 2
def task2
  puts "\nЗАДАНИЕ 2: Матрица M×N, без цифр 5 и 7 в числах"
  print "Введите M и N: "
  m, n = gets.chomp.split.map(&:to_i)

  if m <= 0 || n <= 0
    puts "Ошибка: размеры должны быть положительными."
    return
  end
  

  # Создание матрицы
  matrix = Array.new(m) { Array.new(n) }
  srand(Time.now.to_i + 1) # Инициализация генератора с другим временем

  # Заполнение матрицы рандомными числами от 1000 до 3000
  m.times do |i|
    n.times do |j|
      matrix[i][j] = 1000 + rand(2001)
    end
  end

  puts "\nМатрица:"
  matrix.each do |row|
    row.each { |val| print "%6d" % val }
    puts
  end

  max_len = 0
  max_row = -1
  max_seq = [] # Для хранения самой длинной последовательности

  # Поиск этой последовательности
  m.times do |i|
    curr_seq = [] # Текущая последовательность
    n.times do |j|
      val = matrix[i][j]
      has5 = false
      has7 = false
      
      # Проверка наличие 5 и 7 в числе val
      tmp = val
      while tmp > 0
        d = tmp % 10 # Последняя цифра
        has5 = true if d == 5
        has7 = true if d == 7
        tmp /= 10 # Отбросили последнюю
      end

      if !has5 && !has7
        curr_seq << val
      else
        if curr_seq.size > max_len
          max_len = curr_seq.size
          max_seq = curr_seq.dup
          max_row = i
        end
        curr_seq.clear
      end
    end

    # После конца строки проверяем последнюю последовательность
    if curr_seq.size > max_len
      max_len = curr_seq.size
      max_seq = curr_seq.dup
      max_row = i
    end
  end

  if !max_seq.empty?
    puts "\nСамая длинная последовательность без 5 и 7 в строке #{max_row + 1}:"
    puts max_seq.join(" ")
  else
    puts "\nНет подходящей последовательности."
  end
end

# Основная программа
task1
puts "\nНажмите Enter, чтобы перейти ко 2 заданию..."
gets

task2
