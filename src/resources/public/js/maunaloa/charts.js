var MAUNALOA = MAUNALOA || {};


jQuery(document).ready(function() {
      /*
      $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
          var target = $(e.target).attr("href"); // activated tab
          alert(target);
      });
      */
      var repos1 = null;
      var repos2 = null;
      var node = document.getElementById('my-app');
      var app = Elm.Maunaloa.Charts.embed(node, {
          chartResolution : 1
      });

      var node2 = document.getElementById('my-app2');
      var app2 = Elm.Maunaloa.Charts.embed(node2, {
          chartResolution : 2
      });
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
          var cfg = { ci: chartInfo,
                      ch: chartInfo.chart,
                      cid:MAUNALOA.repos.DAY_LINES,
                      cidx:MAUNALOA.repos.DAY_LINES_OVERLAY,
                      reposId: 1,
                      isMain: true }
          drawCanvas(cfg);
          cfg.isMain = false;
          if (chartInfo.chart2 != null) {
            cfg.ch = chartInfo.chart2;
            cfg.cid =  MAUNALOA.repos.DAY_OSC;
            drawCanvas(cfg);
          }
          if (chartInfo.chart3 != null) {
            cfg.ch = chartInfo.chart3;
            cfg.cid =  MAUNALOA.repos.DAY_VOLUME;
            drawCanvas(cfg);
          }
      }
      var drawCanvas2 = function (chartInfo) {
          var cfg = { ci: chartInfo,
                      ch: chartInfo.chart,
                      cid:MAUNALOA.repos.WEEK_LINES,
                      cidx:MAUNALOA.repos.WEEK_LINES_OVERLAY,
                      reposId: 2,
                      isMain: true }
          drawCanvas(cfg);
          cfg.isMain = false;
          if (chartInfo.chart2 != null) {
            cfg.ch = chartInfo.chart2;
            cfg.cid = MAUNALOA.repos.WEEK_OSC;
            drawCanvas(cfg);
          }
          if (chartInfo.chart3 != null) {
            cfg.ch = chartInfo.chart3;
            cfg.cid = MAUNALOA.repos.WEEK_VOLUME;
            drawCanvas(cfg);
          }
      }
      app.ports.drawCanvas.subscribe(drawCanvas1);
      app2.ports.drawCanvas.subscribe(drawCanvas2);

      var clearCanvas = function(canvasId) {
        var canvas = document.getElementById(canvasId);
        var ctx = canvas.getContext("2d");
        ctx.clearRect(0,0,canvas.width,canvas.height);
        return [ctx,canvas];
      }
      var drawCanvas = function (cfg) {
        var chartInfo = cfg.ci;
        var curChart = cfg.ch;
        var offsets = chartInfo.xaxis;
        var ctx,canvas;
        [ctx,canvas] = clearCanvas(cfg.cid);

        var myHruler = MAUNALOA.hruler(1300,chartInfo.startdate,offsets,curChart.bars === null,5);
        myHruler.lines(ctx,canvas.height,chartInfo.numIncMonths);

        var myVruler = MAUNALOA.vruler(canvas.height,curChart.valueRange);
        myVruler.lines(ctx,canvas.width,curChart.numVlines);

        if (cfg.isMain === true) {
              /*
            if (factory !== null) {
                factory.dispose();
            }
            factory = MAUNALOA.factory.create(myHruler,myVruler);
              */
              /*
              if (cfg.reposId === 1) {
                repos1 = cfg.reposId === 1 ? repos1 : repos2;
                if (repos1 !== null) {
                  repos1.dispose();
                }
                else {
                  repos1 = MAUNALOA.repos.create(canvasId,this.hruler,this.vruler);
                }
              }
              */

              if (cfg.reposId === 1) {
                if (repos1 !== null) {
                  repos1.dispose();
                }
                repos1 = MAUNALOA.repos.create(cfg.cidx,myHruler,myVruler);
              }
              else {
                if (repos2 !== null) {
                  repos2.dispose();
                }
                // repos2 = MAUNALOA.repos.create(MAUNALOA.repos.WEEK_LINES_OVERLAY,myHruler,myVruler);
                repos2 = MAUNALOA.repos.create(cfg.cidx,myHruler,myVruler);
              }
              //clearCanvas(cfg.cidx);
        }

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
        drawRiscLines(riscLinesInfo,1);
      }
      var drawRiscLines2 = function(riscLinesInfo) {
        drawRiscLines(riscLinesInfo,2);
      }
      var drawRiscLines = function(riscLinesInfo,reposId) {
        var repos = reposId === 1 ? repos1 : repos2;
        if (repos === null) {
          alert("Repos not initialized! Aborting.")
          return;
        }
        repos.reset();
        var riscLines = riscLinesInfo.riscLines;
        for (var i=0; i<riscLines.length-1;++i) {
          var rl = riscLines[i];
          repos.addRiscLines(rl,false);
        }
        if (riscLines.length > 0) {
          var rlLast = riscLines[riscLines.length-1];
          repos.addRiscLines(rlLast,true);
        }
      }
      app.ports.drawRiscLines.subscribe(drawRiscLines1);
      app2.ports.drawRiscLines.subscribe(drawRiscLines2);

      <!------------- drawSpot ---------------->

      var drawSpot1 = function (spot) {
        repos1.addSpot(spot);
      }
      app.ports.drawSpot.subscribe(drawSpot1);
});
