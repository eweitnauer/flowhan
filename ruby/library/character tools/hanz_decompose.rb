require 'rubygems'
require 'unicode'

class String
  def to_ustr
    "U+%X" % unpack('U')
  end
end

class Unicode::Character
  def to_ustr
    'U+%X' % to_i
  end
end

class Unicode::String
  def decompose(ids)
    s = "".to_u
    each { |c| s << (ids[c.to_ustr][:ids] || c.to_u) }
    return s
  end
  
  def decompose_all(ids)
    s = self
    while true
      before = s
      s = s.decompose(ids)
      break if s==before
    end
    return s
  end
end

# Reads the ids decompositions from the passed file and stores them inside the
# hash passed as second argument in the following format:
# char_hash["U+xxx"][:ids] = an Unicode::String
def readIDSFile(filename, char_hash)
  File.open(filename) do |f|
    while (line = f.gets)
      next if line.match(/^;;/) # line commented out?
      a = line.strip.split("\t")
      char_hash[a[0]] = Hash.new() unless char_hash.has_key? a[0]
      char_hash[a[0]][:ids] = a[2].to_u
    end
  end
end


$KCODE = 'UTF-8'   # only used when encoding is not specified.
u = "丆	⿱一丿".to_u('utf8')
puts u.length           #=> 5
puts u.to_a.inspect     #=> array of codepoint
puts u.inspect          #=> <U+AC00>
puts u.to_s             #=>

u.each { |c| puts "%X" % c.to_i }

print "Reading IDS files... "
t = Time.now
ids = Hash.new({})
readIDSFile('IDS-UCS-Basic.txt', ids)
readIDSFile('IDS-UCS-Ext-A.txt', ids)
puts "OK. [%.3f s]" % (Time.now-t)
puts 

#puts "乕".to_u.decompose_all(ids)

