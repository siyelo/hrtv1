var purposes = {
  type: 'multi',
  lastIndex: 0,
  lastId: '',

  resetMcdropdown: function (mcdropdown) {
    // reset and focus search
    mcdropdown.find('input:hidden').val('');
    mcdropdown.find('input.purpose_search').val('');
    mcdropdown.find('input.purpose_search').focus(); // focus
    //mcdropdown.find('a').trigger('click');

    $('.mcdropdown_autocomplete').hide();

    // triger ESC event on mcdropdown
    e = $.Event('keypress');
    e.which = 27; // ESC
    mcdropdown.find('input.purpose_search').trigger(e);
  },

  initMcDropdown: function (elements) {
    clone = $("#purpose_menu").clone();
    $("#purpose_menu").remove();
    $(clone).attr('id', 'purpose_menu')
    elements.mcDropdown(clone, {
      hoverOutDelay: 0,
      hoverOverDelay: 300,
      // showACOnEmptyFocus: true,
      allowParentSelect: true,
      delim: ">",
      select: purposes.select_purpose,
      targetColumnSize: 1,
      minRows: 1000, // force one column
      maxRows: 1000 // force one column
    })
  },

  add_purpose: function (add_link) {
    // prevent adding new purpose if last is active & blank
    if (add_link.hasClass('disabled')) {
      return;
    }

    // close mcdropdowns
    var active_mcdropdown = $('.mcdropdown');
    if (active_mcdropdown.length > 0) {
      purposes.close_purpose(active_mcdropdown);
    }

    // enable all add purpose butons
    $('.js_add_purpose').removeClass('disabled');

    // disable this add purpose button
    add_link.addClass('disabled');

    var tr = $(_purpose_row);

    add_link.parents('tr:first').before(tr);

    // hide all mcdropdowns fix
    //$('.mcdropdown_menu, .mcdropdown_autocomplete').hide();
    var purpose_search = tr.find(".purpose_search");
    purposes.initMcDropdown(purpose_search);
    purposes.resetMcdropdown($('.mcdropdown'));

    var selected_li = $('#purpose_menu li[rel="' + purposes.lastId + '"]');
    if (selected_li.length > 0) {
      McDropDownGlobalUpdateValue(selected_li);
    }

    if (purposes.type === 'multi') {
      purposes.lastIndex = tr.parents('.js_purpose_row').index();
    }
  },

  get_purpose_context: function(selected_text) {
    var arr = [];
    var codes = selected_text.split('>');
    var purpose_context = '';

    if (codes.length > 1) {
      arr.push(codes[codes.length - 2]);
      if (codes.length > 2) {
        arr.unshift(codes[codes.length - 3]);
        if (codes.length >= 3) {
          arr.unshift('...');
        }
      }
      purpose_context = '( ' + arr.join(' > ') + ' > )';
    }

    return purpose_context;
  },

  get_purpose_label: function(selected_text) {
    var codes = selected_text.split('>')
    return codes[codes.length - 1];
  },

  // find the value from a mcdropdown or a combobox
  // (classfications are using mcdropdown, implementer orgs are a combobox)
  get_selected_val: function (mcdropdown){
    var selected_id   = mcdropdown.find('input:hidden').val();
    if (!selected_id) {
      selected_id = mcdropdown.find('.combobox').val();
    }
    return selected_id;
  },

  // find the value from a mcdropdown or a combobox
  // (classfications are using mcdropdown, implementer orgs are a combobox)
  get_selected_text: function (mcdropdown){
    var selected_text   = mcdropdown.find('input:first').val();
    if (!selected_text) {
      selected_text = mcdropdown.find(".combobox").find(":selected").text();
    }
    return selected_text;
  },

  close_purpose: function (mcdropdown) {
    var selected_id     = purposes.get_selected_val(mcdropdown);
    var selected_text   = purposes.get_selected_text(mcdropdown);
    var purpose_label   = purposes.get_purpose_label(selected_text);
    var purpose_context = purposes.get_purpose_context(selected_text);
    var tr              = mcdropdown.parents('tr:first');
    var td              = mcdropdown.parents('td:first');
    purposes.lastId     = selected_id;

    mcdropdown.remove();
    td.html(
      '    <label for="classifications_' + selected_id + '">' + purpose_label + '</label>' +
      '    <span class="context">' + purpose_context + '</span>'
    )

    if (!selected_id) {
      tr.remove();
    }
  },

  remove_purpose: function (element) {
    var tr          = element.parents('tr:first');
    tr.find('.js_amount').val(0).trigger('keyup');
    tr.remove();

    $('.js_add_purpose').removeClass('disabled');

    //$('.mcdropdown_autocomplete').remove()
    $('.mcdropdown_menu').hide();
    $('.mcdropdown_autocomplete').hide();
    $('.ie_box').hide();
  },

  //on purpose select
  select_purpose: function (value, name) {
    if (!value) {
      return;
    }

    var mcdropdown     = $('.mcdropdown');
    var tr             = mcdropdown.parents('tr:first');
    var row            = mcdropdown.parents('.js_purpose_row');
    var activity_id    = tr.parents('.js_purpose_row').attr('activity_id');

    if (purposes.alreadyAdded(row, value)) {
      //purposes.resetMcdropdown(mcdropdown);
      //$('.mcdropdown_menu, .mcdropdown_autocomplete').hide();
      //mcdropdown.find('input:hidden').val('');
      //mcdropdown.find('input.purpose_search').val('').focus();
      purposes.remove_purpose(mcdropdown)

      alert('"' + name + '" is already added');
      purposes.lastId = purposes.get_selected_val(mcdropdown);
      return false;
    } else {
      if (value) {
        // enable add purpose button
        $('.js_add_purpose').removeClass('disabled');
      }

      if (purposes.type === 'multi') {
        purposes.update_inputs_multi(tr, activity_id, value);
      } else {
        purposes.update_inputs_single(tr, value);
      }
    }
  },
  update_inputs_single: function (block, value) {
    $.each(block.find(".js_amount"), function (index, element) {
      var element = $(element);
      element.attr('id', 'classifications_' + value + '_' + index);
      element.attr('name', 'classifications[' + value + '][' + index + ']');
    });
  },
  update_inputs_multi: function (block, activity_id, value) {
    var element = block.find('.total input');
    element.attr('id', 'classifications_' + activity_id + '_' + value);
    element.attr('name', 'classifications[' + activity_id + '][' + value + ']');
  },
  openMcDropDown: function (add_purpose_btn) {
    if (add_purpose_btn.length > 0) {
      add_purpose_btn.trigger('click');
    }
  },
  removeMcDropDown: function () {
    var element = $('.mcdropdown').parents('tr:first').find('.js_remove_purpose')
    purposes.remove_purpose(element);
  },
  changeMcDropDown: function (purpose_row) {
    if (purpose_row.length > 0) {
      purposes.removeMcDropDown();
      purposes.openMcDropDown(purpose_row.find('.js_add_purpose:first'));
    }
  },

  alreadyAdded: function (row, value) {
    var addedIds = [];

    // determine if the purpose was already added
    if (purposes.type === 'multi') {
      addedIds = jQuery.map(row.find('.js_amount').not(':last'), function (e) {
        //return Number($(e).attr('id').match(/\d+/)[0]);
        var id = $(e).attr('id');
        if (id) {
          return Number(id.match(/classifications_(\d+)_(\d+)/)[2]);
        }
      });
    } else {
      var elements = []
      $(".js_purpose_row").each(function () {
        elements.push($(this).find('.js_amount:first'));
      })

      addedIds = jQuery.map(elements, function (e) {
        //return Number($(e).attr('id').match(/\d+/)[0]);
        var id = $(e).attr('id');
        if (id) {
          return Number(id.match(/classifications_(\d+)_(\d+)/)[1]);
        }
      });
    }

    return addedIds.indexOf(Number(value)) >= 0;
  },


  init: function (type) {
    purposes.type = type;
    $(".js_add_purpose").live('click', function (e) {
      e.preventDefault();
      purposes.add_purpose($(this));
    });

    $(".js_remove_purpose").live('click', function (e) {
      e.preventDefault();
      if ( confirm('Are you sure?') ) {
        purposes.remove_purpose($(this));
      }
    });

    $(document).bind('keypress', function (e) {
      //console.log(e.keyCode);

      if (e.keyCode == 13) { // enter key
        e.preventDefault();
        var add_purpose_button = $('.js_add_purpose:eq(' + purposes.lastIndex + ')')

        if (!add_purpose_button.hasClass('disabled')) {
          purposes.openMcDropDown(add_purpose_button);
        }
      } else if (e.keyCode === 27) { // esc
        e.preventDefault();
        purposes.removeMcDropDown();
      } else if (e.shiftKey && e.keyCode === 40) { // key down
        e.preventDefault();
        var purpose_row = $('.mcdropdown').parents('.js_purpose_row').next('.js_purpose_row')
        purposes.changeMcDropDown(purpose_row);
      } else if (e.shiftKey && e.keyCode === 38) { // key up
        e.preventDefault();
        var purpose_row = $('.mcdropdown').parents('.js_purpose_row').prev('.js_purpose_row')
        purposes.changeMcDropDown(purpose_row);
      }
    })
  }
};


