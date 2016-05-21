var HourList = new function() {
    this.insert = function() {
        HARBORVIEW.Utils.htmlPUT("/hourlist/insert",
            {
                    "fnr" : $("#fnr").val(),
                    "group" : $("#group").val(),
                    "curdate" : $("#curdate").val(),
                    "from_time" : $("#from-time").val(),
                    "to_time" : $("#to-time").val(),
                    "hours" : $("#hours").val(),
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
    this.overview = function() {
        HARBORVIEW.Utils.htmlGET("/hourlist/overview",{"fnr" : $("#fnr").val(),}, function(result) {
            $("#message").html(result);
        });
    }
    this.onError = function(XMLHttpRequest, textStatus, errorThrown) {
        alert(textStatus);
        alert(errorThrown);
    }
}()

jQuery(document).ready(function() {
    $("#newhourlist").click(function() {
        HourList.insert();
        return false;
    })
    $("#newhourlistgroup").click(function() {
        HourList.newGroup();
        return false;
    })
    $("#fetchgroupsums").click(function() {
        HourList.groupSums();
        return false;
    })
    $("#overview").click(function() {
        HourList.overview();
        return false;
    })
})
