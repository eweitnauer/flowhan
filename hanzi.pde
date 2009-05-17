Graph getHanziGraph() {
	Graph g = new Graph();
	Hanzi hao = new Hanzi("好",new PVector(center.x,center.y));
	hao.movable = false;
	hao.size = 60;
	Hanzi nv = new Hanzi("女", new PVector(10,50));
	nv.size = 45;
	Hanzi zi = new Hanzi("子", new PVector(100,50));
	zi.size = 45;
	createNodes(g, nv, new String[]{"如","她", "始"},30);
	createNodes(g, zi, new String[]{"字","李", "孩", "存"},30);
	createNodes(g, hao, new String[]{"您"},45);
	g.addNode(hao); g.addNode(nv); g.addNode(zi);
	g.addEdge(hao,nv,true);
	g.addEdge(hao,zi,true);
	return g;
}

void createNodes(Graph g, Node parent, String[] childs, int size) {
	for (int i=0; i<childs.length; i++) {
		Hanzi n = new Hanzi(childs[i],new PVector(random(0,width), random(0,height)));
		n.size = size;
		g.addNode(n);
		g.addEdge(parent, n, true);
	}
}

class Hanzi extends Node {
	String zi;
	int size = 40;

	Hanzi(String zi, PVector loc) {
		super(loc);
		this.zi = zi;
	}
	
	Hanzi(PVector loc) {
	  super(loc);
		zi = "爱";
	}
	
	// Method to display
  void render() {
    ellipseMode(CENTER);
    stroke(0);
    fill(255);
    ellipse(int(loc.x),int(loc.y),size+10,size+10);
    fill(0);
	  textFont(font_cn, size);
  	textAlign(CENTER,BOTTOM);
	  text(zi, int(loc.x), int(loc.y)+size*0.52);
	  if (showVectors) {
      stroke(#306F16);
      drawVector(vel,loc,10);
    }    
  }
}
