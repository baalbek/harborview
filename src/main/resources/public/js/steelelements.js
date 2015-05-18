
jQuery(document).ready(function() {
    var dlg1 = document.querySelector("#dlg1");
    var dlg2 = document.querySelector("#dlg2");
    $("#project").change(function() {
        var pid = $("#project").val();
        HARBORVIEW.buildings.fetchBuildings(pid,$("#building"));
    });
    $("#floorplan").change(function() {
        var bid = $("#building").val();
        var fid = $("#floorplan").val();
        HARBORVIEW.stearnswharf.fetchElementSystems(bid,fid,$("#system"));
    });
    $("#system").change(function() {
        var sys = $("#system").val();
        //HARBORVIEW.stearnswharf.fetchSteelElements(sys,$("#system"));
    });
    //-------------------------------------- dlg1 --------------------------------
    $("#dlg1-close").click(function() {
        dlg1.close();
        return false;
    });
    $("#shownewelement").click(function() {
        var elem = $(this)[0];
        var relTop = HARBORVIEW.utils.relativeTop(elem);
        dlg1.style.top = "" + relTop  + "px";
        var sys = $("#system").val();
        var n1 = $("#dlg1-n1");
        var n2 = $("#dlg1-n2");
        var nodes = [
            $("#dlg1-n1"),
            $("#dlg1-n2"),
            $("#dlg1-n3"),
            $("#dlg1-n4"),
            $("#dlg1-n5")
        ];
        $("#dlg1-header").html("System: " + sys);
        HARBORVIEW.nodes.fetchSystemNodes(sys,nodes);
        dlg1.show();
        return false;
    });
});
