# Проверка диагонального преобладания
def has_diagonal_dominance(a)
  n = a.size
  (0...n).each do |i|
    diag = a[i][i].abs
    sum = 0.0
    (0...n).each do |j|
      sum += a[i][j].abs unless j == i
    end
    return false if diag < sum
  end
  true
end

# Вывод матрицы
def print_matrix(name, mat)
  puts "#{name}:"
  mat.each do |row|
    row.each { |val| print "%10.4f " % val }
    puts
  end
  puts
end

# Вывод вектора
def print_vector(name, vec)
  puts "#{name}:"
  vec.each { |val| puts "%10.6f" % val }
  puts
end

# LU-разложение и решение
def lu_decomposition(a, b)
  n = a.size

  l = Array.new(n) { Array.new(n, 0.0) }
  u = Array.new(n) { Array.new(n, 0.0) }

  (0...n).each do |i|
    (i...n).each do |k|
      sum = 0.0
      (0...i).each { |j| sum += l[i][j] * u[j][k] }
      u[i][k] = a[i][k] - sum
    end

    (i...n).each do |k|
      if i == k
        l[i][i] = 1.0
      else
        sum = 0.0
        (0...i).each { |j| sum += l[k][j] * u[j][i] }
        l[k][i] = (a[k][i] - sum) / u[i][i]
      end
    end
  end

  y = Array.new(n, 0.0)
  (0...n).each do |i|
    y[i] = b[i]
    (0...i).each { |j| y[i] -= l[i][j] * y[j] }
  end

  x = Array.new(n, 0.0)
  (n - 1).downto(0) do |i|
    x[i] = y[i]
    (i + 1...n).each { |j| x[i] -= u[i][j] * x[j] }
    x[i] /= u[i][i]
  end

  puts "=== Решение через LU-разложение ==="
  print_matrix("A", a)
  print_vector("b", b)
  print_matrix("L", l)
  print_matrix("U", u)
  print_vector("y (решение L·y = b)", y)
  print_vector("x (решение U·x = y)", x)
end

# Метод Зейделя
def zeidel_iteration(a, b, tol = 1e-6, max_iter = 1000)
  n = a.size
  x_old = Array.new(n, 0.0)
  x_new = Array.new(n, 0.0)
  iter = 0
  converged = false

  puts "=== Решение методом простых итераций (Зейдель) ==="

  while iter < 100
    (0...n).each do |i|
      sigma = 0.0
      (0...n).each do |j|
        sigma += a[i][j] * x_old[j] unless j == i
      end
      x_new[i] = (b[i] - sigma) / a[i][i]
    end

    error = 0.0
    (0...n).each { |i| error += (x_new[i] - x_old[i]).abs }

    if error < tol
      converged = true
      break
    end

    x_old = x_new.dup
    iter += 1
  end

  if converged
    puts "Сходимость достигнута за #{iter} итераций."
    print_vector("x (решение)", x_new)
  else
    puts "Решение не сошлось за #{max_iter} итераций."
    print_vector("x (решение)", x_new)
  end
end

# Основная программа
a = [
  [-0.88, -0.04, 0.21, -18.0],
  [0.25, -1.23, 1.0, -0.09],
  [0.21, 0.11, 0.8, -0.13],
  [0.15, -1.31, 0.06, -1.04]
]

b = [-1.24, 0.91, 2.56, -0.88]

lu_decomposition(a, b)
puts
zeidel_iteration(a, b)
