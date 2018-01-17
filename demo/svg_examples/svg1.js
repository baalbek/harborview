document.addEventListener("DOMContentLoaded", function(event) {
  var svgLine = function(x1, y1, x2, y2) {
    var l = document.createElementNS("http://www.w3.org/2000/svg", "line");
    l.setAttribute("x1", x1);
    l.setAttribute("y1", y1);
    l.setAttribute("x2", x2);
    l.setAttribute("y2", y2);
    l.setAttribute("stroke", "red");
    l.setAttribute("stroke-width", 1);
    return l;
  }
  var addLine = function() {
    var curMarker = null;
    var curMarkerDown = function(e) {
      curMarker = e.target;
    }
    var curMarkerUp = function() {
      curMarker = null;
    }
    var l = svgLine("200", "20", "20", "200");
    var l50 = svgLine("110", "110", "1200", "110");
    var c1 = draggableMarker("1", l.getAttribute("x1"), l.getAttribute("y1"), curMarkerDown, curMarkerUp);
    var c2 = draggableMarker("2", l.getAttribute("x2"), l.getAttribute("y2"), curMarkerDown, curMarkerUp);

    var svg = document.getElementById("svg1");
    svg.addEventListener("mousemove", function(e) {
      if (curMarker !== null) {
        var x = e.offsetX;
        var y = e.offsetY;
        curMarker.setAttribute("cx", x);
        curMarker.setAttribute("cy", y);
        if (curMarker.id === "1") {
          l.setAttribute("x1", x);
          l.setAttribute("y1", y);
          var y0 = l.getAttribute("y2");
          var x0 = l.getAttribute("x2");
        } else {
          l.setAttribute("x2", x);
          l.setAttribute("y2", y);
          var y0 = l.getAttribute("y1");
          var x0 = l.getAttribute("x1");
        }

        var x50 = (Math.abs(x - x0) / 2.0) + Math.min(x, x0);
        var y50 = (Math.abs(y - y0) / 2.0) + Math.min(y, y0);
        l50.setAttribute("x1", x50);
        l50.setAttribute("y1", y50);
        l50.setAttribute("y2", y50);
      }
    });
    svg.appendChild(l);
    svg.appendChild(l50);
    svg.appendChild(c1);
    svg.appendChild(c2);
  };
  var btn = document.getElementById('newline');
  btn.onclick = addLine;

  drawCanvasRect();
  drawCanvasLine();

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
  ctx.moveTo(110, 110);
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