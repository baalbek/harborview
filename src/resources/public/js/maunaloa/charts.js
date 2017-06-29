
jQuery(document).ready(function() {
      /*
      $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
          var target = $(e.target).attr("href"); // activated tab
          alert(target);
      });
      */
      var node = document.getElementById('my-app');
      var app = Elm.Maunaloa.Charts.embed(node, {
          isWeekly : false
      });

      var node2 = document.getElementById('my-app2');
      var app2 = Elm.Maunaloa.Charts.embed(node2, {
          isWeekly : true
      });
      var drawCanvas1 = function (chartInfo) {
          console.log("valueRange: " + chartInfo.chart.valueRange[0] + " - " + chartInfo.chart.valueRange[1]);
          drawCanvas(chartInfo,'canvas1','canvas1b');
      }
      var drawCanvas2 = function (chartInfo) {
          drawCanvas(chartInfo,'canvas2','canvas2b');
      }
      app.ports.drawCanvas.subscribe(drawCanvas1);
      app2.ports.drawCanvas.subscribe(drawCanvas2);

      var drawCanvas = function (chartInfo,canvasId,canvasId2) {
        var offsets = chartInfo.xaxis;
        var myHruler = MAUNALOA.hruler(1300,chartInfo.startdate,offsets);
        var canvas = document.getElementById(canvasId);
        var ctx = canvas.getContext("2d");
        ctx.clearRect(0,0,canvas.width,canvas.height);

        var curChart = chartInfo.chart;
        var myVruler = MAUNALOA.vruler(canvas.height,curChart.valueRange);
        myVruler.lines(ctx,canvas.width,curChart.numVlines);
        var lineChart = MAUNALOA.lineChart(myHruler,myVruler,ctx);
        var strokes = chartInfo.strokes;
        for (var i=0;i<curChart.lines.length;++i) {
            console.log("Drawing line");
            var line = curChart.lines[i];
            var curStroke = strokes[i] === undefined ? "#000000" : strokes[i];
            lineChart.draw(line,curStroke);
        }

        /*
        drawChart(canvasId,chartInfo,myHruler,chartInfo.chart);
        if (chartInfo.chart2 != null) {
          drawChart(canvasId2,chartInfo,myHruler,chartInfo.chart2);
        }
        */
      }
      /*
      var drawLines = function (ctx,xaxis,curLines,strokes) {
        for (var i = 0; i < curLines.length; ++i) {
            ctx.beginPath();
            var curStroke = strokes[i] === undefined ? "#000000" : strokes[i];
            var ys = curLines[i];
            drawGraph(ctx,xaxis,ys,curStroke);
        }
      }
      var day_millis = 86400000;
      var incMonths = function(origDate,numMonths) {
          return new Date(origDate.getFullYear(),origDate.getMonth()+numMonths,1);
      }
      var diffDays = function(d0,d1) {
          return (d1 - d0) / day_millis;
      }
      var date2string = function(d) {
          return (d.getMonth()+1) + "." + d.getFullYear();
      }
      var hrulerLines = function(ctx,hruler,canvas,numIncMonths) {
          var d0 = hruler.startDate;
          ctx.fillStyle = "black";
          ctx.font = "16px Arial";
          ctx.strokeStyle = "#bbb";
          ctx.lineWidth = 0.25;
          var d0x = incMonths(d0,numIncMonths);
          var txtY = canvas.height - 5;
          var curX = 0;
          while (curX < canvas.width) {
              curX = hruler.dateToPix(d0x);
              // console.log("Canvas width: " + canvas.width + ", curX: " + curX);
              ctx.beginPath();
              ctx.moveTo(curX,0);
              ctx.lineTo(curX,canvas.height);
              ctx.stroke();
              ctx.fillText(date2string(d0x),curX+5,txtY);
              d0x = incMonths(d0x,numIncMonths);
          }
      }

      var double2decimal = function(x,roundingFactor) {
          var rf = roundingFactor || 100;
          return (Math.round(x*rf))/rf;
      }
      var vrulerLines = function(ctx,chart,canvas) {
        ctx.fillStyle = "black";
        ctx.font = "16px Arial";
        ctx.strokeStyle = "#bbb";
        ctx.lineWidth = 0.25;
        var minVal = chart.valueRange[0];
        var maxVal = chart.valueRange[1];
        var ppy = chart.height / (maxVal - minVal);
        var step = chart.height / (chart.numVlines - 1);
        var ix = chart.numVlines;
        for (var i=0; i<ix; ++i) {
            var curStep = step * i;
            var curVal = double2decimal(maxVal - (curStep / ppy));
            ctx.beginPath();
            ctx.moveTo(0,curStep);
            ctx.lineTo(canvas.width,curStep);
            if (i===0) {
              ctx.fillText(curVal,10,curStep+18);
            }
            else {
              ctx.fillText(curVal,10,curStep-5);
            }
            ctx.stroke();
        }
      }

      var drawChart = function(canvasId,chartInfo,hruler,chart) {
          var canvas = document.getElementById(canvasId);
          var ctx = canvas.getContext("2d");
          ctx.clearRect(0,0,canvas.width,canvas.height);
          if (chart.lines != null) {
            drawLines(ctx,hruler.xaxis,chart.lines,chartInfo.strokes);
          }
          if (chart.candlesticks != null) {
              ctx.strokeStyle = "#000000";
              ctx.fillStyle = "#ffaa00";
              ctx.lineWidth = 0.5;
              var numCandlesticks = chart.candlesticks.length;
              for (var i = 0; i < numCandlesticks; ++i) {
                drawCandlestick(ctx,hruler.xaxis[i],chart.candlesticks[i]);
              }
          }

          vrulerLines(ctx,chart,canvas);
          hrulerLines(ctx,hruler,canvas,chartInfo.numIncMonths);
       }

      var createHruler = function(width,startDateAsMillis,offsets) {
          var x0 = offsets[offsets.length-1];
          var x1 = offsets[0] + 5;
          var diffDays = x1 - x0;
          var ppx = width / diffDays;

          //console.log("startDateAsMillis: " + startDateAsMillis);
          var startDate = new Date(startDateAsMillis);

          var calcPix = function(x) {
            var curDiffDays = x-x0;
            //console.log("x0: " + x0 + ", x: " + x + ", curDiffDays: " + curDiffDays);
            return ppx * curDiffDays;
          }
          var dateToPix = function(d) {
            //console.log("d: " + d + ", startDate: " + startDate);
            var curOffset = x0 + ((d - startDate) / day_millis);
            //console.log("curOffset: " + curOffset);
            return calcPix(curOffset);
          }
          var offsetsToPix = function() {
            //console.log("Calculating offsetsToPix...");
            var result = [];
            for (var i=0;i<offsets.length;++i)  {
                result[i] = calcPix(offsets[i]);
            }
            return result;
          }
          var xaxis = offsetsToPix();
          return {
            dateToPix : dateToPix,
            xaxis : xaxis,
            startDate : startDate
          }
      }

      var drawCanvas = function (chartInfo,canvasId,canvasId2) {
        var offsets = chartInfo.xaxis;
        var myHruler = createHruler(1300,chartInfo.startdate,offsets);
        drawChart(canvasId,chartInfo,myHruler,chartInfo.chart);
        if (chartInfo.chart2 != null) {
          drawChart(canvasId2,chartInfo,myHruler,chartInfo.chart2);
        }
      }
      app.ports.drawCanvas.subscribe(drawCanvas1);
      app2.ports.drawCanvas.subscribe(drawCanvas2);

      var drawGraph = function (ctx,xs,ys,strokeStyle) {
        ctx.lineWidth = 0.5;
        // ctx.setLineDash([5,10]);
        ctx.strokeStyle = strokeStyle; // "#FF0000";
        ctx.moveTo(xs[0],ys[0]);
        for (var i = 1; i < ys.length; ++i) {
          var y = ys[i];
          var x = xs[i];
          ctx.lineTo(x,y);
        }
        ctx.stroke();
      }

      var drawCandlestick = function(ctx,x,candleStick) {
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
    */
});
