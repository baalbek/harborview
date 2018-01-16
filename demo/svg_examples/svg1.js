document.addEventListener("DOMContentLoaded", function(event) {
  var addLine = function() {
    var curMarker = null;
    var curMarkerDown = function(e) {
      curMarker = e.target;
      console.log(curMarker.id);
    }
    var curMarkerUp = function() {
      console.log(curMarker.id);
      curMarker = null;
    }
    var l = document.createElementNS("http://www.w3.org/2000/svg", "line");
    l.setAttribute("x1", "20");
    l.setAttribute("y1", "20");
    l.setAttribute("x2", "100");
    l.setAttribute("y2", "100");
    l.setAttribute("stroke", "red");
    l.setAttribute("stroke-width", 2);
    var c1 = draggableMarker("1", l.getAttribute("x1"), l.getAttribute("y1"), curMarkerDown, curMarkerUp);
    var c2 = draggableMarker("2", l.getAttribute("x2"), l.getAttribute("y2"), curMarkerDown, curMarkerUp);

    var svg = document.getElementById("svg1");
    svg.addEventListener("mousemove", function(e) {
      if (curMarker !== null) {
        curMarker.setAttribute("cx", e.offsetX);
        curMarker.setAttribute("cy", e.offsetY);
        console.log(curMarker.id);
        if (curMarker.id === "1") {
          l.setAttribute("x1", e.offsetX);
          l.setAttribute("y1", e.offsetY);
        } else {
          l.setAttribute("x2", e.offsetX);
          l.setAttribute("y2", e.offsetY);
        }
      }
    });
    svg.appendChild(l);
    svg.appendChild(c1);
    svg.appendChild(c2);
    drawCanvasLine();
  };
  var btn = document.getElementById('newline');
  btn.onclick = addLine;

  drawCanvasRect();

});

var draggableMarker = function(id, cx, cy, fnDown, fnUp) {
  var c = document.createElementNS("http://www.w3.org/2000/svg", "circle");
  //c.setAttribute("id", "");
  c.id = id;
  c.setAttribute("r", "5");
  c.setAttribute("stroke", "green");
  c.setAttribute("stroke-width", "1");
  c.setAttribute("fill", "transparent");
  c.setAttribute("cx", cx);
  c.setAttribute("cy", cy);
  c.setAttribute("class", "draggable");
  c.addEventListener("mousedown", fnDown);
  c.addEventListener("mouseup", fnUp);
  return c;
}

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
      cy: y1,
      lend: 1
    };
  } else {
    return {
      cx: x2,
      cy: y2,
      lend: 2
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