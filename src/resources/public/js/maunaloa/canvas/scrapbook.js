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
  p1: null,
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
  },
  drawLine: function(self) {
    return function() {
      self.mode = self.MODE_LINE;
    }
  },
  drawArrowLine: function() {
    var ctx = this.ctx;
    ctx.beginPath();
    ctx.moveTo(70, 70);
    ctx.quadraticCurveTo(140, 105, 210, 20);
    ctx.lineTo(190, 25);
    ctx.moveTo(210, 20);
    ctx.lineTo(215, 35);
    ctx.stroke();
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
      if (self.id_canvas_0 !== null) {
        var canvas_0 = document.getElementById(self.id_canvas_0);
        newCtx.drawImage(canvas_0, 0, 0);
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
          //self.ctx.globalCompositeOperation = "xor";
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
          self.p1 = null;
          //self.ctx.globalCompositeOperation = "source-over";
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
      switch (self.mode) {
        case self.MODE_PAINT:
          self.addClick(e.offsetX, e.offsetY);
          self.redraw();
          break;
          /*
          case self.MODE_LINE_2:
            if (self.p1 !== null) {
              var context = self.ctx;
              context.beginPath();
              context.moveTo(self.p0.x, self.p0.y);
              context.lineTo(self.p1.x, self.p1.y);
              context.stroke();
            }
            self.p1 = {
              x: e.offsetX,
              y: e.offsetY
            }
            break;
            */
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