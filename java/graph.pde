// Forces
// Daniel Shiffman <http://www.shiffman.net>

// A class to describe a thing in our world, has vectors for location, velocity, and acceleration
// Also includes scalar values for mass, maximum velocity, and elasticity
import java.util.Vector; 

class Graph {
	public Vector nodes;
	public Vector edges;
	
	Graph() {
		nodes = new java.util.Vector();
		edges = new Vector();
	}
	
	void render() {
	  Enumeration eenum = edges.elements();
	  while (eenum.hasMoreElements()) ((Edge)(eenum.nextElement())).render();
	  Enumeration nenum = nodes.elements(); 
	  while (nenum.hasMoreElements()) ((Node)(nenum.nextElement())).render();
	}
	
	void update() {
		// center force
		Enumeration nenum = nodes.elements(); 
	  while (nenum.hasMoreElements()) {
	  	Node n = (Node)nenum.nextElement();
	  	n.applyMomentum(getCenterMom(PVector.sub(n.getLoc(),center)));
	  	// field force (pushing nodes apart)
	  	Enumeration nenum2 = nodes.elements(); 
	  	while (nenum2.hasMoreElements()) {
	  		Node n2 = (Node)nenum2.nextElement();
	  		if (n != n2)
		  		n.applyMomentum(getFieldMom(PVector.sub(n.getLoc(), n2.getLoc())));
	  	}
	  }
		// edge forces
	  Enumeration eenum = edges.elements();
	  while (eenum.hasMoreElements()) {
	  	Edge e = (Edge)eenum.nextElement();
			e.from.applyMomentum(getEdgeMom(PVector.sub(e.to.getLoc(),e.from.getLoc()),e.strength));
	  }
	  // let the nodes move
	  nenum = nodes.elements(); 
	  while (nenum.hasMoreElements()) {
	  	Node n = (Node)nenum.nextElement();
	  	n.update();
	  }
	}
	
	void addNode(Node node) {
		nodes.add(node);
	}
	
	void addEdge(Edge edge) {
		edges.add(edge);
	}
	
	void addEdge(Node n1, Node n2, boolean bidir) {
		edges.add(new Edge(n1,n2,1));
		if (bidir) edges.add(new Edge(n2,n1,1));		
	}
}

Graph getExampleGraph() {
		Graph g = new Graph();
		Node n1 = new Node(new PVector(20,20));
		Node n2 = new Node(new PVector(100,20));
		Node n3 = new Node(new PVector(20,100));
		Node n4 = new Node(new PVector(10,10));
		Node n5 = new Node(new PVector(100,10));
		Node n6 = new Node(new PVector(10,100));
		g.addNode(n1); g.addNode(n2); g.addNode(n3);
	  g.addNode(n4); g.addNode(n5); g.addNode(n6);
		g.addEdge(n1,n2,true);
		g.addEdge(n1,n3,true);
		g.addEdge(n2,n3,true);
   	g.addEdge(n3,n4,true);
		g.addEdge(n4,n5,true);
		g.addEdge(n4,n6,true);
		g.addEdge(n5,n6,true);
		return g;
	}
	
Graph getRandomGraph(int nodes, float edge_prob) {
	Graph g = new Graph();
	for (int i=0; i<nodes; i++) {
		g.addNode(new Node(new PVector(random(0,width), random(0,height)), random(2.5)));
	}
	Enumeration nenum = g.nodes.elements(); 
	while (nenum.hasMoreElements()) {
	 	Node n = (Node)nenum.nextElement();
	 	Enumeration nenum2 = g.nodes.elements(); 
	  while (nenum2.hasMoreElements()) {
	  	Node n2 = (Node)nenum2.nextElement();
	  	if ((n != n2) && (random(1) < edge_prob))
		  	g.addEdge(n,n2,true);
	  }
	}
	return g; 	
}

class Edge {
	public Node to, from;
	public float strength;
	public boolean visible;
	
	Edge(Node to, Node from, float strength) {
		this.to = to;
		this.from = from;
		this.strength = strength;
		this.visible = true;
	}
	
	void render() {
		stroke(150);
		line(from.getLoc().x, from.getLoc().y, to.getLoc().x, to.getLoc().y);
	}
}

class Node {
  PVector loc;
  PVector vel;
  boolean movable = true;
  float mass;
  float max_vel;
  float bounce = 0.8; // How "elastic" is the object
  float dumping = 0.4; // how much of speed is taken into next step
  
  Node(PVector l) {
  	vel = new PVector(0.,0.);
  	loc = l.get();
    mass = 1.;
    max_vel = 20.0;
  }

  Node(PVector l, float mass) {
    println(mass);
  	vel = new PVector(0.,0.);
  	loc = l.get();
    this.mass = mass;
    max_vel = 20.0;
  }
  
  Node(PVector v, PVector l, float m_) {
    vel = v.get();
    loc = l.get();
    mass = m_;
    max_vel = 20.0;
  }
  
  PVector getLoc() {
    return loc;
  }

  PVector getVel() {
    return vel;
  }

  float getMass() {
    return mass;
  }

  void applyMomentum(PVector mom) {
    PVector dv = mom.get();
    dv.div(mass);
    vel.add(dv);
    if (showVectors) {
      stroke(#DE6445);
      drawVector(dv,loc,20);
    }    
  }
  
  // Main method to operate object
  void go() {
    update();
    borders();
    render();
  }
  
  // Method to update location
  void update() {
  	if (!movable) vel.mult(0);
    vel.limit(max_vel);
    loc.add(vel);
    vel.mult(dumping);
  }
  
  // Check for bouncing off borders
  void borders() {
    if (loc.y > height) {
      vel.y *= -bounce;
      loc.y = height;
    }
    if ((loc.x > width) || (loc.x < 0)) {
      vel.x *= -bounce;
    }    
    //if (loc.x < 0)     loc.x = width;
    //if (loc.x > width) loc.x = 0;
  }  
  
  // Method to display
  void render() {
    ellipseMode(CENTER);
    stroke(0);
    fill(175,200);
    ellipse(loc.x,loc.y,mass*40,mass*40);
//    println(mass);
    if (showVectors) {
      stroke(#306F16);
      drawVector(vel,loc,10);
    }
  }
}

PVector getFieldMom(PVector delta) {
	float r = delta.mag();
  delta.normalize();
	delta.mult((float)(1/(Math.pow(r,1.5) + 1e-6)*4000));
	return delta;
}
		
PVector getEdgeMom(PVector delta, float deg){
  float r = delta.mag();
  delta.normalize();
	delta.mult(r*deg*4e-2);
	return delta;
}
		
PVector getCenterMom(PVector delta) {
  float r = delta.mag();
  delta.normalize();
  delta.mult(r*-1e-2);
	return delta;
}
		
// Renders a vector object 'v' as an arrow and a location 'loc'
void drawVector(PVector v, PVector loc, float scayl) {
  pushMatrix();
  float arrowsize = 5;
  // Translate to location to render vector
  translate(loc.x,loc.y);
  // Call vector heading function to get direction (note that pointing up is a heading of 0) and rotate
  rotate(v.heading2D());
  // Calculate length of vector & scale it to be bigger or smaller if necessary
  float len = v.mag()*scayl;
  // Draw three lines to make an arrow (draw pointing up since we've rotate to the proper direction)
  line(0,0,len,0);
  line(len,0,len-arrowsize,+arrowsize/2);
  line(len,0,len-arrowsize,-arrowsize/2);
  popMatrix();
}
