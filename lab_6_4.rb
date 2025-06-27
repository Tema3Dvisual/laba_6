# Функция для перевода числа в двоичную систему
def to_binary(num)
  binary = []
  
  if num == 0
    return [0]
  end
  
  while num > 0
    binary << num % 2 # сохраняем остаток
    num /= 2          # делим число на 2
  end
  
  binary.reverse
end

# Функция для подсчета количества единиц (бананов) через двоичное представление
def count_bananas(num)
  binary = to_binary(num)
  binary.count(1)
end

puts "Введите число: "
n = gets.chomp.to_i

best_pair = [0, n] # Начальная пара (0, N)
max_bananas = count_bananas(0) + count_bananas(n)
max_diff = n # Разность чисел в паре

# Перебираем все возможные пары чисел
(1..(n/2)).each do |a|
  b = n - a
  current_bananas = count_bananas(a) + count_bananas(b)
  
  # Если нашли пару с большим количеством бананов
  # Или такое же количество, но с большей разностью
  if current_bananas > max_bananas || 
     (current_bananas == max_bananas && (b - a) > max_diff)
    max_bananas = current_bananas
    best_pair = [a, b]
    max_diff = b - a
  end
end

# Выводим результат
puts "#{best_pair[0]} #{best_pair[1]}"
