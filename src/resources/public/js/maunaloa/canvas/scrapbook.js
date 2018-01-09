var MAUNALOA = MAUNALOA || {};

MAUNALOA.scrapbook = {
  MODE_NONE: 0,
  MODE_PAINT: 1,
  MODE_LINE: 2,
  MODE_LINE_2: 3,
  MODE_TEXT: 4,
  MODE_ARROW: 5,
  MODE_HORIZ: 6,
  MODE_HORIZ_2: 7,
  paint: false,
  mode: null,
  textMode: false,
  clickX: null,
  clickY: null,
  p0: null,
  //p1: null,
  ctx: null,
  id_rgLine: null,
  id_canvas_0: null,
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
    this.id_canvas_0 = param.id_canvas_0;
    this.obj_color = document.getElementById(param.id_color);
    this.obj_comment = document.getElementById(param.id_comment);
    this.obj_arrow_orient = document.getElementById(param.id_arrow_orient);
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
    var saveBtn = document.getElementById(param.id_save);
    if (saveBtn !== null) {
      saveBtn.onclick = this.saveCanvas(this);
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
    var arrowBtn = document.getElementById(param.id_arrow);
    if (arrowBtn !== null) {
      arrowBtn.onclick = this.drawArrowLine(this);
    }
    var horizBtn = document.getElementById(param.id_horiz);
    if (horizBtn !== null) {
      horizBtn.onclick = this.drawHorizLine(this);
    }
  },
  drawLine: function(self) {
    return function() {
      self.mode = self.MODE_LINE;
    }
  },
  drawArrowLine_: function(ctx, x, y, comment, orientation) {
    var x1 = x - 140;
    var y1 = y + 50;
    var x2 = x - 105;
    var y2 = y + 120;
    var x3 = x - 20;
    var y3 = y + 5;
    var x4 = x + 5;
    var y4 = y + 15;
    var x5 = x - 160;
    var y5 = y + 40;
    switch (orientation) {
      case "NW":
        var ty = 2 * y;
        y1 = ty - y1;
        y2 = ty - y2;
        y3 = ty - y3;
        y4 = ty - y4;
        y5 = ty - y5 + 10;
        break;
      case "NE":
        var tx = 2 * x;
        var ty = 2 * y;
        x1 = tx - x1;
        y1 = ty - y1;
        x2 = tx - x2;
        y2 = ty - y2;
        x3 = tx - x3;
        y3 = ty - y3;
        x4 = tx - x4;
        y4 = ty - y4;
        x5 = tx - x5 - 100;
        y5 = ty - y5 + 10;
        break;
      case "SE":
        var tx = 2 * x;
        x1 = tx - x1;
        x2 = tx - x2;
        x3 = tx - x3;
        x4 = tx - x4;
        x5 = tx - x5 - 100;
        break;
    }
    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.quadraticCurveTo(x2, y2, x, y);
    ctx.lineTo(x3, y3);
    ctx.moveTo(x, y);
    ctx.lineTo(x4, y4);
    ctx.stroke();
    ctx.fillText(comment, x5, y5);
  },
  drawArrowLine: function(self) {
    return function() {
      self.mode = self.MODE_ARROW;
    }
  },
  drawHorizLine: function(self) {
    return function() {
      self.mode = self.MODE_HORIZ;
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
  saveCanvas: function(self) {
    return function() {
      var canvas = self.ctx.canvas; //document.getElementById('canvas');
      var newCanvas = document.createElement('canvas');
      newCanvas.width = canvas.width;
      newCanvas.height = canvas.height;
      var newCtx = newCanvas.getContext("2d");
      newCtx.fillStyle = "FloralWhite";
      newCtx.fillRect(0, 0, canvas.width, canvas.height);
      newCtx.drawImage(canvas, 0, 0);
      /*
      if (self.id_canvas_0 !== null) {
        var canvas_0 = document.getElementById(self.id_canvas_0);
        newCtx.drawImage(canvas_0, 0, 0);
      }
      */
      var c0s = self.id_canvas_0;
      if (c0s !== null) {
        for (var i=0; i<c0s.length; ++i) {
            var canvas_0 = document.getElementById(c0s[i]);
            newCtx.drawImage(canvas_0, 0, 0);
        }
      }
      newCanvas.toBlob(function(blob) {
        var newImg = document.createElement('img');
        var url = URL.createObjectURL(blob);
        var a = document.createElement("a");
        a.href = url;
        a.download = "scrap.png";
        document.body.appendChild(a);
        a.click();
        setTimeout(function() {
          document.body.removeChild(a);
          window.URL.revokeObjectURL(url);
        }, 0);
      });
      newCanvas.remove();
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
          self.p0 = null;
          self.mode = self.MODE_NONE;
          break;
        case self.MODE_TEXT:
          self.mode = self.MODE_NONE;
          self.ctx.fillStyle = "#000";
          self.ctx.font = "16px Arial";
          var comment = self.obj_comment.value; //document.getElementById(self.id_comment).value;
          self.ctx.fillText(comment, e.offsetX, e.offsetY);
          break;
        case self.MODE_ARROW:
          self.ctx.fillStyle = self.lineColor;
          self.ctx.strokeStyle = self.lineColor;
          self.ctx.lineWidth = self.lineSize;
          self.ctx.font = "16px Arial";
          self.drawArrowLine_(self.ctx, e.offsetX, e.offsetY, self.obj_comment.value, self.obj_arrow_orient.value);
          self.mode = self.MODE_NONE;
          break;
        case self.MODE_HORIZ:
          self.p0 = {
            x: e.offsetX,
            y: e.offsetY
          }
          self.mode = self.MODE_HORIZ_2;
          break;
        case self.MODE_HORIZ_2:
          var context = self.ctx;
          var canvas = self.ctx.canvas;
          context.strokeStyle = self.lineColor;
          context.lineJoin = "round";
          context.lineWidth = self.lineSize;
          context.beginPath();
          context.moveTo(self.p0.x, self.p0.y);
          context.lineTo(e.offsetX, self.p0.y);
          context.stroke();
          self.p0 = null;
          self.mode = self.MODE_NONE;
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
      switch (self.mode) {
        case self.MODE_PAINT:
          self.addClick(e.offsetX, e.offsetY);
          self.redraw();
          break;
      }
    }
  },
  handleMouseDone: function(self) {
    return function(e) {
      switch (self.mode) {
        case self.MODE_PAINT:
          self.clickX = null;
          self.clickY = null;
          self.mode = self.MODE_NONE;
          break;
      }
    }
  }
}
