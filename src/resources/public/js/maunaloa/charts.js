
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
      var repos1 = null;
      var repos2 = null;
      <!------------- canvas sizes ---------------->
      var setCanvasSize = function(selector,w,h) {
          var c1 = document.querySelectorAll(selector);
          for (var i=0; i<c1.length; ++i) {
            var canvas = c1[i];
            canvas.width = w;
            canvas.height = h;
          }
      }
      var setCanvasSizes = function() {
        setCanvasSize('canvas.c1',1310,500);
        setCanvasSize('canvas.c2',1310,200);
        setCanvasSize('canvas.c3',1310,110);
      }
      setCanvasSizes();
      <!------------- drawCanvas ---------------->
      var drawCanvas1 = function (chartInfo) {
          drawCanvas(chartInfo,chartInfo.chart,'canvas1');
          if (chartInfo.chart2 != null) {
            drawCanvas(chartInfo,chartInfo.chart2,'canvas1b');
          }
          if (chartInfo.chart3 != null) {
            drawCanvas(chartInfo,chartInfo.chart3,'canvas1c');
          }
          if (repos1 != null) {
            repos1.reset();
          }
      }
      var drawCanvas2 = function (chartInfo) {
          drawCanvas(chartInfo,chartInfo.chart,'canvas2');
          if (chartInfo.chart2 != null) {
            drawCanvas(chartInfo,chartInfo.chart2,'canvas2b');
          }
          if (chartInfo.chart3 != null) {
            drawCanvas(chartInfo,chartInfo.chart3,'canvas2c');
          }
          if (repos2 != null) {
            repos2.reset();
          }
      }
      app.ports.drawCanvas.subscribe(drawCanvas1);
      app2.ports.drawCanvas.subscribe(drawCanvas2);
      <!------------- drawSpot ---------------->
      var drawSpot1 = function (spot) {
        alert(spot.dx);
      }
      app.ports.drawSpot.subscribe(drawSpot1);

      var drawCanvas = function (chartInfo,curChart,canvasId) {
        var offsets = chartInfo.xaxis;
        var canvas = document.getElementById(canvasId);
        var ctx = canvas.getContext("2d");
        ctx.clearRect(0,0,canvas.width,canvas.height);

        var myHruler = MAUNALOA.hruler(1300,chartInfo.startdate,offsets,curChart.bars === null);
        myHruler.lines(ctx,canvas.height,chartInfo.numIncMonths);

        var myVruler = MAUNALOA.vruler(canvas.height,curChart.valueRange);
        myVruler.lines(ctx,canvas.width,curChart.numVlines);

        var lineChart = MAUNALOA.lineChart(myHruler,myVruler,ctx);
        var strokes = chartInfo.strokes;
        if (curChart.lines !== null) {
          for (var i=0;i<curChart.lines.length;++i) {
              var line = curChart.lines[i];
              var curStroke = strokes[i] === undefined ? "#000000" : strokes[i];
              lineChart.drawLine(line,curStroke);
          }
        }
        if (curChart.bars !== null) {
          for (var i=0;i<curChart.bars.length;++i) {
            lineChart.drawBars(curChart.bars[i]);
          }
        }

        if (curChart.candlesticks !== null) {
            lineChart.drawCandlesticks(curChart.candlesticks);
        }
      }

      <!------------- drawRiscLines ---------------->
      var drawRiscLines1 = function(riscLinesInfo) {
        drawRiscLines(riscLinesInfo,'canvas1x',1);
      }
      var drawRiscLines2 = function(riscLinesInfo) {
        drawRiscLines(riscLinesInfo,'canvas2x',2);
      }
      var drawRiscLines = function(riscLinesInfo,canvasId,reposId) {
        var canvas = document.getElementById(canvasId);
        var vruler = MAUNALOA.vruler(canvas.height,riscLinesInfo.valueRange);

        var repos = reposId === 1 ? repos1 : repos2;
        if (repos === null) {
          repos = MAUNALOA.repos.create(canvasId,vruler);
          if (reposId === 1) {
            repos1 = repos;
          }
          else {
            repos2 = repos;
          }
        }
        else {
          repos.reset();
          repos.vruler = vruler;
        }
        var riscLines = riscLinesInfo.riscLines;
        for (var i=0; i<riscLines.length-1;++i) {
          var rl = riscLines[i];
          //repos.addRiscLines(rl.ticker,rl.optionPrice,rl.risc,rl.be);
          repos.addRiscLines(rl,false);
        }
        if (riscLines.length > 0) {
          var rlLast = riscLines[riscLines.length-1];
          repos.addRiscLines(rlLast,true);
        }
      }
      app.ports.drawRiscLines.subscribe(drawRiscLines1);
      app2.ports.drawRiscLines.subscribe(drawRiscLines2);
});
