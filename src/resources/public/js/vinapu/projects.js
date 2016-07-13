var Vinapu = new function () {
    this.getProjectId = function() {
        return $("#projects").val();
    };
    this.getLocationId = function() {
        return $("#locations").val();
    };
}()

jQuery(document).ready(function() {
    var fetchLocations = function() {
        var oid = Vinapu.getProjectId();
        if (oid == "-1") return false;

        HARBORVIEW.Utils.jsonGET("/vinapu/locations",{"oid": oid},
            function(items) {
            var cb = document.getElementById("locations");
            HARBORVIEW.Utils.emptyHtmlOptions(cb);
            HARBORVIEW.Utils.addHtmlOption(cb,"-1","-");
            for (var i = 0; i < items.length; i++) {
                HARBORVIEW.Utils.addHtmlOption(cb,items[i].oid,items[i].text);
            }
        });

        return false;
    };
    var fetchSystems = function() {
        var oid = Vinapu.getLocationId();
        if (oid == "-1") return false;
        HARBORVIEW.Utils.jsonGET("/vinapu/systems",{"oid": oid},
            function(items) {
            var cb = document.getElementById("systems");
            HARBORVIEW.Utils.emptyHtmlOptions(cb);
            HARBORVIEW.Utils.addHtmlOption(cb,"-1","-");
            for (var i = 0; i < items.length; i++) {
                HARBORVIEW.Utils.addHtmlOption(cb,items[i].oid,items[i].text);
            }
        });

        return false;
    };
    $("#projects").change(function() {
        fetchLocations();
    });
    $("#locations").change(function() {
        fetchSystems();
    });
    $("#systems").change(function() {
    });
})
