require 'graph.rb'
require 'hanzi.rb'

$showVectors = false

class Flowhan < Processing::App
  def setup
    $center = PVector.new(width/2, height/2)
    @avatar = load_image("http://www.gravatar.com/avatar/2db5bef022028e9db45e8cbaebbf042f.png")
    $font_cn = create_font("AR PL UKai CN", 20);
    $font_de = create_font("verdana", 20);
    #@g = get_example_graph();
    #@g = get_random_graph(20,0.1);
    #@g.add_node(Hanzi.new(PVector.new(20,20)));
    @g = get_hanzi_graph
  end
   
  def draw
    background 255
    footer
    smooth
    @g.update
    @g.render
  end
   
  def footer
    image(@avatar, 10, height-90);
    text_font($font_de, 16);
    text_align(LEFT, CENTER);
    fill(50);
    text("Written by Erik Weitnauer, 2009",100,height-50);
  end
  
  def get_example_graph
    g = Graph.new($center)
    n1 = Node.new(PVector.new(20,20))
    n2 = Node.new(PVector.new(100,20))
    n3 = Node.new(PVector.new(20,100))
    n4 = Node.new(PVector.new(10,10))
    n5 = Node.new(PVector.new(100,10))
    n6 = Node.new(PVector.new(10,100))
    g.add_node(n1); g.add_node(n2); g.add_node(n3);
    g.add_node(n4); g.add_node(n5); g.add_node(n6);
    g.add_edge2(n1,n2,true);
    g.add_edge2(n1,n3,true);
    g.add_edge2(n2,n3,true);
    g.add_edge2(n3,n4,true);
    g.add_edge2(n4,n5,true);
    g.add_edge2(n4,n6,true);
    g.add_edge2(n5,n6,true);
    return g;
  end
  
  def get_random_graph(nodes, edge_prob)
    g = Graph.new($center)
    nodes.times do 
      g.add_node(Node.new(PVector.new(random(0,width), random(0, height))))
    end
    g.nodes.each do |n|
      g.nodes.each do |n2|
        g.add_edge2(n,n2,true) if (n != n2) and (random(1) < edge_prob)
      end
    end
    return g;   
  end
end

Flowhan.new(:width => 800, :height => 600, :title => "Flowhan In Ruby-Processing")
