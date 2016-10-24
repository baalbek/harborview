var Vinapu = new function () {
    this.getProjectId = function() {
        return $("#projects").val();
    };
    this.getLocationId = function() {
        return $("#locations").val();
    };
    this.getSystemId = function() {
        return $("#systems").val();
    };
}()

jQuery(document).ready(function() {
    var fetchProjects = function() {
        HARBORVIEW.Utils.jsonGET("/vinapu/projects",{},
            function(items) {
                var cb = document.getElementById("projects");
                HARBORVIEW.Utils.emptyHtmlOptions(cb);
                HARBORVIEW.Utils.addHtmlOption(cb,"-1","-");
                for (var i = 0; i < items.length; i++) {
                    HARBORVIEW.Utils.addHtmlOption(cb,items[i].oid,items[i].text);
                }
            });
        return false;
    };
    var fetchLocations = function() {
        var oid = Vinapu.getProjectId();
        /*if (oid == "-1") return false;*/

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
        /*if (oid == "-1") return false;*/
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
    var fetchElementLoads = function() {
        var oid = Vinapu.getSystemId();
        /*if (oid == "-1") return false;*/
        HARBORVIEW.Utils.htmlGET("/vinapu/elementloads", {"oid": oid},
            function(result) {
                $("#elementloads").html(result);
            });
        return false;
    };

    $("#projects").change(function() {
        var cb = document.getElementById("systems");
        HARBORVIEW.Utils.emptyHtmlOptions(cb);
        $("#elementloads").html("");
        fetchLocations();
    });
    $("#locations").change(function() {
        $("#elementloads").html("");
        fetchSystems();
    });
    $("#systems").change(function() {
        fetchElementLoads();
    });
    /*-------------------- New Project -----------------------*/
    /*
    $("body").on("click", "a.shownewproject", function() {
        return true;
    });
    */
    $("body").on("click", "#dlg1-ok", function() {
        var pn = $("#dlg1-name").val();
        alert(pn);
        /*
        HARBORVIEW.Utils.htmlPUT(
            "/vinapu/newproject",
            {pn: },
            function(result) {
                var cb = document.getElementById("projects");
            });
        */
        var cancel = document.getElementById("dlg1-cancel");
        cancel.click();
        return true;
    });
    /*-------------------- New Location -----------------------*/
    $("body").on("click", "a.shownewlocation", function() {
        var oid = Vinapu.getProjectId();
        $("#dlg2-header").html("Project id: " + oid);
        return true;
    });
    /*-------------------- New System -----------------------*/
    $("body").on("click", "a.shownewsystem", function() {
        var oid = Vinapu.getLocationId();
        $("#dlg3-header").html("Location id: " + oid);
        return true;
    });
})
