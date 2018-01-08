var MAUNALOA = MAUNALOA || {};

MAUNALOA.levelLine = {
  color: "black",
  lineWidth: 1,
  draggable: true,
  draw: function() {
    var y = this.y1;
    var ctx = this.parent.ctx;

    ctx.lineWidth = this.lineWidth;
    ctx.beginPath();
    ctx.moveTo(this.x1, y);
    ctx.lineTo(this.x2, y);
    ctx.strokeStyle = this.color;
    ctx.stroke();
    ctx.fillText(this.legend(), this.x1, y - 10);
  },
  move: function(dx, dy) {
    this.x1 += dx;
    this.x2 += dx;
    this.y1 += dy;
    this.y2 += dy;
    this.levelValue = this.parent.vruler.pixToValue(this.y2);
  },

  //create : function(parent,levelValue,x1,x2,y,
  //      {draggable=true,color="grey",lineWidth=1,legendFn=null,onMouseUp=null,id=null}={}) {
  create: function(parent, levelValue, x1, x2, y, conf) {
    var LL = function() {};
    LL.prototype = MAUNALOA.levelLine;
    LL.constructor.prototype = LL;
    var result = new LL();
    //var result = Object.create(MAUNALOA.levelLine);
    result.parent = parent;
    //result.id = conf.id;
    result.levelValue = levelValue;
    result.lineWidth = conf.lineWidth || 1;
    result.color = conf.color || "grey";
    result.x1 = x1;
    result.x2 = x2;
    result.y1 = y;
    result.y2 = y;
    result.legend = conf.legendFn || function() {
      return this.levelValue;
    }
    result.draggable = conf.hasOwnProperty('draggable') == true ? conf.draggable : true;
    result.onMouseUp = conf.onMouseUp || null;
    return result;
  }
};


// https://stackoverflow.com/questions/9880279/how-do-i-add-a-simple-onclick-event-handler-to-a-canvas-element

