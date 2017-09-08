var MAUNALOA = MAUNALOA || {};

MAUNALOA.cache =  {
    hruler : null,
    vruler : null,
    repos1 : null,
    repos2 : null,
    getRepos : function(reposId) {

    },
    create : function(hruler,vruler) {
        var C = function() { 
            this.hruler = hruler;
            this.hruler = hruler;
            this.repos1 = null;
            this.repos2 = null;
        }
        C.prototype = MAUNALOA.cache;
        C.constructor.prototype = C;
        return new C();
    }
}
