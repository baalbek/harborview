var MAUNALOA = MAUNALOA || {};

describe("Maunaloa.Cache", function() {
    var date = new Date(2017,6,1);
    var tm = date.getTime();
    var offsets = [9,8,7,6,5,4,3,2,1,0];
    var hruler = MAUNALOA.hruler(1200,tm,offsets,true,0);;
    var vruler = MAUNALOA.vruler(1000,[0,100]);
    var factory;

    beforeEach(function() {
        factory = MAUNALOA.factory.create(hruler,vruler);
        console.log(factory);
    });

    it("should be able to manage a repos", function() {
        var r = factory.initRepos(1); 
        expect(r.lines.length).toEqual(0);
        r.lines.push(1);

        var r2 = factory.initRepos(2); 
        expect(r.lines.length).toEqual(1);
        expect(r2.lines.length).toEqual(0);

        var rx = factory.initRepos(1); 
        expect(rx).toEqual(r);
    });
});

