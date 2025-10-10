def cut_cake(cake)
  grid = cake.map(&:chars)
  h = grid.size
  w = grid.first.size

  raisins = []
  h.times do |y|
    w.times do |x|
      raisins << [y, x] if grid[y][x] == 'o'
    end
  end

  n = raisins.size
  total_area = h * w
  return [] if total_area % n != 0

  piece_area = total_area / n

  possible_rects = []
  (1..h).each do |ph|
    (1..w).each do |pw|
      possible_rects << [ph, pw] if ph * pw == piece_area
    end
  end

  solutions = []

  def backtrack(i, raisins, grid, h, w, used, piece_area, possible_rects, pieces, solutions)
    if i == raisins.size
      solutions << pieces.map(&:dup)
      return
    end

    ry, rx = raisins[i]

    possible_rects.each do |ph, pw|
      (0..(h - ph)).each do |y0|
        (0..(w - pw)).each do |x0|
          y1, x1 = y0 + ph - 1, x0 + pw - 1
          next unless (y0..y1).include?(ry) && (x0..x1).include?(rx)

          free = true
          (y0..y1).each do |yy|
            (x0..x1).each do |xx|
              free = false if used[yy][xx]
            end
          end
          next unless free

          (y0..y1).each { |yy| (x0..x1).each { |xx| used[yy][xx] = true } }

          piece = (y0..y1).map { |yy| grid[yy][x0..x1].join }
          backtrack(i + 1, raisins, grid, h, w, used, piece_area, possible_rects, pieces + [piece], solutions)

          (y0..y1).each { |yy| (x0..x1).each { |xx| used[yy][xx] = false } }
        end
      end
    end
  end

  used = Array.new(h) { Array.new(w, false) }
  backtrack(0, raisins, grid, h, w, used, piece_area, possible_rects, [], solutions)

  best = solutions.max_by { |sol| sol.first.first.size }
  best || []
end

puts "Enter a cake"

cake = []
loop do
  line = gets&.chomp
  break if line.nil? || line.empty?
  cake << line
end

if cake.empty?
  puts "No cake"
  exit
end

result = cut_cake(cake)

if result.empty?
  puts "Unable to cut the cake"
else
  result.each_with_index do |piece, i|
    puts "\nPiece #{i + 1}:"
    puts piece.join("\n")
  end
end


