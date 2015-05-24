
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
        HARBORVIEW.stearnswharf.fetchSteelElements(sys,$("#steelelements"));
    });
    //-------------------------------------- dlg1 --------------------------------
    $("#dlg1-qall").change(function() {
        var qa = $("#dlg1-qall").val();
        $("#dlg1-q1").val(qa);
        $("#dlg1-q2").val(qa);
        $("#dlg1-q3").val(qa);
        $("#dlg1-q4").val(qa);
    });
    $("#dlg1-close").click(function() {
        dlg1.close();
        return false;
    });
    $("#dlg1-ok").click(function() {
        var sys = $("#system").val();
        var steelBeam = $("#dlg1-steel").val();
        var nodes = [
            $("#dlg1-n1").val(),
            $("#dlg1-n2").val(),
            $("#dlg1-n3").val(),
            $("#dlg1-n4").val(),
            $("#dlg1-n5").val()
        ];
        var distLoads = [
            $("#dlg1-q1").val(),
            $("#dlg1-q2").val(),
            $("#dlg1-q3").val(),
            $("#dlg1-q4").val()
        ];
        var nodeLoads = [
            $("#dlg1-p1").val(),
            $("#dlg1-p2").val(),
            $("#dlg1-p3").val(),
            $("#dlg1-p4").val(),
            $("#dlg1-p5").val()
        ];
        var nodeLf = [
            $("#dlg1-p1-lf").val(),
            $("#dlg1-p2-lf").val(),
            $("#dlg1-p3-lf").val(),
            $("#dlg1-p4-lf").val(),
            $("#dlg1-p5-lf").val()
        ];
        HARBORVIEW.stearnswharf.newSteelElements(sys,
                                                steelBeam,
                                                nodes,
                                                distLoads,
                                                nodeLoads,
                                                nodeLf);
        dlg1.close();
        return false;
    });
    $("#shownewelement").click(function() {
        var elem = $(this)[0];
        var relTop = HARBORVIEW.utils.relativeTop(elem);
        dlg1.style.top = "" + relTop  + "px";
        var sys = $("#system").val();
        var nodes = [
            $("#dlg1-n1"),
            $("#dlg1-n2"),
            $("#dlg1-n3"),
            $("#dlg1-n4"),
            $("#dlg1-n5")
        ];
        var distLoads = [
            $("#dlg1-qall"),
            $("#dlg1-q1"),
            $("#dlg1-q2"),
            $("#dlg1-q3"),
            $("#dlg1-q4")
        ];
        $("#dlg1-header").html("System: " + sys);
        HARBORVIEW.nodes.fetchSystemNodes2(sys,1,nodes);
        HARBORVIEW.stearnswharf.fetchDistLoads(sys,distLoads);
        HARBORVIEW.stearnswharf.fetchSteelBeams($("#dlg1-steel"));
        dlg1.show();
        return false;
    });
    //-------------------------------------- dlg2 --------------------------------
    $("#dlg2-close").click(function() {
        dlg2.close();
        return false;
    });
    $("#dlg2-qx1").change(function() {
        $("#dlg2-qx2").val($("#dlg2-qx1").val());
    });
    $("#dlg2-qy1").change(function() {
        $("#dlg2-qy2").val($("#dlg2-qy1").val());
    });
    $("#dlg2-qz1").change(function() {
        $("#dlg2-qz2").val($("#dlg2-qz1").val());
    });
    $("#dlg2-ok").click(function() {
        var args = { "sysid" : $("#system").val(),
                    "qx1" : $("#dlg2-qx1").val(),
                    "qx2" : $("#dlg2-qx2").val(),
                    "qy1" : $("#dlg2-qy1").val(),
                    "qy2" : $("#dlg2-qy2").val(),
                    "qz1" : $("#dlg2-qz1").val(),
                    "qz2" : $("#dlg2-qz2").val(),
                    "lf" : $("#dlg2-lf").val() };
        HARBORVIEW.stearnswharf.newDistLoad(args);
        dlg2.close();
        return false;
    });
    $("#shownewdistload").click(function() {
        var elem = $(this)[0];
        var relTop = HARBORVIEW.utils.relativeTop(elem);
        dlg2.style.top = "" + relTop  + "px";
        var sys = $("#system").val();
        $("#dlg2-header").html("System: " + sys);
        dlg2.show();
        return false;
    });
});
