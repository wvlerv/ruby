require 'find'
require 'json'
require 'digest'

print "Enter path to directory: "
root = gets.strip
root = '.' if root.empty?

files = []

# collect files
Find.find(root) do |path|
  next unless File.file?(path)
  begin
    size = File.size(path)
    files << { path: path, size: size }
  rescue
    next
  end
end

# group by size
groups = files.group_by { |f| f[:size] }.select { |_, v| v.size > 1 }

def same?(a, b)
  Digest::SHA256.file(a).hexdigest == Digest::SHA256.file(b).hexdigest
rescue
  false
end

result_groups = []

# find duplicates
for size, group in groups
  checked = []
  group.each do |f1|
    next if checked.include?(f1[:path])
    dupes = group.select { |f2| f1 != f2 && same?(f1[:path], f2[:path]) }
    if dupes.any?
      all = [f1[:path]] + dupes.map { |d| d[:path] }
      saved = (all.size - 1) * size
      result_groups << {
        size_bytes: size,
        saved_if_dedup_bytes: saved,
        files: all
      }
      checked += all
    end
  end
end

report = {
  scanned_files: files.size,
  groups: result_groups
}

File.write('duplicates.json', JSON.pretty_generate(report))

puts "JSON report saved to duplicates.json"
puts "Scanned #{files.size} files, found #{result_groups.size} duplicate groups."
