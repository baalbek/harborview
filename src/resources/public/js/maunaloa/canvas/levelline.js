var MAUNALOA = MAUNALOA || {};

MAUNALOA.draggable = {
  // select the nearest line to the mouse
  closestLine : function (mx,my,lines){
    var dist=100000000;
    var index,pt;
    for(var i=0;i<lines.length;i++){
        var xy=closestXY(lines[i],mx,my);
        var dx=mx-xy.x;
        var dy=my-xy.y;
        var thisDist=dx*dx+dy*dy;
        if(thisDist<dist){
            dist=thisDist;
            pt=xy;
            index=i;
        }
    }
    var line=lines[index];
    return({ pt:pt, line:line, originalLine:{x0:line.x0,y0:line.y0,x1:line.x1,y1:line.y1} });
  }
};

MAUNALOA.levelLine = {
};


jQuery(document).ready(function() {

});
