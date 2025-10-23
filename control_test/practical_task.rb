def read_file_in_batches(file_name, batch_size)
  return puts "Error: file '#{file_name}' not found." unless File.exist?(file_name)

  all_batches = []

  File.open(file_name, "r") do |file|
    batch = []
    batch_number = 1

    file.each_line do |line|
      batch << line.chomp
      if batch.size == batch_size
        all_batches << format_batch(batch, batch_number)
        batch = []
        batch_number += 1
      end
    end

    all_batches << format_batch(batch, batch_number) unless batch.empty?
  end

  save_report(all_batches)
end

class ReportFormatter
  def format(title, text)
    raise NotImplementedError, "Subclasses must implement this method"
  end
end

class TextFormatter < ReportFormatter
  def format(title, text)
    "REPORT: #{title}\n\n#{text.join("\n")}\n\n"
  end
end

class MarkdownFormatter < ReportFormatter
  def format(title, text)
    "# #{title}\n\n#{text.join("\n")}\n\n"
  end
end

class HtmlFormatter < ReportFormatter
  def format(title, text)
    html_text = text.join('<br>')
    "<h2>#{title}</h2>\n<p>#{html_text}</p>\n"
  end
end

def format_batch(batch, batch_number)
  return "" if batch.empty?
  title = "Batch #{batch_number} (#{batch.size} lines)"
  @formatter.format(title, batch)
end

def save_report(all_batches)
  ext =
    case @formatter
    when TextFormatter then "txt"
    when MarkdownFormatter then "md"
    when HtmlFormatter then "html"
    else "txt"
    end

  file_name = "report.#{ext}"

  if @formatter.is_a?(HtmlFormatter)
    content = "<html>\n<head><title>Report</title></head>\n<body>\n"
    content += all_batches.join("\n")
    content += "\n</body>\n</html>"
  else
    content = all_batches.join
  end

  File.write(file_name, content)
  puts "Report saved to #{file_name}"
end

print "Enter file name: "
file_name = gets.chomp

print "Enter batch size (number of lines per batch): "
batch_size = gets.to_i

puts "\nChoose report format: text / markdown / html"
format_choice = gets.chomp.downcase

@formatter =
  case format_choice
  when "text" then TextFormatter.new
  when "markdown" then MarkdownFormatter.new
  when "html" then HtmlFormatter.new
  else
    puts "Unknown format. Using text by default."
    TextFormatter.new
  end

read_file_in_batches(file_name, batch_size)