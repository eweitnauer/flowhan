class Flowhan < Processing::App
  class Graph
    attr_accessor :nodes, :edges # arrays
    attr_accessor :center # PVector
    
    # center is a PVector and the center of the graph
    def initialize(center)
      @nodes = []; @edges = []
      @center = center
    end
    
    def render
      @edges.each { |e| e.render }
      @nodes.each { |n| n.render }
    end
    
    # apply physics to the nodes
    def update
      # center force (pull nodes to center)
      @nodes.each do |n|
        n.apply_momentum(Force.center_mom(PVector.sub(n.loc, @center)))
        # apply field force (push nodes apart)
        @nodes.each do |n2|
          n.apply_momentum(Force.field_mom(PVector.sub(n.loc, n2.loc))) unless n == n2
        end
      end
      
      # edge forces (pull connected nodes to each other)
      @edges.each do |e|
        e.from.apply_momentum(Force.edge_mom(PVector.sub(e.to.loc, e.from.loc), e.strength))
      end
      
      # move the nodes
      @nodes.each { |n| n.update }
    end
      
    def add_node node
      @nodes << node
    end
    
    def add_edge edge
      @edges << edge
    end
    
    def add_edge2 n1, n2, bidir=true
      @edges << Edge.new(n1, n2, 1)
      @edges << Edge.new(n2, n1, 1) if bidir
    end
  end

  class Edge
    attr_accessor :to, :from # Node
    attr_accessor :strength  # Numerical
    attr_accessor :visible   # bool
    
    def initialize (to, from, strength)
      @to = to
      @from = from
      @strength = strength
      @visible = true
    end
    
    def render
      stroke(150)
      line(from.loc.x, from.loc.y, to.loc.x, to.loc.y)
    end
  end
   
  class Node
    attr_accessor :loc, :vel # PVector
    attr_accessor :movable # bool
    attr_accessor :mass, :max_vel, :dumping # float
    
    # call with initial location
    def initialize(loc, mass=1.0)
      @loc = loc.get # deep copy
      @movable = true
      @vel = PVector.new(0, 0)
      @mass = mass
      @max_vel = 20.0
      @dumping = 0.5
    end
   
    # momentum is a PVector
    def apply_momentum(mom)
      dv = mom.get # deep copy
      dv.div(@mass)
      @vel.add(dv);
      if $show_vectors
        stroke(0xDE6445);
        drawVector(dv,@loc,20);
      end
    end
    
    # method to update location
    def update
      @vel.mult(0) if not @movable
      @vel.limit(@max_vel)
      @loc.add(@vel)
      @vel.mult(@dumping)
    end
    
    # Method to display
    def render
      ellipse_mode(CENTER)
      stroke(0)
      fill(175,200)
      ellipse(@loc.x,@loc.y,@mass*40,@mass*40)
      if $show_vectors
        stroke(0x306F16)
        drawVector(@vel,@loc,10)
      end
    end
  end

  class Force
    def self.field_mom(delta)
      r = delta.mag
      delta.normalize
      delta.mult((1./(r**1.5 + 1e-6)*4000));
      return delta;
    end
      
    # delta is PVector, diff between the nodes, deg is the strength of the edge
    def self.edge_mom(delta, deg)
      r = delta.mag
      delta.normalize
      delta.mult(r*deg*4e-2)
      return delta;
    end
      
    def self.center_mom(delta)
      r = delta.mag
      delta.normalize
      delta.mult(r*-1e-2)
      return delta;
    end
  end
      
  # Renders a PVector 'v' as an arrow and at location 'loc', also PVector
  # scale is a float
  def drawVector(v, loc, scale)
    push_matrix
    arrowsize = 5.
    # Translate to location to render vector
    translate(loc.x,loc.y);
    # Call vector heading function to get direction (note that pointing up is a heading of 0) and rotate
    rotate(v.heading2D());
    # Calculate length of vector & scale it to be bigger or smaller if necessary
    len = v.mag()*scale
    # Draw three lines to make an arrow (draw pointing up since we've rotate to the proper direction)
    line(0,0,len,0);
    line(len,0,len-arrowsize,+arrowsize/2);
    line(len,0,len-arrowsize,-arrowsize/2);
    pop_matrix();
  end
end
