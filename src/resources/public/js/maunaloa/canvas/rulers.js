var MAUNALOA = MAUNALOA || {};


MAUNALOA.vruler = function(chartHeight,valueRange) {
  var double2decimal = function(x,roundingFactor) {
      var rf = roundingFactor || 100;
      return (Math.round(x*rf))/rf;
  }
  var minVal = valueRange[0];
  var maxVal = valueRange[1];
  var ppy = chartHeight / (maxVal - minVal);

  console.log("ppy: " + ppy);

  var lines = function(ctx,chartWidth,numVlines) {
    ctx.fillStyle = "black";
    ctx.font = "16px Arial";
    ctx.strokeStyle = "#bbb";
    ctx.lineWidth = 0.25;
    var step = chartHeight / (numVlines - 1);
    for (var i=0; i<numVlines; ++i) {
        var curStep = step * i;
        var curVal = double2decimal(maxVal - (curStep / ppy));
        ctx.beginPath();
        ctx.moveTo(0,curStep);
        ctx.lineTo(chartWidth,curStep);
        if (i===0) {
          ctx.fillText(curVal,10,curStep+18);
        }
        else {
          ctx.fillText(curVal,10,curStep-5);
        }
        ctx.stroke();
    }
  }
  var pixToValue = function(pix) {
    return double2decimal(maxVal - (pix / ppy));
  }
  var valueToPix = function(v) {
    return Math.round((maxVal - v) * ppy);
  }
  return {
    valueToPix : valueToPix,
    pixToValue : pixToValue,
    lines : lines
  }
}


MAUNALOA.hruler = function(width,startDateAsMillis,offsets) {
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
