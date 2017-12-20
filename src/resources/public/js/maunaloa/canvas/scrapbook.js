var MAUNALOA = MAUNALOA || {};

MAUNALOA.scrapbook = {
  paint : false,
  clickX : null,
  clickY : null,
  //lines : [],
  ctx : null,
  init : function() {
    var scrapbook = document.getElementById("scrapbook");
    if (scrapbook !== null) {

      var c_scrap = document.getElementById(MAUNALOA.repos.DAY_LINES_OVERLAY_2);
      c_scrap.addEventListener('mousedown', this.handleMouseDown(this), false);
      c_scrap.addEventListener('mousemove', this.handleMouseMove(this), false);
      c_scrap.addEventListener('mouseup', this.handleMouseDone(this), false);
      c_scrap.addEventListener('mouseleave', this.handleMouseDone(this), false);
      this.ctx = c_scrap.getContext("2d");

      scrapbook.onchange = function() {
        var div_1x = document.getElementById("div-1x");
        var div_1scrap = document.getElementById("div-1scrap");
        if (scrapbook.checked === true) {
          div_1scrap.style.zIndex = "10";
          div_1x.style.zIndex = "0";
        }
        else {
          div_1x.style.zIndex = "10";
          div_1scrap.style.zIndex = "0";
        }
      }
    }
    var clearBtn = document.getElementById("btn-scrapbook-clear");
    if (clearBtn !== null) {
      clearBtn.onclick = this.clearCanvas;
    }
  },
  clearCanvas : function() {
    var self = MAUNALOA.scrapbook;
    var canvas = self.ctx.canvas;
    self.ctx.clearRect(0, 0, canvas.width, canvas.height)
  },
  addClick : function(x,y) {
    this.clickX.push(x);
    this.clickY.push(y);
  },
  redraw : function() {
      var context = this.ctx;
      var canvas = this.ctx.canvas;
      //context.clearRect(0, 0, canvas.width, canvas.height)
      context.strokeStyle = this.lineColor;
      context.lineJoin = "round";
      context.lineWidth = this.lineSize;
      var cx = this.clickX;
      var cy = this.clickY;
        context.beginPath();
        context.moveTo(cx[0], cy[0]);
        for(var i=1; i < cx.length; ++i) {
            context.lineTo(cx[i], cy[i]);
        }

    //context.closePath();
    context.stroke();
  },
  getLineSize : function() {
    var rgLine = document.querySelector('input[name="rg-line"]:checked').value;
    switch (rgLine) {
        case "1": return 1;
        case "2": return 3;
        case "3": return 7;
    }
  },
  lineSize : 3,
  lineColor : "#ff5c00",
    handleMouseDown : function(self) {
        return function(e) {
            self.paint = true;
            self.clickX = [];
            self.clickY = [];
            self.addClick(e.offsetX,e.offsetY);
            self.lineSize = self.getLineSize();
            self.lineColor = document.getElementById("color").value;

            //self.redraw(e);
        }
    },
  handleMouseMove : function(self) {
    return function(e) {
        if(self.paint){
            self.addClick(e.offsetX,e.offsetY);
            self.redraw();
        }
    }
  },
  handleMouseDone : function(self) {
    return function(e) {
        self.paint = false;
        self.clickX = null;
        self.clickY = null;
    }
  }
}
