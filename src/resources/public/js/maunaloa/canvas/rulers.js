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

  var pixToValue = function(pix) {
    return double2decimal(maxVal - (pix / ppy));
  }
  var valueToPix = function(v) {
    return Math.round((maxVal - v) * ppy);
  }
  return {
    valueToPix : valueToPix,
    pixToValue : pixToValue
  }
}

MAUNALOA.hruler = function() {

}
