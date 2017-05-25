var MAUNALOA = MAUNALOA || {};

/*
MAUNALOA.draggable = {
  lerp : function(a,b,x){
    return(a+x*(b-a));
  },
  shortestDistance : function(mx,my) {
    var dx=this.x2-this.x1;
    var dy=this.y2-this.y1;
    var t=((mx-this.x1)*dx+(my-this.y1)*dy)/(dx*dx+dy*dy);
    t=Math.max(0,Math.min(1,t));
    var x=this.lerp(this.x1,this.x2,t);
    var y=this.lerp(this.y1,this.y2,t);
    return({x:x,y:y});
  },
};
*/

MAUNALOA.levelLine = {
    color : "red",
    draggable : true,
    legend : function() {
      return this.levelValue;
    },
    draw : function(repos) {
        var y = this.y1;
        var ctx = repos.ctx;
        ctx.beginPath();
        ctx.moveTo(this.x1,y);
        ctx.lineTo(this.x2,y);
        ctx.strokeStyle=this.color;
        ctx.stroke();
        ctx.fillText(this.legend(),this.x1,y-10);
        //ctx.fillText("[" + this.id + "] " + this.levelValue,this.x1,this.y-10);
    }
    /*
    create : function(levelValue) {
        var result = Object.create(MAUNALOA.levelLine);
    }
    */
};


// https://stackoverflow.com/questions/9880279/how-do-i-add-a-simple-onclick-event-handler-to-a-canvas-element

MAUNALOA.repos = {
  init : function(canvasId,vruler) {
    this.canvas = document.getElementById(canvasId);
    this.ctx = this.canvas.getContext("2d");
    this.vruler = vruler;

    /* No need for this
    var clientRect = canvas.getBoundingClientRect();
    this.offsetX = clientRect.left;
    this.offsetY = clientRect.top;
    */
    // listen for mouse events
    this.canvas.addEventListener('mouseup', this.handleMouseUp(this), false);
    this.canvas.addEventListener('mouseout', this.handleMouseOut(this), false);
    this.canvas.addEventListener('mousedown', this.handleMouseDown(this), false);
    this.canvas.addEventListener('mousemove', this.handleMouseMove(this), false);
    //this.canvas.mousedown(function(e){handleMouseDown(e);});
    //this.canvas.mousemove(function(e){handleMouseMove(e);});
    //this.canvas.mouseup(this.handleMouseUpOut(this));
    //this.canvas.mouseout(function(e){handleMouseUpOut(e);});
  },
  handleMouseOut : function(self) {
    return function(e) {
      e.preventDefault();
      e.stopPropagation();
    }
  },
  handleMouseUp : function(self) {
    return function(e) {
      // tell the browser we're handling this event
      e.preventDefault();
      e.stopPropagation();
    }
  },
  isDown : false,
  nearest : null,
  handleMouseDown : function(self) {
    return function(e) {
      // tell the browser we're handling this event
      e.preventDefault();
      e.stopPropagation();
      self.nearest=self.closestLine(e.offsetX,e.offsetY);
      self.draw();
      // set dragging flag
      self.isDown=true;
    }
  },
  handleMouseMove : function(self) {
    return function(e) {
      // tell the browser we're handling this event
      e.preventDefault();
      e.stopPropagation();
    }
  },
  lines : [],
  // linear interpolation -- needed in setClosestLine()
  lerp : function(a,b,x){
    return(a+x*(b-a));
  },
  // find closest XY on line to mouse XY
  closestXY : function(line,mx,my){
    var x0=line.x1;
    var y0=line.y1;
    var x1=line.x2;
    var y1=line.y2;
    var dx=x1-x0;
    var dy=y1-y0;
    var t=((mx-x0)*dx+(my-y0)*dy)/(dx*dx+dy*dy);
    t=Math.max(0,Math.min(1,t));
    var x=this.lerp(x0,x1,t);
    var y=this.lerp(y0,y1,t);
    return({x:x,y:y});
  },
  // select the nearest line to the mouse
  closestLine : function (mx,my,lines){
    var len = this.lines.length;
    if (len === 0) {
      return null;
    }
    var dist=100000000;
    var index,pt;
    for(var i=0;i<len;i++){
        var xy=this.closestXY(this.lines[i],mx,my);
        var dx=mx-xy.x;
        var dy=my-xy.y;
        var thisDist=dx*dx+dy*dy;
        if(thisDist<dist){
            dist=thisDist;
            pt=xy;
            index=i;
        }
    }
    var line=this.lines[index];
    return({ pt:pt, line:line, originalLine:{x0:line.x1,y0:line.y1,x1:line.x2,y1:line.y2} });
  },
  draw : function() {
    this.ctx.clearRect(0,0,this.canvas.width,this.canvas.height);
    var len = this.lines.length;
    for (var i=0; i<len; ++i) {
        this.lines[i].draw(this);
    }
    // draw markers if a line is being dragged
    if(this.nearest){
        // point on line nearest to mouse
        this.ctx.beginPath();
        this.ctx.arc(this.nearest.pt.x,this.nearest.pt.y,5,0,Math.PI*2);
        this.ctx.strokeStyle='red';
        this.ctx.stroke();
        /*
        // marker for original line before dragging
        drawLine(nearest.originalLine,'red');
        // hightlight the line as its dragged
        drawLine(nearest.line,'red');
        */
    }
  },
  create : function(canvasId,vruler) {
    var result = Object.create(MAUNALOA.repos);
    result.init(canvasId,vruler);
    return result;
  },
  addLevelLine : function(lineId,levelValue) {
    /*
    var result = Object.create(MAUNALOA.levelLine, {
                                  y1 : {
                                          get: function() {return this.y;},
                                          set: function(value) {this.y=value;},
                                        },
                                  y2 : {
                                          get: function() {return this.y;},
                                          set: function(value) {this.y=value;},
                                        },
    */
    var result = Object.create(MAUNALOA.levelLine);
    result.id = lineId;
    result.levelValue = levelValue;
    result.x1 = 20;
    result.x2 = this.canvas.width;
    result.y1 = this.vruler.valueToPix(levelValue);
    result.y2 = result.y1;
    this.lines.push(result);
    this.draw();
  }
}


MAUNALOA.vruler = function(chartInfo) {
  var double2decimal = function(x,roundingFactor) {
      var rf = roundingFactor || 100;
      return (Math.round(x*rf))/rf;
  }
  var chart = chartInfo.chart;
  var minVal = chart.valueRange[0];
  var maxVal = chart.valueRange[1];
  var ppy = chart.height / (maxVal - minVal);

  console.log("ppy: " + ppy);

  var pixToValue = function(pix) {
    return double2decimal(maxVal - (pix / ppy));
  }
  var valueToPix = function(v) {
    return Math.round((maxVal - v) * ppy);
  }
  return {
    valueToPix : valueToPix,
    pixToValue : pixToValue
  }
}

    var chartInfo = {
        chart : {
          valueRange : [35,40],
          height : 300
        }
    }
jQuery(document).ready(function() {
    var vruler = MAUNALOA.vruler(chartInfo);
    var r = MAUNALOA.repos.create("canvas0",vruler);
    r.addLevelLine(1,37);
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
