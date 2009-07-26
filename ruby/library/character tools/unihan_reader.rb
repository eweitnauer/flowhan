require 'hanz_decompose'

# For explaination of property meanings in Unihan.txt file see
# http://www.unicode.org/reports/tr38/tr38-5.html

$KCODE = 'UTF-8'   # only used when encoding is not specified.


#puts [0x4E00].pack('U')
#puts '新'.to_u.inspect

# Fills the hash passed as second argument as follows:
# key: "U+xxxx"
# value: hash holding the properties of this unicode character
# Reads the ids decompositions from the passed file and stores them inside the
# hash passed as second argument in the following format:
# char_hash["U+xxx"][:kProperty] = a String
def readUnihanDatabase(filename, char_hash)
  File.open(filename) do |f|
    while (line = f.gets)
      next if line.match(/^#/) # line commented out?
      a = line.strip.split("\t")
      char_hash[a[0]] = Hash.new() unless char_hash.has_key? a[0]
      char_hash[a[0]][a[1].to_sym] = a[2]
    end
  end
end


def getRadical(k_rs_unicode)
  n = k_rs_unicode.match(/([0-9]{1,3})\'?\.[0-9]{1,2}/)[1]
  return [0x2F00 + n.to_i-1].pack('U')
end

def getFennFrequency(k_fenn)
  return "unknown" if k_fenn.nil?
  f = k_fenn.match(/[0-9]+a?([A-KP*])/)[1]
  case f
    when 'A'..'K'
      freq = (f[0]-'A'[0]+1)*500
      return "among the most frequent #{freq} characters"
    when 'P'
      return 'phonetic element'
  end
  return 'unknown'
end

def writeCharInfo(char, char_props)
  h = char_props[char.to_ustr]
  puts "Info about: #{char}:"
  puts "Frequency: #{h[:kFrequency]}"
  puts "Strokes: #{h[:kTotalStrokes]}"
  puts "Mandarin: #{h[:kMandarin]}"
  puts "Definition: #{h[:kDefinition]}"
  puts "Radical: " + getRadical(h[:kRSUnicode])
  puts "Fenn-Frequency: " + getFennFrequency(h[:kFenn])
  puts "Grade Level: #{h[:kGradeLevel]}"
  puts "Decomposition: " + char.to_u.decompose_all(char_props).to_s
end

unihan = Hash.new({})
puts "Reading IDS and Unihan files... "
t = Time.now
readUnihanDatabase('Unihan.txt', unihan)
readIDSFile('IDS-UCS-Basic.txt', unihan)
puts "OK. [%.3f s]" % (Time.now-t)

puts "Loaded hash with #{unihan.size} entries."
puts
writeCharInfo('新', unihan)
#puts "Properties of '新':"
#unihan['新'.to_ustr].each do |key, value|
#  puts key.to_s + ": " + value.to_s 
#end


