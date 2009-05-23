class Flowhan < Processing::App

  def get_hanzi_graph
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
    attr_accessor :zi, :size
   
    def initialize(zi, loc)
      super(loc)
      @size = 40
      @zi = zi;
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
      if ($show_vectors)
        stroke(0x306F16);
        draw_vector(@vel,@loc,10);
      end
    end
  end
end
