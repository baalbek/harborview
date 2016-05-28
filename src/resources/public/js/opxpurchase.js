var Opxpurchase = new function() {
    this.newOpxPurchaseOk = function(price,buy,volume,spot,purchaseType) {
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
        HARBORVIEW.Utils.jsonPUT("/opx/purchase",
                {opid: Opxpurchase.oid, 
                    price: price, 
                    buy: buy, 
                    volume: volume, 
                    spot: spot, 
                    ptype: purchaseType},
                function(result) {
            alert("New option Purchase: " + result.oid);
        });
        var cancel = document.getElementById("dlg1-cancel");
        cancel.click();
    };
    this.showNewOpxPurchase = function(oid,ticker) {
        $("#dlg1-header").html("Oid: " + oid + ", ticker: " + ticker);
        Opxpurchase.oid = oid
    };
    this.oid = undefined
}()

jQuery(document).ready(function() {
    $("body").on("click", "a.shownewopxpurchase", function() {
        var oid = $(this).attr("data-oid");
        var ticker = $(this).attr("data-ticker");
        Opxpurchase.showNewOpxPurchase(oid,ticker);
        return true;
    });
    $("body").on("click", "#dlg1-ok", function() {
        var pt = $("#dlg1-purchasetype").val();
        var price = $("#dlg1-price").val();
        var buy = $("#dlg1-buy").val();
        var vol = $("#dlg1-volume").val();
        var spot = $("#dlg1-spot").val();
        Opxpurchase.newOpxPurchaseOk(price,buy,vol,spot,pt);
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
    */
})
