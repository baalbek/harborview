var MAUNALOA = MAUNALOA || {};

describe("Maunaloa.Rulers", function() {

    describe("hruler", function() {
        var hruler;
        var date;
        var tm;
        var offsets;
        beforeEach(function() {
            date = new Date(2017,6,1);
            tm = date.getTime();
            offsets = [];
            for (var i=10; i>=0; --i) {
                offsets.push(i);
            } 
            hruler = MAUNALOA.hruler(1200,tm,offsets,true,0);
        });

        it("should be able to calculate date to pix", function() {
            var dx = new Date(2017,6,1);
            var pix = hruler.dateToPix(dx);
            expect(pix).toEqual(0);

            dx = new Date(2017,6,6);
            pix = hruler.dateToPix(dx);
            expect(pix).toEqual(600);

            dx = new Date(2017,6,11);
            pix = hruler.dateToPix(dx);
            expect(pix).toEqual(1200);
        });
    });
    describe("vruler", function() {
        var vruler;
        beforeEach(function() {
            vruler = new MAUNALOA.vruler(1000,[0,100]);
        });
        it("should be able to calculate value to pix", function() {
            var pix = vruler.valueToPix(0);
            expect(pix).toEqual(1000);

            var pix = vruler.valueToPix(50);
            expect(pix).toEqual(500);

            var pix = vruler.valueToPix(100);
            expect(pix).toEqual(0);
        });
        it("should be able to calculate pix to value", function() {
            var val = vruler.pixToValue(0);
            expect(val).toEqual(100);

            val = vruler.pixToValue(500);
            expect(val).toEqual(50);

            val = vruler.pixToValue(1000);
            expect(val).toEqual(0);
        });
    });
});
