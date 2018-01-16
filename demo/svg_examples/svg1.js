document.addEventListener("DOMContentLoaded", function(event) {
  var addLine = function() {
    var l = document.createElementNS("http://www.w3.org/2000/svg", "line");
    l.setAttribute("x1", "20");
    l.setAttribute("y1", "20");
    l.setAttribute("x2", "100");
    l.setAttribute("y2", "100");
    l.setAttribute("stroke", "red");
    l.setAttribute("stroke-width", 10);
    l.addEventListener("mouseover", function(e) {
      l.setAttribute("stroke", "blue");

      var curcle = document.getElementById("curcle");

      var p0 = getNearestEndPoint(l, e);

      if (curcle === null) {
        var c = document.createElementNS("http://www.w3.org/2000/svg", "circle");
        c.setAttribute("id", "curcle");
        c.setAttribute("r", "10");
        c.setAttribute("stroke", "green");
        c.setAttribute("stroke-width", "1");
        c.setAttribute("fill", "transparent");
        c.setAttribute("cx", p0.cx);
        c.setAttribute("cy", p0.cy);
        c.addEventListener("mousedown", function(ce) {
          console.log(ce);
        });
        svg.appendChild(c);
      } else {
        curcle.setAttribute("cx", p0.cx);
        curcle.setAttribute("cy", p0.cy);
      }
    }, false);
    l.addEventListener("mouseout", function(e) {
      l.setAttribute("stroke", "red");
    }, false);
    var svg = document.getElementById("svg1");
    svg.appendChild(l);
    drawCanvasLine();
  };
  var btn = document.getElementById('newline');
  btn.onclick = addLine;

  drawCanvasRect();

});

var getNearestEndPoint = function(line, mouseEvent) {
  var x1 = line.getAttribute("x1");
  var y1 = line.getAttribute("y1");
  var x2 = line.getAttribute("x2");
  var y2 = line.getAttribute("y2");
  var deltaX1 = x1 - mouseEvent.offsetX;
  var deltaY1 = y1 - mouseEvent.offsetY;
  var deltaX2 = x2 - mouseEvent.offsetX;
  var deltaY2 = y2 - mouseEvent.offsetY;
  var dist1 = Math.sqrt((deltaX1 * deltaX1) + (deltaY1 * deltaY1));
  var dist2 = Math.sqrt((deltaX2 * deltaX2) + (deltaY2 * deltaY2));


  if (dist1 < dist2) {
    return {
      cx: x1,
      cy: y1
    };
  } else {
    return {
      cx: x2,
      cy: y2
    };
  }

}
var drawCanvasLine = function() {
  var canvas = document.getElementById('canvas1');
  var ctx = canvas.getContext("2d");
  ctx.strokeStyle = "red";
  ctx.beginPath();
  ctx.moveTo(105, 105);
  ctx.lineTo(200, 200);
  ctx.stroke();
}

var drawCanvasRect = function() {
  var canvas = document.getElementById('canvas1');
  var ctx = canvas.getContext("2d");
  ctx.strokeStyle = "red";
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(1200, 0);
  ctx.lineTo(1200, 300);
  ctx.lineTo(0, 300);
  ctx.lineTo(0, 0);
  ctx.stroke();
};