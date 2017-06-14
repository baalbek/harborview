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
    color : "black",
    lineWidth : 1,
    draggable : true,
    /*
    legend : function() {
      return this.levelValue;
    },
    */
    draw : function(repos) {
        var y = this.y1;
        var ctx = this.parent.ctx;

        ctx.lineWidth = this.lineWidth;
        ctx.beginPath();
        ctx.moveTo(this.x1,y);
        ctx.lineTo(this.x2,y);
        ctx.strokeStyle=this.color;
        ctx.stroke();
        ctx.fillText(this.legend(),this.x1,y-10);
        //ctx.fillText("[" + this.id + "] " + this.levelValue,this.x1,this.y-10);
    },
    move : function(dx,dy) {
        this.x1+=dx;
        this.x2+=dx;
        this.y1+=dy;
        this.y2+=dy;
        this.levelValue = this.parent.vruler.pixToValue(this.y2);
    },

    //create : function({parent,levelValue,x1,x2,y,draggable=true,legendFn=null,id=null}={}) {
    create : function(parent,levelValue,x1,x2,y,{draggable=true,color="grey",lineWidth=1,legendFn=null,onMouseUp=null,id=null}={}) {
        var result = Object.create(MAUNALOA.levelLine);
        result.parent = parent;
        if (id) {
          result.id = id;
        }
        result.levelValue = levelValue;
        result.lineWidth = lineWidth;
        result.color = color;
        result.x1 = x1;
        result.x2 = x2;
        result.y1 = y;
        result.y2 = y;
        result.legend = legendFn || function() { return this.levelValue; }
        result.draggable = draggable;
        result.onMouseUp = onMouseUp;
        return result;
    }
};


// https://stackoverflow.com/questions/9880279/how-do-i-add-a-simple-onclick-event-handler-to-a-canvas-element

MAUNALOA.repos = {
  init : function(canvasId,vruler) {
    this.canvas = document.getElementById(canvasId);
    this.ctx = this.canvas.getContext("2d");
    this.vruler = vruler;
    // listen for mouse events
    this.canvas.addEventListener('mouseup', this.handleMouseUp(this), false);
    this.canvas.addEventListener('mouseout', this.handleMouseOut(this), false);
    this.canvas.addEventListener('mousedown', this.handleMouseDown(this), false);
    this.canvas.addEventListener('mousemove', this.handleMouseMove(this), false);
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
      var line=self.nearest.line;
      if (line.onMouseUp != null) {
          line.onMouseUp();
      }
      self.isDown=false;
      self.nearest=null;
      /*
      var len = self.lines.length;
      for (var i=0; i<len; ++i) {
          if (self.lines[i].onMouseUp != null) {
              self.lines[i].onMouseUp();
          }
      }*/
      self.draw();
    }
  },
// dragging vars
  startX : 0,
  startY : 9,
  isDown : false,
  nearest : null,
  handleMouseDown : function(self) {
    return function(e) {
      // tell the browser we're handling this event
      e.preventDefault();
      e.stopPropagation();
      self.startX = e.offsetX;
      self.startY = e.offsetY;
      self.nearest=self.closestLine(e.offsetX,e.offsetY);
      self.draw();
      // set dragging flag
      self.isDown=true;
    }
  },
  handleMouseMove : function(self) {
    return function(e) {
      if(!self.isDown){return;}
      // tell the browser we're handling this event
      e.preventDefault();
      e.stopPropagation();
      // calc how far mouse has moved since last mousemove event
      var dx=e.offsetX-self.startX;
      var dy=e.offsetY-self.startY;
      self.startX=e.offsetX;
      self.startY=e.offsetY;
      // change nearest line vertices by distance moved
      var line=self.nearest.line;
      line.move(dx,dy);
      // redraw
      self. draw();
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
        var curLine = this.lines[i];
        if (curLine.draggable === false) {
          continue;
        }
        var xy=this.closestXY(curLine,mx,my);
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
    return({ pt:pt, line:line, originalLine:{x1:line.x1,y1:line.y1,x2:line.x2,y2:line.y2} });
  },
  draw : function() {
    this.ctx.clearRect(0,0,this.canvas.width,this.canvas.height);
    var len = this.lines.length;
    for (var i=0; i<len; ++i) {
        this.lines[i].draw();
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
  addLevelLine : function(lineId,levelValue,doDraw=true) {
    var result = MAUNALOA.levelLine.create(this,
                                            levelValue,
                                            20,
                                            this.canvas.width,
                                            this.vruler.valueToPix(levelValue),
                                            {id:lineId});
    this.lines.push(result);
    if (doDraw) {
      this.draw();
    }
  },
  addRiscLines : function(option,risc,riscLevel,breakEven,doDraw=true) {
    var riscLine = MAUNALOA.levelLine.create(this,
                                            riscLevel,
                                            20,
                                            this.canvas.width,
                                            this.vruler.valueToPix(riscLevel),
                                            {draggable:true,
                                            color:"red",
                                            lineWidth:2,
                                            legendFn:function() {
                                                var curRisc = this.risc || risc;
                                                return "[" + option + "] Risc: " + curRisc + " => " + this.levelValue;
                                            },
                                            onMouseUp:function(){
                                                this.risc = "-"; //this.levelValue;
                                                HARBORVIEW.Utils.jsonGET("http://192.168.1.55:8082/maunaloa/calcrisc", 
                                                    { "optype":"calls","ticker":,"stockprice": }, 
                                                    function(result) {
                                                        console.log("Risc result: " + result);
                                                        this.risc = result; 
                                                });
                                            }});
    this.lines.push(riscLine);
    var breakEvenLine = MAUNALOA.levelLine.create(this,breakEven,20,this.canvas.width,
                                            this.vruler.valueToPix(breakEven),
                                            {draggable:false,
                                            color:"green",
                                            lineWidth:2,
                                            legendFn:function() {
                                                return "[" + option + "] Break-even: " + this.levelValue;
                                            }});
    this.lines.push(breakEvenLine);
    if (doDraw) {
      this.draw();
    }
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
    r.addLevelLine(1,37,false);
    r.addRiscLines("YAR8C300",3.4,36,39);
    $("#button1").click(function() {
        HARBORVIEW.Utils.jsonGET("http://192.168.1.55:8082/maunaloa/demo", {}, function(result) {
          alert(result);
        });
    });
    //r.draw();
});
