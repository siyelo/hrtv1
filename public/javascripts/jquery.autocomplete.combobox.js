(function( $ ) {
    $.widget( "ui.combobox", {
      _create: function() {
        var self = this,
          select = this.element.hide(),
          selected = select.children( ":selected" ),
          value = selected.val() ? selected.text() : "";
        var input = this.input = $( "<input>" )
          .insertAfter( select )
          .val( value )
          .autocomplete({
            delay: 300, //otherwise when you type a long string, it crawls
            minLength: 2, // for performance
            source: function( request, response ) {
                var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
                var select_el = select.get(0); // get dom element
                var rep = new Array(); // response array
                var maxRepSize = 30; // maximum response size
                // simple loop for the options
                for (var i = 0; i < select_el.length; i++) {
                    var text = select_el.options[i].text;
                    if ( select_el.options[i].value && ( !request.term || matcher.test(text) ) ) {
                        // add element to result array
                        rep.push({
                            label: text, // no more bold
                            value: text,
                            option: select_el.options[i]
                        });
                    }
                    if ( rep.length > maxRepSize ) {
                        rep.push({
                            label: "... more available",
                            value: "maxRepSizeReached",
                            option: ""
                        });
                        break;
                    }
                 }

                  if (rep.length === 0) {
                      rep.push({
                          label:'&lt;Create new <strong>'+ input.val() +'</strong>&gt;',
                          value: input.val(),
                          option: null
                      });
                  }
                 // send response
                 response( rep );
            },
            select: function( event, ui ) {
                if ( ui.item.value == "maxRepSizeReached") {
                    return false;
                } else {
                    if (ui.item.option) {
                      ui.item.option.selected = true;
                      self._trigger( "selected", event, {
                          item: ui.item.option
                      });
                    } else {
                      var option = $('<option/>').val(ui.item.value)
                      select.append(option)
                      option[0].selected = true;
                    }
                }
            },
            focus: function( event, ui ) {
                if ( ui.item.value == "maxRepSizeReached") {
                    return false;
                }
            },
            change: function( event, ui ) {
              if ( !ui.item && $(this).val() != "" ) {
                var matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( $(this).val() ) + "$", "i" ),
                  valid = false;
                select.children( "option" ).each(function() {
                  if ( $( this ).text().match( matcher ) ) {
                    this.selected = valid = true;
                    return false;
                  }
                });
                if ( !valid ) {
                  // Trigger the event for value not found
                  $(select).trigger('autocompletenotfound', $(this).val());

                  // remove invalid value, as it didn't match anything
                  $( this ).val( "" );
                  select.val( "" );
                  input.data( "autocomplete" ).term = "";
                  return false;
                }
              }
            }
          })
          .addClass( "ui-widget ui-widget-content ui-corner-left" );

        input.data( "autocomplete" )._renderItem = function( ul, item ) {
          return $( "<li></li>" )
            .data( "item.autocomplete", item )
            .append( "<a>" + item.label + "</a>" )
            .appendTo( ul );
        };
      },

      destroy: function() {
        this.input.remove();
        // NOTE: original file change here with this condition
        if (typeof(this.button) !== 'undefined') {
          this.button.remove();
        }
        this.element.show();
        $.Widget.prototype.destroy.call( this );
      }
    });
  })( jQuery );
