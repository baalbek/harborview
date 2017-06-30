
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
          drawCanvas(chartInfo,chartInfo.chart,'canvas1');
          if (chartInfo.chart2 != null) {
            drawCanvas(chartInfo,chartInfo.chart2,'canvas1b');
          }
      }
      var drawCanvas2 = function (chartInfo) {
          //drawCanvas(chartInfo,'canvas2','canvas2b');
      }
      app.ports.drawCanvas.subscribe(drawCanvas1);
      app2.ports.drawCanvas.subscribe(drawCanvas2);

      var drawCanvas = function (chartInfo,curChart,canvasId) {
        var offsets = chartInfo.xaxis;
        var canvas = document.getElementById(canvasId);
        var ctx = canvas.getContext("2d");
        ctx.clearRect(0,0,canvas.width,canvas.height);
        
        var myHruler = MAUNALOA.hruler(1300,chartInfo.startdate,offsets);
        myHruler.lines(ctx,canvas.height,chartInfo.numIncMonths);

        var myVruler = MAUNALOA.vruler(canvas.height,curChart.valueRange);
        myVruler.lines(ctx,canvas.width,curChart.numVlines);

        var lineChart = MAUNALOA.lineChart(myHruler,myVruler,ctx);
        var strokes = chartInfo.strokes;
        for (var i=0;i<curChart.lines.length;++i) {
            var line = curChart.lines[i];
            var curStroke = strokes[i] === undefined ? "#000000" : strokes[i];
            lineChart.drawLine(line,curStroke);
        }

        if (curChart.candlesticks != null) {
            lineChart.drawCandlesticks(curChart.candlesticks);
        }
      }
});
