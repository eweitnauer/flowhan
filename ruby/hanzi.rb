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

class Flowhan < Processing::App
  def get_hanzi_graph(hanzi)
    @unihan = Hash.new({})
    puts "Reading IDS and Unihan files... "
    t = Time.now
    readUnihanDatabase('Unihan.txt', @unihan)
    readIDSFile('IDS-UCS-Basic.txt', @unihan)
    puts "OK. [%.3f s]" % (Time.now-t)
    
    
    
    puts "Loaded hash with #{@unihan.size} entries."
    puts
    writeCharInfo('新', @unihan)

    g = Graph.new($center)
    node = Hanzi.new(hanzi, PVector.new($center.x,$center.y))
    node.pinyin = @unihan[hanzi.to_ustr][:kMandarin]
    node.movable = false
    node.size = 60
    g.add_node(node)
    create_subgraph_ids(g, node)
    return g;
  end

  def create_subgraph_ids(g, parent)
    # components
    decomp = parent.zi.to_u.decompose(@unihan)
    puts decomp
    return if decomp.length != 3
    node1 = Hanzi.new(decomp[1])
    node1.pinyin = @unihan[decomp[1].to_ustr][:kMandarin]
    node1.definition = @unihan[decomp[1].to_ustr][:kDefinition]
    g.add_node(node1)
    g.add_edge2(parent, node1, true)
    node2 = Hanzi.new(decomp[2])
    node2.pinyin = @unihan[decomp[2].to_ustr][:kMandarin]
    node2.definition = @unihan[decomp[2].to_ustr][:kDefinition]
    g.add_node(node2)
    g.add_edge2(parent, node2, true)
    create_subgraph_ids(g,node1)
    create_subgraph_ids(g,node2)
    
    # radical
    node_rad = Hanzi.new(getRadical(@unihan[parent.zi.to_ustr][:kRSUnicode]))
    node_rad.pinyin = @unihan[node_rad.zi.to_ustr][:kMandarin]
    node_rad.definition = @unihan[node_rad.zi.to_ustr][:kDefinition]
    g.add_node(node_rad)
    g.add_edge2(parent, node_rad, true)
  end
  
  def get_hanzi_example_graph
    g = Graph.new($center)
    hao = Hanzi.new("好", PVector.new($center.x,$center.y));
    hao.movable = false;
    hao.size = 60;
    nv = Hanzi.new("女", PVector.new(10,50));
    nv.size = 45;
    zi = Hanzi.new("子", PVector.new(100,50));
    zi.size = 45;
    createNodes(g, nv, ["如","她", "始"],30);
    createNodes(g, zi, ["字","李", "孩", "存"],30);
    createNodes(g, hao, ["您"],45);
    g.add_node(hao); g.add_node(nv); g.add_node(zi);
    g.add_edge2(hao,nv,true);
    g.add_edge2(hao,zi,true);
    return g;
  end
 
  def createNodes(g, parent, childs, size)
    childs.each do |c|
      n = Hanzi.new(c,PVector.new(random(0,width), random(0,height)))
      n.size = size
      g.add_node(n)
      g.add_edge2(parent, n, true)
    end
  end
 
  class Hanzi < Node
    attr_accessor :zi, :size, :pinyin, :definition
   
    def initialize(zi, loc=nil)
      loc = PVector.new($center.x+rand(100)-50,$center.y+rand(100)-50) if loc.nil?
      super(loc)
      @size = 40
      @zi = zi;
      @pinyin = ""
    end
    
    # method to display
    def render
      ellipse_mode(CENTER);
      stroke(0);
      fill(255);
      ellipse(@loc.x.round,@loc.y.round,@size+10,@size+10);
      fill(0);
      textFont($font_cn, @size);
      textAlign(CENTER,BOTTOM);
      text(@zi, @loc.x.round, @loc.y.round+@size*0.52)
      textFont($font_de, @size/4);
      text(@pinyin, @loc.x.round, @loc.y.round+@size) unless @pinyin.nil?
      text(@definition, @loc.x.round, @loc.y.round-@size) unless @definition.nil?
      if ($show_vectors)
        stroke(0x306F16);
        draw_vector(@vel,@loc,10);
      end
    end
  end
end
