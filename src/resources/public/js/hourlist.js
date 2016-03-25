var HourList = new function() {
    this.insert = function() {
        $.ajax({
            url: "/hourlist/insert",
            type: "PUT",
            dataType: "html",
            data: {
                    "fnr" : $("#fnr").val(),
                    "group" : $("#group").val(),
                    "curdate" : $("#curdate").val(),
                    "from_time" : $("#from_time").val(),
                    "to_time" : $("#to_time").val(),
                    "hours" : $("#hours").val(),
            },
            success: function(result) {
                $("#message").html(result);
            },
            error: this.onError
        })
    }
    this.groupSums = function() {
        $.ajax({
            url: "/hourlist/groupsums",
            type: "GET",
            dataType: "html",
            data: {
                "fnr" : $("#fnr").val(),
            },
            success: function(result) {
                $("#message").html(result);
            },
            error: this.onError
        })
    }
    this.overview = function() {
        $.ajax({
            url: "/hourlist/overview",
            type: "GET",
            dataType: "html",
            data: {
                "fnr" : $("#fnr").val(),
            },
            success: function(result) {
                $("#message").html(result);
            },
            error: this.onError
        })
    }
    this.onError = function(XMLHttpRequest, textStatus, errorThrown) {
        alert(textStatus);
        alert(errorThrown);
    }
}()

jQuery(document).ready(function() {
    $("#hourlist").click(function() {
        HourList.insert();
        return false;
    })
    $("#edithourlist").click(function() {
        HourList.edit();
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
