var MAUNALOA = MAUNALOA || {};

MAUNALOA.scrapbook = {
  MODE_NONE: 0,
  MODE_PAINT: 1,
  MODE_LINE: 2,
  MODE_LINE_2: 3,
  MODE_TEXT: 4,
  paint: false,
  mode: null,
  textMode: false,
  clickX: null,
  clickY: null,
  p0: null,
  ctx: null,
  id_rgLine: null,
  obj_comment: null,
  obj_color: null,
  create: function(param) {
    var SCRAPBOOK = function() {}
    SCRAPBOOK.prototype = MAUNALOA.scrapbook;
    SCRAPBOOK.constructor.prototype = SCRAPBOOK;
    var result = new SCRAPBOOK();
    result.init(param);
    return result;
  },
  init: function(param) {
    this.mode = this.MODE_NONE;
    this.obj_color = document.getElementById(param.id_color);
    this.obj_comment = document.getElementById(param.id_comment);
    this.id_rgLine = param.id_rgLine;
    var scrapbook = document.getElementById(param.id_checkbox);
    if (scrapbook !== null) {

      var c_scrap = document.getElementById(param.id_canvas);
      c_scrap.addEventListener('mousedown', this.handleMouseDown(this), false);
      c_scrap.addEventListener('mousemove', this.handleMouseMove(this), false);
      c_scrap.addEventListener('mouseup', this.handleMouseDone(this), false);
      c_scrap.addEventListener('mouseleave', this.handleMouseDone(this), false);
      this.ctx = c_scrap.getContext("2d");

      scrapbook.onchange = function() {
        var div_1x = document.getElementById(param.id_div1);
        var div_1scrap = document.getElementById(param.id_divScrap)
        if (scrapbook.checked === true) {
          div_1scrap.style.zIndex = "10";
          div_1x.style.zIndex = "0";
        } else {
          div_1x.style.zIndex = "10";
          div_1scrap.style.zIndex = "0";
        }
      }
    }
    var clearBtn = document.getElementById(param.id_clear);
    if (clearBtn !== null) {
      clearBtn.onclick = this.clearCanvas(this);
    }
    var textBtn = document.getElementById(param.id_text);
    if (textBtn !== null) {
      textBtn.onclick = this.placeText(this);
    }
    var lineBtn = document.getElementById(param.id_line);
    if (lineBtn !== null) {
      lineBtn.onclick = this.drawLine(this);
    }
  },
  drawLine: function(self) {
    return function() {
      self.mode = self.MODE_LINE;
    }
  },
  placeText: function(self) {
    return function() {
      self.mode = self.MODE_TEXT;
    }
  },
  clearCanvas: function(self) {
    return function() {
      var canvas = self.ctx.canvas;
      self.ctx.clearRect(0, 0, canvas.width, canvas.height)
    }
  },
  addClick: function(x, y) {
    this.clickX.push(x);
    this.clickY.push(y);
  },
  redraw: function() {
    var context = this.ctx;
    var canvas = this.ctx.canvas;
    context.strokeStyle = this.lineColor;
    context.lineJoin = "round";
    context.lineWidth = this.lineSize;
    var cx = this.clickX;
    var cy = this.clickY;
    context.beginPath();
    context.moveTo(cx[0], cy[0]);
    for (var i = 1; i < cx.length; ++i) {
      context.lineTo(cx[i], cy[i]);
    }
    context.stroke();
  },
  getLineSize: function() {
    var qry = 'input[name="' + this.id_rgLine + '"]:checked';
    var rgLine = document.querySelector(qry).value;
    switch (rgLine) {
      case "1":
        return 1;
      case "2":
        return 3;
      case "3":
        return 7;
    }
  },
  lineSize: 3,
  lineColor: "#ff5c00",
  handleMouseDown: function(self) {
    return function(e) {
      self.lineSize = self.getLineSize();
      //self.lineColor = document.getElementById(self.id_color).value;
      self.lineColor = self.obj_color.value; //document.getElementById(self.id_color).value;
      switch (self.mode) {
        case self.MODE_LINE:
          self.p0 = {
            x: e.offsetX,
            y: e.offsetY
          }
          self.mode = self.MODE_LINE_2;
          break;
        case self.MODE_LINE_2:
          var context = self.ctx;
          var canvas = self.ctx.canvas;
          context.strokeStyle = self.lineColor;
          context.lineJoin = "round";
          context.lineWidth = self.lineSize;
          context.beginPath();
          context.moveTo(self.p0.x, self.p0.y);
          context.lineTo(e.offsetX, e.offsetY);
          context.stroke();
          self.mode = self.MODE_NONE;
          break;
        case self.MODE_TEXT:
          self.mode = self.MODE_NONE;
          self.ctx.fillStyle = "#000";
          self.ctx.font = "16px Arial";
          var comment = self.obj_comment.value; //document.getElementById(self.id_comment).value;
          self.ctx.fillText(comment, e.offsetX, e.offsetY);
          break;
        default:
          self.mode = self.MODE_PAINT;
          self.clickX = [];
          self.clickY = [];
          self.addClick(e.offsetX, e.offsetY);
          break;
      }
    }
  },
  handleMouseMove: function(self) {
    return function(e) {
      if (self.mode === self.MODE_PAINT) {
        self.addClick(e.offsetX, e.offsetY);
        self.redraw();
      }
    }
  },
  handleMouseDone: function(self) {
    return function(e) {
      if (self.mode !== self.MODE_LINE_2) {
        self.mode = self.MODE_NONE;
        self.clickX = null;
        self.clickY = null;
      }
    }
  }
}