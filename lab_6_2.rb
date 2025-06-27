# Класс для реализации AES-128 в режиме CFB
class AES
  # Таблица S-box для SubWord (256 элементов)
  SBOX = [
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
  ].freeze

  # Константы Rcon для ключевого расширения (11 значений)
  RCON = [
    0x00, # Rcon[0] не используется
    0x01, 0x02, 0x04, 0x08,
    0x10, 0x20, 0x40, 0x80,
    0x1B, 0x36
  ].freeze

  # Функция вывода данных в 16-ричном формате с заголовком
  def self.print_hex(label, data)
    print label
    data.each { |byte| print "%02x" % byte }
    puts
  end

  # Функция циклического сдвига слова (32-бита) на 1 байт влево
  def self.rot_word(word)
    ((word << 8) & 0xFFFFFFFF) | (word >> 24)
  end

  # Функция замены каждого байта слова на значение из S-box
  def self.sub_word(word)
    result = 0
    4.times do |i|
      byte = (word >> (24 - 8 * i)) & 0xFF
      sub = SBOX[byte]
      result |= sub << (24 - 8 * i)
    end
    result
  end

  # Функция расширения ключа
  def self.key_expansion(key)
    nk = 4       # Количество слов в ключе (AES-128: 4 слова по 4 байта)
    nr = 10      # Количество раундов шифрования (AES-128: 10)
    nb = 4       # Количество слов в блоке (4 слова)
    
    round_keys = Array.new(nb * (nr + 1), 0)

    # Копируем исходный ключ в первые Nk слов раундовых ключей
    nk.times do |i|
      round_keys[i] = (key[4 * i].ord << 24) | 
                      (key[4 * i + 1].ord << 16) | 
                      (key[4 * i + 2].ord << 8) | 
                      key[4 * i + 3].ord
    end

    # Генерируем оставшиеся слова ключа
    (nk...nb*(nr+1)).each do |i|
      temp = round_keys[i - 1]

      if i % nk == 0
        temp = sub_word(rot_word(temp)) ^ (RCON[i / nk] << 24)
      end
      round_keys[i] = round_keys[i - nk] ^ temp
    end

    round_keys
  end

  # Функция вывода всех раундовых ключей
  def self.print_round_keys(round_keys)
    nr = 10    # Количество раундов
    nb = 4     # Количество слов в блоке

    puts "\nRound Keys:"
    (0..nr).each do |i|
      print "Round #{i}: "
      nb.times do |j|
        word = round_keys[i * nb + j]
        3.downto(0) do |k|
          print "%02x" % ((word >> (8 * k)) & 0xFF
        end
        print " "
      end
      puts
    end
  end

  # Функция умножения в поле Галуа
  def self.gmul(a, b)
    p = 0
    8.times do
      p ^= a if (b & 1) != 0
      hi_bit_set = (a & 0x80) != 0
      a <<= 1
      a ^= 0x1b if hi_bit_set  # Полином для AES
      b >>= 1
    end
    p & 0xFF
  end

  # Функция шифрования одного блока (16 байт)
  def self.aes_encrypt_block(input, round_keys)
    nb = 4
    nr = 10

    # Инициализация state (4x4 байта)
    state = Array.new(4) { Array.new(4, 0) }
    16.times do |i|
      state[i % 4][i / 4] = input[i].ord
    end

    # AddRoundKey для начального ключа
    nb.times do |i|
      k = round_keys[i]
      state[0][i] ^= (k >> 24) & 0xFF
      state[1][i] ^= (k >> 16) & 0xFF
      state[2][i] ^= (k >> 8) & 0xFF
      state[3][i] ^= k & 0xFF
    end

    # Раунды 1..Nr-1
    (1...nr).each do |round|
      # SubBytes
      4.times do |r|
        4.times do |c|
          state[r][c] = SBOX[state[r][c]]
        end
      end

      # ShiftRows
      4.times do |r|
        temp = []
        4.times do |c|
          temp << state[r][(c + r) % 4]
        end
        4.times do |c|
          state[r][c] = temp[c]
        end
      end

      # MixColumns
      4.times do |c|
        a = []
        b = []
        4.times do |i|
          a << state[i][c]
          b << ((state[i][c] << 1) ^ ((state[i][c] & 0x80 != 0) ? 0x1b : 0x00) & 0xFF
        end
        state[0][c] = (b[0] ^ a[1] ^ b[1] ^ a[2] ^ a[3]) & 0xFF
        state[1][c] = (a[0] ^ b[1] ^ a[2] ^ b[2] ^ a[3]) & 0xFF
        state[2][c] = (a[0] ^ a[1] ^ b[2] ^ a[3] ^ b[3]) & 0xFF
        state[3][c] = (a[0] ^ b[0] ^ a[1] ^ a[2] ^ b[3]) & 0xFF
      end
      
      # AddRoundKey
      nb.times do |i|
        k = round_keys[round * nb + i]
        state[0][i] ^= (k >> 24) & 0xFF
        state[1][i] ^= (k >> 16) & 0xFF
        state[2][i] ^= (k >> 8) & 0xFF
        state[3][i] ^= k & 0xFF
      end
    end

    # Раунд Nr без MixColumns
    # SubBytes
    4.times do |r|
      4.times do |c|
        state[r][c] = SBOX[state[r][c]]
      end
    end

    # ShiftRows
    4.times do |r|
      temp = []
      4.times do |c|
        temp << state[r][(c + r) % 4]
      end
      4.times do |c|
        state[r][c] = temp[c]
      end
    end

    # AddRoundKey
    nb.times do |i|
      k = round_keys[nr * nb + i]
      state[0][i] ^= (k >> 24) & 0xFF
      state[1][i] ^= (k >> 16) & 0xFF
      state[2][i] ^= (k >> 8) & 0xFF
      state[3][i] ^= k & 0xFF
    end

    # Преобразуем state в одномерный массив
    output = []
    16.times do |i|
      output << state[i % 4][i / 4]
    end
    output
  end

  # Генерация случайного вектора инициализации 16 байт
  def self.generate_random_iv
    iv = []
    16.times { iv << rand(256) }
    iv
  end

  # Генерация случайного 16-байтового ключа
  def self.generate_random_key
    generate_random_iv
  end

  # Функция шифрования в режиме CFB
  def self.aes_cfb_encrypt(plaintext, round_keys, iv)
    len = plaintext.size
    ciphertext = []
    feedback = iv.dup

    len.times do |i|
      enc_block = aes_encrypt_block(feedback.map(&:chr), round_keys)
      ciphertext_byte = plaintext[i].ord ^ enc_block[0]
      ciphertext << ciphertext_byte

      # Обновляем feedback
      feedback.shift
      feedback << ciphertext_byte
    end

    ciphertext
  end

  # Функция дешифрования в режиме CFB
  def self.aes_cfb_decrypt(ciphertext, round_keys, iv)
    len = ciphertext.size
    plaintext = []
    feedback = iv.dup

    len.times do |i|
      enc_block = aes_encrypt_block(feedback.map(&:chr), round_keys)
      plaintext_byte = ciphertext[i] ^ enc_block[0]
      plaintext << plaintext_byte

      # Обновляем feedback
      feedback.shift
      feedback << ciphertext[i]
    end

    plaintext
  end
end

# Основная программа
puts "Введите многострочный текст для шифрования (конец ввода Ctrl+D на пустой строке):"

# Считываем многострочный ввод
fulltext = []
while line = gets
  break if line.chomp.empty?
  fulltext << line.chomp
end
fulltext = fulltext.join("\n")

if fulltext.empty?
  puts "Ошибка: введён пустой текст."
  exit 1
end

# Генерируем случайный ключ и IV
key = AES.generate_random_key.map(&:chr).join
iv = AES.generate_random_iv

# Выводим ключ и IV
AES.print_hex("Сгенерированный ключ: ", key.bytes)
AES.print_hex("Сгенерированный IV:  ", iv)

# Расширяем ключ
round_keys = AES.key_expansion(key)

# Выводим все раундовые ключи
AES.print_round_keys(round_keys)

# Шифруем текст в режиме CFB
ciphertext = AES.aes_cfb_encrypt(fulltext, round_keys, iv)

# Выводим шифротекст в hex
AES.print_hex("\nЗашифрованный текст (hex): ", ciphertext)

# Дешифруем обратно
decryptedtext = AES.aes_cfb_decrypt(ciphertext, round_keys, iv)

# Выводим дешифрованный текст
puts "\nДешифрованный текст:"
puts decryptedtext.pack('C*')
