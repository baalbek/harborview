var Opxpurchase = new function() {
    this.current_oid = "-99"
    this.newOpxPurchaseOk = function() {
        /*
        $.ajax({
                url: "/opx/purchase",
                type: "PUT",
                dataType: "json",
                data: {"opid"       : $("#nopOpid").val(),
                    "price"         : $("#nopPrice").val(),
                    "buy"           : $("#nopBuy").val(),
                    "volume"        : $("#nopVolume").val(),
                    "spot"          : $("#nopSpot").val(),
                    "ptype" : $("#nopPurchaseType").val()},
                success: function(result) {
                    alert(result.oid);
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    alert(textStatus);
                    alert(errorThrown);
                }
            });
        */
        /*$(this).dialog("close");*/
    };
    this.showNewOpxPurchase = function(oid) {
        $("#dlg1-header").html("Oid: " + oid);
    };
}()

jQuery(document).ready(function() {
    $("body").on("click", "a.shownewopxpurchase", function() {
        var oid = $(this).attr("data-oid");
        Opxpurchase.showNewOpxPurchase(oid);
        return true;
    });
    /*
    $("#dlg1-ok").click(function() {
        alert($("#dlg1-purchasetype").val());
        dlg1.close();
        return false;
    });
    $("#dlg1-close").click(function() {
        dlg1.close();
        return false;
    });
    //*/
})