//###################################
//# Classifications
//###################################
var classifications_edit = {
  run: function () {
    var getClassificationTotal = function (amounts, amount) {
      var total = 0;
      for (var i = 0; i < amounts.length; i++) {
        var value = jQuery.trim(amounts[i]) ;
        if (value.charAt(value.length - 1) === '%') {
          var percent = Number(value.substring(0, value.length - 1));
          value = percent * amount / 100;
        } else {
          value = Number(value);
        }
        if (!isNaN(value)) {
          total += value;
        }
      }
      return total;
    };

    // amount totals
    $('.js_amount').live('keyup', function (e) {
      var element = $(this);
      var tr = element.parents('.js_purpose_row');
      var amount = Number(tr.attr('data-amount'));
      // activity total
      var elements = tr.find('.js_amount');
      var amounts  = jQuery.map(elements, function (e) { return $(e).val();});
      var total    = getClassificationTotal(amounts, amount);
      tr.find('.js_activity_total_row .total li:first span.js_activity_total').text(total);

      // remaining
      var remaining = amount - total;
      var remaining_box = tr.find('.js_activity_total_row .js_remaining_box');
      remaining === 0 ? remaining_box.hide() : remaining_box.show();
      remaining_box.find('span.js_remaining').text(remaining)
    });

    // tooltip
    $("td.tooltip").live('hover', function() {
      this.setAttribute("title", this.textContent)
    }).tipsy({gravity: 'w', live: true, html: true})

    purposes.init('multi');
  }
};

var long_term_budgets_show =  {
  run: function () {
    purposes.init('single');
  }
};
