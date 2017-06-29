var MAUNALOA = MAUNALOA || {};

MAUNALOA.lineChart = function(hruler,vruler,ctx) {
    var scale = function(line) {
        var result = []
        for (var i=0;i<line.length;++i) {
          result.push(vruler.valueToPix(line[i]));
        }
        return result;
    }
    var draw = function(line,strokeStyle,lineWidth=0.5) {
        ctx.lineWidth = 0.5;
        ctx.strokeStyle = strokeStyle; // "#FF0000";
        var ys = scale(line);
        var xs = hruler.xaxis;
        ctx.beginPath();
        ctx.moveTo(xs[0],ys[0]);
        for (var i = 1; i < ys.length; ++i) {
          var y = ys[i];
          var x = xs[i];
          ctx.lineTo(x,y);
        }
        ctx.stroke();
    }
    return {
        draw : draw
    }
}
