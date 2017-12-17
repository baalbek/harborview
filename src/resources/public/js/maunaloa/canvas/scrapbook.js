var MAUNALOA = MAUNALOA || {};


MAUNALOA.scrapbook = {
  create : function() {
    var F = function() {
    }
    F.prototype = MAUNALOA.scrapbook;
    F.constructor.prototype = F;
    var result = new F();
    return result;
  },
  init : function() {
    var scrapbook = document.getElementById("scrapbook");
    if (scrapbook !== null) {

      var c_scrap = document.getElementById(MAUNALOA.repos.DAY_LINES_OVERLAY_2);
      c_scrap.onclick = function() {
          var color = document.getElementById("color");
          alert("In Scrapbook: " + color.value + "!");
      }
      scrapbook.onchange = function() {
        var div_1x = document.getElementById("div-1x");
        var div_1scrap = document.getElementById("div-1scrap");
        if (scrapbook.checked === true) {
          div_1scrap.classList.add("top");
          div_1x.classList.remove("top");
        }
        else {
          div_1x.classList.add("top");
          div_1scrap.classList.remove("top");
        }
      }
    }
  }
}
