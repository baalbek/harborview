var MAUNALOA = MAUNALOA || {};

MAUNALOA.levelLine = {
    color : "red",
    draw : function(ctx) {
        console.log(ctx + "x1: " + this.x1 + ", y1: " + this.y1);
        ctx.beginPath();
        ctx.moveTo(this.x0,this.y0);
        ctx.lineTo(this.x1,this.y1);
        ctx.strokeStyle=this.color;
        ctx.stroke();
    }
    /*
    create : function(levelValue) {
        var result = Object.create(MAUNALOA.levelLine);
    }
    */
};

// https://stackoverflow.com/questions/9880279/how-do-i-add-a-simple-onclick-event-handler-to-a-canvas-element

MAUNALOA.repos = {
  init : function() {
    // listen for mouse events
    this.canvas = $("#" + this.canvasId);
    this.ctx = document.getElementById(this.canvasId).getContext("2d");
    //this.canvas.mousedown(function(e){handleMouseDown(e);});
    //this.canvas.mousemove(function(e){handleMouseMove(e);});
    this.canvas.mouseup(this.handleMouseUpOut(this));
    //this.canvas.mouseout(function(e){handleMouseUpOut(e);});
  },
  
  handleMouseUpOut : function(self) {
    return function(e) {
        self.draw();
    }
  },
  handleMouseDown : function(e) {
    alert("Hi!");
  },
  lines : [],
  draw : function() {
    var len = this.lines.length;
    for (var i=0; i<len; ++i) {
        this.lines[i].draw(this.ctx);
    }
  },
  create : function(canvasId) {
    var result = Object.create(MAUNALOA.repos);
    result.canvasId = canvasId;
    result.init();
    return result;
  },
  addLevelLine : function(lineId,levelValue) {
    var result = Object.create(MAUNALOA.levelLine);
    result.x1 = 30;
    result.y1 = 30;
    result.x2 = 200;
    result.y2 = 30;
    this.lines.push(result);
  }

}
/*
MAUNALOA.crateRepos = function(canvasId){
    var result = Object.create(MAUNALOA.repos);
    result.canvasId = canvasId;
    result.init();
    return result;
}
*/

MAUNALOA.draggable = {
  // select the nearest line to the mouse
  closestLine : function (mx,my,lines){
    var dist=100000000;
    var index,pt;
    for(var i=0;i<lines.length;i++){
        var xy=closestXY(lines[i],mx,my);
        var dx=mx-xy.x;
        var dy=my-xy.y;
        var thisDist=dx*dx+dy*dy;
        if(thisDist<dist){
            dist=thisDist;
            pt=xy;
            index=i;
        }
    }
    var line=lines[index];
    return({ pt:pt, line:line, originalLine:{x0:line.x0,y0:line.y0,x1:line.x1,y1:line.y1} });
  }

};



jQuery(document).ready(function() {
    var r = MAUNALOA.repos.create("canvas0");
    r.addLevelLine(1,3);
    //r.draw();
});

/*
// canvas vars
var canvas=document.getElementById("canvas");
var ctx=canvas.getContext("2d");
var cw=canvas.width;
var ch=canvas.height;
function reOffset(){
    var BB=canvas.getBoundingClientRect();
    offsetX=BB.left;
    offsetY=BB.top;        
}
var offsetX,offsetY;
reOffset();
window.onscroll=function(e){ reOffset(); }
window.onresize=function(e){ reOffset(); }

// dragging vars
var isDown=false;
var startX,startY;

// line vars
var nearest;
var lines=[];
lines.push({x0:75, y0:25, x1:125,y1:25});
lines.push({x0:75, y0:100, x1:125, y1:100});
lines.push({x0:50, y0:35, x1:50,y1:85});
lines.push({x0:150,y0:35, x1:150,y1:85});

draw();

// listen for mouse events
$("#canvas").mousedown(function(e){handleMouseDown(e);});
$("#canvas").mousemove(function(e){handleMouseMove(e);});
$("#canvas").mouseup(function(e){handleMouseUpOut(e);});
$("#canvas").mouseout(function(e){handleMouseUpOut(e);});


// functions
//////////////////////////

// select the nearest line to the mouse
function closestLine(mx,my){
    var dist=100000000;
    var index,pt;
    for(var i=0;i<lines.length;i++){
        //
        var xy=closestXY(lines[i],mx,my);
        //
        var dx=mx-xy.x;
        var dy=my-xy.y;
        var thisDist=dx*dx+dy*dy;
        if(thisDist<dist){
            dist=thisDist;
            pt=xy;
            index=i;
        }
    }
    var line=lines[index];
    return({ pt:pt, line:line, originalLine:{x0:line.x0,y0:line.y0,x1:line.x1,y1:line.y1} });
}

// linear interpolation -- needed in setClosestLine()
function lerp(a,b,x){return(a+x*(b-a));}

// find closest XY on line to mouse XY
function closestXY(line,mx,my){
    var x0=line.x0;
    var y0=line.y0;
    var x1=line.x1;
    var y1=line.y1;
    var dx=x1-x0;
    var dy=y1-y0;
    var t=((mx-x0)*dx+(my-y0)*dy)/(dx*dx+dy*dy);
    t=Math.max(0,Math.min(1,t));
    var x=lerp(x0,x1,t);
    var y=lerp(y0,y1,t);
    return({x:x,y:y});
}

// draw the scene
function draw(){
    ctx.clearRect(0,0,cw,ch);
    // draw all lines at their current positions
    for(var i=0;i<lines.length;i++){
        drawLine(lines[i],'black');
    }
    // draw markers if a line is being dragged
    if(nearest){
        // point on line nearest to mouse
        ctx.beginPath();
        ctx.arc(nearest.pt.x,nearest.pt.y,5,0,Math.PI*2);
        ctx.strokeStyle='red';
        ctx.stroke();
        // marker for original line before dragging
        drawLine(nearest.originalLine,'red');
        // hightlight the line as its dragged
        drawLine(nearest.line,'red');
    }
}

function drawLine(line,color){
    ctx.beginPath();
    ctx.moveTo(line.x0,line.y0);
    ctx.lineTo(line.x1,line.y1);
    ctx.strokeStyle=color;
    ctx.stroke();
}

function handleMouseDown(e){
  // tell the browser we're handling this event
  e.preventDefault();
  e.stopPropagation();
  // mouse position
  startX=parseInt(e.clientX-offsetX);
  startY=parseInt(e.clientY-offsetY);
  // find nearest line to mouse
  nearest=closestLine(startX,startY);
  draw();
  // set dragging flag
  isDown=true;
}

function handleMouseUpOut(e){
  // tell the browser we're handling this event
  e.preventDefault();
  e.stopPropagation();
  // clear dragging flag
  isDown=false;
  nearest=null;
  draw();
}

function handleMouseMove(e){
    if(!isDown){return;}
    // tell the browser we're handling this event
    e.preventDefault();
    e.stopPropagation();
    // mouse position
    mouseX=parseInt(e.clientX-offsetX);
    mouseY=parseInt(e.clientY-offsetY);
    // calc how far mouse has moved since last mousemove event
    var dx=mouseX-startX;
    var dy=mouseY-startY;
    startX=mouseX;
    startY=mouseY;
    // change nearest line vertices by distance moved
    var line=nearest.line;
    line.x0+=dx;
    line.y0+=dy;
    line.x1+=dx;
    line.y1+=dy;
    // redraw
    draw();
}
*/
