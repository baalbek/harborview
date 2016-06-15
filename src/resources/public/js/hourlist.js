var HourList = new function() {
    this.insert = function() {
        HARBORVIEW.Utils.htmlPUT("/hourlist/insert",
            {
                    "fnr" : $("#fnr").val(),
                    "group" : $("#group").val(),
                    "curdate" : $("#curdate").val(),
                    "from_time" : $("#from-time").val(),
                    "to_time" : $("#to-time").val(),
                    "hours" : $("#hours").val()
            },
            function(items) {
                $("#message").html(items);
            });
    }
    this.update = function() {
        HARBORVIEW.Utils.htmlPUT("/hourlist/update",
            {
                    "fnr" : $("#fnr").val(),
                    "group" : $("#group").val(),
                    "curdate" : $("#curdate").val(),
                    "from_time" : $("#from-time").val(),
                    "to_time" : $("#to-time").val(),
                    "hours" : $("#hours").val(),
                    "oid" : $("#oid").val()
            },
            function(items) {
                $("#message").html(items);
            });
    }
    this.newGroup = function() {
        HARBORVIEW.Utils.jsonPUT("/hourlist/newhourlistgroup", {"groupname": $("#hourlistgroup").val()}, function(result) {
            alert("New gourp id: " + result.oid);
        });
    }
    this.groupSums = function() {
        HARBORVIEW.Utils.htmlGET("/hourlist/groupsums",{"fnr" : $("#fnr").val()}, function(result) {
            $("#message").html(result);
        });
    }
    this.hourlistGroups = function() {
        HARBORVIEW.Utils.htmlGET("/hourlist/hourlistgroups",
        {"showinactive" : $("#showinactivegroups").is(":checked")},
        function(result) {
            $("#message").html(result);
        });
    }
    this.overview = function() {
        HARBORVIEW.Utils.htmlGET("/hourlist/overview",{"fnr" : $("#fnr").val(),}, function(result) {
            $("#message").html(result);
        });
    }
    this.toggleActiveGroup = function(oid,isActive) {
        HARBORVIEW.Utils.jsonPUT("/hourlist/togglegroup", {"oid": oid, "isactive": isActive}, function(items) {
            var cb = document.getElementById("group");
            HARBORVIEW.Utils.emptyHtmlOptions(cb);
            for (var i = 0; i < items.length; i++) {
                HARBORVIEW.Utils.addHtmlOption(cb,items[i].value,items[i].name);
            }
        });
    }
}()

jQuery(document).ready(function() {
    $("body").on("click", "a.loadhourlistdata", function() {
        $("#oid").val($(this).attr("data-oid"));
        $("#hours").val($(this).attr("data-hours"));
        $("#curdate").val($(this).attr("data-date"));
        $("#from-time").val($(this).attr("data-fromtime"));
        $("#to-time").val($(this).attr("data-totime"));
        $("#group").val($(this).attr("data-group"));
        return false;
    });
    $("#newhourlist").click(function() {
        HourList.insert();
        return false;
    });
    $("#updhourlist").click(function() {
        HourList.update();
        return false;
    });
    $("#newhourlistgroup").click(function() {
        HourList.newGroup();
        return false;
    });
    $("#fetchgroupsums").click(function() {
        HourList.groupSums();
        return false;
    });
    $("#fetchhourlistgroups").click(function() {
        HourList.hourlistGroups();
        return false;
    });
    $("#overview").click(function() {
        HourList.overview();
        return false;
    });
    $("body").on("change", ".group-active", function() {
        var oid = $(this).attr("data-oid");
        var isActive = $(this).is(":checked") === true ? "y" : "n";
        HourList.toggleActiveGroup(oid,isActive);
        return false;
    });
})
