var MAUNALOA = MAUNALOA || {};

MAUNALOA.scrapbook = {
  /*
  create : function() {
    var F = function() {
    }
    F.prototype = MAUNALOA.scrapbook;
    F.constructor.prototype = F;
    var result = new F();
    return result;
  },
  */
  paint : false,
  init : function() {
    var scrapbook = document.getElementById("scrapbook");
    if (scrapbook !== null) {

      var c_scrap = document.getElementById(MAUNALOA.repos.DAY_LINES_OVERLAY_2);
      c_scrap.addEventListener('mousedown', this.handleMouseDown(this), false);

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
  },
  handleMouseDown : function(self) {
    return function(e) {
        console.log(self.paint);
    }
  }
}
