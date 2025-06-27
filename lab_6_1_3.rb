HEIGHT = 25
WIDTH = 25
STEPS = 100
DELAY = 0.02 # в секундах

# Replicator pattern (примерная форма, 9x9)
REPLICATOR = [
  [1,3], [1,4], [2,2], [2,4], [3,1], [3,2], [3,5], [4,1], [4,3], [4,5], [5,2], [5,4],
  [6,3]
]

# Glider (паразит)
PARASITE = [
  [10,10], [11,11], [12,9], [12,10], [12,11]
]

def initialize_grid
  grid = Array.new(HEIGHT) { Array.new(WIDTH, 0) }
  
  REPLICATOR.each do |r, c|
    grid[r][c] = 1 if r < HEIGHT && c < WIDTH
  end
  
  PARASITE.each do |r, c|
    grid[r][c] = 1 if r < HEIGHT && c < WIDTH
  end
  
  grid
end

def print_grid(grid)
  system('clear') || system('cls')
  grid.each do |row|
    row.each do |cell|
      print cell == 1 ? '0' : ' '
    end
    puts
  end
end

def count_neighbors(grid, x, y)
  count = 0
  (-1..1).each do |dx|
    (-1..1).each do |dy|
      next if dx == 0 && dy == 0
      nx = (x + dx + HEIGHT) % HEIGHT
      ny = (y + dy + WIDTH) % WIDTH
      count += grid[nx][ny]
    end
  end
  count
end

def update_grid(grid)
  new_grid = Array.new(HEIGHT) { Array.new(WIDTH, 0) }
  
  (0...HEIGHT).each do |i|
    (0...WIDTH).each do |j|
      n = count_neighbors(grid, i, j)
      if grid[i][j] == 1
        new_grid[i][j] = (n == 2 || n == 3) ? 1 : 0
      else
        new_grid[i][j] = (n == 3) ? 1 : 0
      end
    end
  end
  
  new_grid
end

puts "Game of Life: Replicator + Parasite\nНажмите Enter..."
gets

grid = initialize_grid

STEPS.times do
  print_grid(grid)
  grid = update_grid(grid)
  sleep(DELAY)
end

puts "Симуляция завершена."