MAUNALOA.repos = {
  DAY_LINES: 'canvas1',
  DAY_LINES_OVERLAY: 'canvas1x',
  DAY_LINES_OVERLAY_2: 'canvas1-scrap',
  DAY_VOLUME: 'canvas1c',
  DAY_OSC: 'canvas1b',
  WEEK_LINES: 'canvas2',
  WEEK_LINES_OVERLAY: 'canvas2x',
  WEEK_LINES_OVERLAY_2: 'canvas2-scrap',
  WEEK_VOLUME: 'canvas2c',
  WEEK_OSC: 'canvas2b',
  MONTH_LINES: 'canvas3',
  MONTH_LINES_OVERLAY: 'canvas3x',
  MONTH_VOLUME: 'canvas3c',
  MONTH_OSC: 'canvas3b',
  init: function(canvasId, hruler, vruler) {
    this.canvas = document.getElementById(canvasId);
    if (this.canvas === null) {
      this.ctx = null;
      return;
    }
    this.ctx = this.canvas.getContext("2d");
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    this.vruler = vruler;
    this.hruler = hruler;
    // listen for mouse events
    this.mup = this.handleMouseUp(this);
    this.mdo = this.handleMouseDown(this);
    this.mmo = this.handleMouseMove(this);
    this.canvas.addEventListener('mouseup', this.mup, false);
    this.canvas.addEventListener('mousedown', this.mdo, false);
    this.canvas.addEventListener('mousemove', this.mmo, false);
  },
  dispose: function() {
    this.canvas.removeEventListener('mouseup', this.mup, false);
    this.canvas.removeEventListener('mousedown', this.mdo, false);
    this.canvas.removeEventListener('mousemove', this.mmo, false);
    this.reset();
  },
  reset: function() {
    this.lines = [];
    if (this.ctx !== null) {
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    }
  },
  handleMouseOut: function(self) {
    return function(e) {
      e.preventDefault();
      e.stopPropagation();
    }
  },
  handleMouseUp: function(self) {
    return function(e) {
      if (self.nearest === null) {
        return;
      }
      // tell the browser we're handling this event
      e.preventDefault();
      e.stopPropagation();
      var line = self.nearest.line;
      if (line.onMouseUp != null) {
        line.onMouseUp();
      }
      self.isDown = false;
      self.nearest = null;
      self.draw();
    }
  },
  // dragging vars
  startX: 0,
  startY: 9,
  isDown: false,
  nearest: null,
  handleMouseDown: function(self) {
    return function(e) {
      if (self.lines.length === 0) {
        return;
      }
      // tell the browser we're handling this event
      e.preventDefault();
      e.stopPropagation();
      self.startX = e.offsetX;
      self.startY = e.offsetY;
      self.nearest = self.closestLine(e.offsetX, e.offsetY);
      self.draw();
      // set dragging flag
      self.isDown = true;
    }
  },
  handleMouseMove: function(self) {
    return function(e) {
      if (!self.isDown) {
        return;
      }
      if (self.nearest === null) {
        return;
      }

      // tell the browser we're handling this event
      e.preventDefault();
      e.stopPropagation();
      // calc how far mouse has moved since last mousemove event
      var dx = e.offsetX - self.startX;
      var dy = e.offsetY - self.startY;
      self.startX = e.offsetX;
      self.startY = e.offsetY;
      // change nearest line vertices by distance moved
      var line = self.nearest.line;
      line.move(dx, dy);
      // redraw
      self.draw();
    }
  },
  lerp: function(a, b, x) {
    return (a + x * (b - a));
  },
  // find closest XY on line to mouse XY
  closestXY: function(line, mx, my) {
    var x0 = line.x1;
    var y0 = line.y1;
    var x1 = line.x2;
    var y1 = line.y2;
    var dx = x1 - x0;
    var dy = y1 - y0;
    var t = ((mx - x0) * dx + (my - y0) * dy) / (dx * dx + dy * dy);
    t = Math.max(0, Math.min(1, t));
    var x = this.lerp(x0, x1, t);
    var y = this.lerp(y0, y1, t);
    return ({
      x: x,
      y: y
    });
  },
  // select the nearest line to the mouse
  closestLine: function(mx, my, lines) {
    var len = this.lines.length;
    if (len === 0) {
      return null;
    }
    var dist = 100000000;
    var index, pt;
    for (var i = 0; i < len; i++) {
      var curLine = this.lines[i];
      if (curLine.draggable === false) {
        continue;
      }
      var xy = this.closestXY(curLine, mx, my);
      var dx = mx - xy.x;
      var dy = my - xy.y;
      var thisDist = dx * dx + dy * dy;
      if (thisDist < dist) {
        dist = thisDist;
        pt = xy;
        index = i;
      }
    }
    var line = this.lines[index];
    return ({
      pt: pt,
      line: line,
      originalLine: {
        x1: line.x1,
        y1: line.y1,
        x2: line.x2,
        y2: line.y2
      }
    });
  },
  draw: function() {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    var len = this.lines.length;
    for (var i = 0; i < len; ++i) {
      this.lines[i].draw();
    }
    if (this.spot !== null) {
      var lineChart = MAUNALOA.lineChart(this.hruler, this.vruler, this.ctx);
      lineChart.drawCandlestick(this.spot);
    }
    // draw markers if a line is being dragged
    if (this.nearest) {
      // point on line nearest to mouse
      this.ctx.beginPath();
      this.ctx.arc(this.nearest.pt.x, this.nearest.pt.y, 5, 0, Math.PI * 2);
      this.ctx.strokeStyle = 'red';
      this.ctx.stroke();
      /*
      // marker for original line before dragging
      drawLine(nearest.originalLine,'red');
      // hightlight the line as its dragged
      drawLine(nearest.line,'red');
      */
    }
  },
  create: function(canvasId, hruler, vruler) {
    var F = function() {
      this.lines = [];
      this.spot = null;
    }
    F.prototype = MAUNALOA.repos;
    F.constructor.prototype = F;
    var result = new F();
    result.init(canvasId, hruler, vruler);
    return result;
  },
  addSpot: function(spot) {
    this.spot = spot;
    this.draw();
  },
  addLevelLine: function(levelPix, doDraw) {
    var levelValue = this.vruler.pixToValue(levelPix);
    var myDoDraw = doDraw || true;
    var result = MAUNALOA.levelLine.create(this,
      levelValue,
      20,
      this.canvas.width,
      levelPix, {});
    this.lines.push(result);
    if (myDoDraw) {
      this.draw();
    }
  },
  //addRiscLines : function(option,risc,riscLevel,breakEven,doDraw) {
  addRiscLines: function(cfg, doDraw) {
    var riscLine = MAUNALOA.levelLine.create(this,
      cfg.stockPrice,
      100,
      this.canvas.width,
      this.vruler.valueToPix(cfg.stockPrice), {
        draggable: true,
        color: "red",
        lineWidth: 2,
        legendFn: function() {
          var curRisc = this.risc || cfg.risc;
          var curOptionPrice = this.optionPrice || cfg.optionPrice;
          return "[" + cfg.ticker + "] Price: " + curOptionPrice + ", Risc: " + curRisc + " => " + this.levelValue;
        },
        onMouseUp: function() {
          this.risc = "-";
          var self = this;
          //HARBORVIEW.Utils.jsonGET("https://andromeda/maunaloa/optionprice",
          HARBORVIEW.Utils.jsonGET("http://localhost:8082/maunaloa/optionprice", {
              "ticker": cfg.ticker,
              "stockprice": this.levelValue
            },
            function(result) {
              self.risc = parseFloat(result.risc);
              self.optionPrice = parseFloat(result.optionprice);
              self.parent.draw();
            });
        }
      });
    this.lines.push(riscLine);
    var breakEven = cfg.be;
    var breakEvenLine = MAUNALOA.levelLine.create(this, breakEven, 100, this.canvas.width,
      this.vruler.valueToPix(breakEven), {
        draggable: false,
        color: "green",
        lineWidth: 2,
        legendFn: function() {
          return "[" + cfg.ticker + "] Ask: " + cfg.ask + ", Break-even: " + this.levelValue;
        }
      });
    this.lines.push(breakEvenLine);
    if (doDraw === true) {
      this.draw();
    }
  }
}