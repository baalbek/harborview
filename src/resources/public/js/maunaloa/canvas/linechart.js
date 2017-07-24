var MAUNALOA = MAUNALOA || {};

MAUNALOA.lineChart = function(hruler,vruler,ctx) {
    var scaleLine = function(line) {
        var result = []
        for (var i=0;i<line.length;++i) {
          result.push(vruler.valueToPix(line[i]));
        }
        return result;
    }
    var drawLine = function(line,strokeStyle,lineWidth) {
        ctx.lineWidth = lineWidth || 0.5;
        ctx.strokeStyle = strokeStyle; // "#FF0000";
        var ys = scaleLine(line);
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
    var scaleCandlestick = function(candleStick) {
        var o = vruler.valueToPix(candleStick.o);
        var h = vruler.valueToPix(candleStick.h);
        var l = vruler.valueToPix(candleStick.l);
        var c = vruler.valueToPix(candleStick.c);
        return { o : o,
                 h : h,
                 l : l,
                 c : c};
    }
    var scaleCandlesticks = function(cs) {
        var result = []
        for (var i=0;i<cs.length;++i) {
          result.push(scaleCandlestick(cs[i]));
        }
        return result;
    }
    var drawCandlestick = function(x,candleStick) {
      var x0 = x - 4;
      ctx.beginPath();

      if (candleStick.c > candleStick.o) {
          // Bearish
          ctx.moveTo(x,candleStick.h);
          ctx.lineTo(x,candleStick.o);
          ctx.moveTo(x,candleStick.c);
          ctx.lineTo(x,candleStick.l);
          var cndlHeight = candleStick.c - candleStick.o;
          ctx.rect(x0,candleStick.o,8,cndlHeight);
          ctx.fillRect(x0,candleStick.o,8,cndlHeight);
      }
      else {
          // Bullish
          var cndlHeight = candleStick.o - candleStick.c;
          // If doji
          if (cndlHeight === 0.0) {
            cndlHeight = 1.0;
            var x1 = x + 4;
            ctx.moveTo(x,candleStick.h);
            ctx.lineTo(x,candleStick.l);
            ctx.moveTo(x0,candleStick.c);
            ctx.lineTo(x1,candleStick.c);
          }
          else {
            ctx.moveTo(x,candleStick.h);
            ctx.lineTo(x,candleStick.c);
            ctx.moveTo(x,candleStick.o);
            ctx.lineTo(x,candleStick.l);
            ctx.rect(x0,candleStick.c,8,cndlHeight);
          }
      }
      ctx.stroke();
    }
    var drawCandlesticks = function(cs) {
      ctx.strokeStyle = "#000000";
      ctx.fillStyle = "#ffaa00";
      ctx.lineWidth = 0.5;
      var xs = hruler.xaxis;
      var scs = scaleCandlesticks(cs);
      var numCandlesticks = scs.length;
      for (var i = 0; i < numCandlesticks; ++i) {
        drawCandlestick(xs[i],scs[i]);
      }
    }
    var scaleBars = function(bars) {
        //var o = vruler.valueToPix(candleStick.o);
        var result = []
        for (var i=0;i<bars.length;++i) {
          result.push(vruler.valueToPix(bars[i]));
        }
        return result;
    }
    var drawBar = function(x,bar) {
      ctx.beginPath();
      ctx.moveTo(x,vruler.bottom);
      ctx.lineTo(x,bar);
      ctx.stroke();
    }
    var drawBars = function(bars) {
      ctx.strokeStyle = "#ff0000";
      //ctx.fillStyle = "#ffaa00";
      ctx.lineWidth = 0.5;

      var xs = hruler.xaxis;
      var sbars = scaleBars(bars);
      var numBars = sbars.length;
      for (var i = 0; i < numBars; ++i) {
        drawBar(xs[i],sbars[i]);
      }
    }
    return {
        drawLine : drawLine,
        drawCandlesticks : drawCandlesticks,
        drawBars : drawBars
    }
}
