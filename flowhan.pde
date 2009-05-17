//import java.util.Vector;
PImage avatar;
PFont font_cn, font_de;
boolean showVectors = false;
Graph g;
PVector center;

void setup() {
	size(800,600);
	center = new PVector(width/2, height/2);
	avatar = loadImage("http://www.gravatar.com/avatar/2db5bef022028e9db45e8cbaebbf042f.png");
	font_cn = createFont("AR PL UKai CN", 20);
  font_de = createFont("verdana", 20);
  //g = getExampleGraph();
  //g = getRandomGraph(20,0.1);
  //g.addNode(new Hanzi(new PVector(20,20)));
  g = getHanziGraph();
}

void draw() {
	background(255);
	footer();
  smooth();
	g.update();
	g.render();
}

void footer() {
	image(avatar, 10, height-90);
	textFont(font_de, 16);
	textAlign(LEFT, CENTER);
	fill(50);
	text("Written by Erik Weitnauer, 2009",100,height-50);
}
