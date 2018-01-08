document.addEventListener("DOMContentLoaded", function(event) {
  var addLine = function() {
    var l = document.createElementNS('http://www.w3.org/2000/svg', 'line');
    l.setAttribute("x1", "20");
    l.setAttribute("y1", "20");
    l.setAttribute("x2", "100");
    l.setAttribute("y2", "20");
    l.setAttribute("stroke", "red");
    l.setAttribute("stroke-width", 10);
    l.addEventListener('mouseover', function() {
      l.setAttribute("stroke", "blue");
    }, false);
    l.addEventListener('mouseout', function() {
      l.setAttribute("stroke", "red");
    }, false);
    var svg = document.getElementById("svg1");
    svg.appendChild(l);
  };
  var btn = document.getElementById('newline');
  btn.onclick = addLine;

  var canvas = document.getElementById('canvas1');
  var ctx = canvas.getContext("2d");
  ctx.lineTo(0, 0);
  ctx.moveTo(1200, 0);
  ctx.moveTo(1200, 300);
  ctx.moveTo(0, 300);
  ctx.moveTo(0, 0);
  ctx.stroke();

});