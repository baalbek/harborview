var MAUNALOA = MAUNALOA || {};

MAUNALOA.factory =  {
    hruler : null,
    vruler : null,
    repos1 : null,
    repos2 : null,
    canvasIds : { 
        DAY_LINES           : 'canvas1',
        DAY_LINES_OVERLAY   : 'canvas1x',
        DAY_VOLUME          : 'canvas1c',
        DAY_OSC             : 'canvas1b',
        WEEK_LINES          : 'canvas2',
        WEEK_LINES_OVERLAY  : 'canvas2x',
        WEEK_VOLUME         : 'canvas2c',
        WEEK_OSC            : 'canvas2b'
    },
    getCanvasIdFor : function(reposId) {
        if (reposId === 1) {
            return this.canvasIds.DAY_LINES_OVERLAY;
        }
        else {
            return this.canvasIds.WEEK_LINES_OVERLAY;
        }
    },
    initRepos : function(reposId) {
        var repos = reposId === 1 ? this.repos1 : this.repos2;
        var canvasId = reposId === 1 ? this.canvasIds.DAY_LINES_OVERLAY : this.canvasIds.WEEK_LINES_OVERLAY;
        if (repos === null) {
          console.log("Creating repos " + reposId);
          repos = MAUNALOA.repos.create(canvasId,this.vruler);
          if (reposId === 1) {
            this.repos1 = repos;
          }
          else {
            this.repos2 = repos;
          }
        }
        else {
          repos.reset();
        }
        return repos;
    },
    create : function(hruler,vruler) {
        var C = function() { 
            this.hruler = hruler;
            this.vruler = vruler;
            this.repos1 = null;
            this.repos2 = null;
        }
        C.prototype = MAUNALOA.factory;
        C.constructor.prototype = C;
        return new C();
    },
    dispose : function() {
        if (this.repos1 !== null) {
            this.repos1.dispose();
        }
        if (this.repos2 !== null) {
            this.repos2.dispose();
        }
    }

}
