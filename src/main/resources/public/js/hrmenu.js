
var cbpHorizontalMenu = (function() {
    var current = -1;

    var _items = null;
    function myItems() {
        if (_items == null) {
            var listItems = $( '#hrmenu > ul > li' )
                menuItems = listItems.children('a');
            _items ={ listItems : listItems,
                    menuItems : menuItems };
        }
        return _items;
    }
	function init() {
        var items = myItems();
		items.menuItems.on( 'click', open );
		items.listItems.on( 'click', function( event ) { event.stopPropagation(); } );
	}

	function open( event ) {
        var $body = $('body');

		if( current !== -1 ) {
			myItems().listItems.eq( current ).removeClass( 'hropen' );
		}

		var $item = $( event.currentTarget ).parent( 'li' ),
			idx = $item.index();

		if( current === idx ) {
			$item.removeClass( 'hropen' );
			current = -1;
		}
		else {
			$item.addClass( 'hropen' );
			current = idx;
			$body.off( 'click' ).on( 'click', close );
		}
		return false;
	}

	function close( event ) {
        myItems().listItems.eq(current).removeClass('hropen');
		current = -1;
	}

	return { init : init };
})();
jQuery(document).ready(function() {
    cbpHorizontalMenu.init();
})

