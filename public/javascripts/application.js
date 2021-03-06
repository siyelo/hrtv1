var ALLOWED_VARIANCE = 0.05;

/* Nested model forms BEGIN */
function inspect (obj) {
        var str;
        for(var i in obj)
        str+=i+";\n"
  //str+=i+"="+obj[i]+";\n"
        alert(str);
}

function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
  //$(link).parent().next().hide();

  if ($(link).hasClass('totals_callback')) {
    updateTotalValuesCallback(link);
  }
};

function add_fields(link, association, content) {
  // before callback
  before_add_fields_callback(association);

  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")

  if (association === 'in_flows' || association === 'implementer_splits' ) {
    $(link).parents('tr:first').before(content.replace(regexp, new_id));
  } else {
    $(link).parent().before(content.replace(regexp, new_id));
  }

  after_add_fields_callback(association);
};

//prevents non-numeric characters to be entered in the input field
var numericInputField = function (input) {

  $(input).keydown(function(event) {
    // Allow backspace and delete, enter and tab
    var bksp = 46;
    var del = 8;
    var enter = 13;
    var tab = 9;

    if ( event.keyCode == bksp || event.keyCode == del || event.keyCode == enter || event.keyCode == tab ) {
      // let it happen, don't do anything
    } else {
      // Ensure that it is a number or a '.' and stop the keypress
      var period = 190;
      if ((event.keyCode >= 48 && event.keyCode <= 57 ) || event.keyCode == period || event.keyCode >= 37 && event.keyCode <= 40)  {
        // let it happen
      } else {
       event.preventDefault();
      };
    };
  });
}

var observeFormChanges = function (form) {
  var catcher = function () {
    var changed = false;

    if ($(form).data('initialForm') != $(form).serialize()) {
      changed = true;
    }

    if (changed) {
      return 'You have unsaved changes!';
    }
  };

  if ($(form).length) { //# dont bind unless you find the form element on the page
    $('input[type=submit]').click(function (e) {
      $(form).data('initialForm', $(form).serialize());
    });

    $(form).data('initialForm', $(form).serialize());
    $(window).bind('beforeunload', catcher);
  };
}

var build_activity_funding_source_row = function (edit_block) {
  var organization = edit_block.find('.ff_organization option:selected').text();
  var spend = '';
  var budget = '';

  spend = $('<li/>').append(
    $('<span/>').text('Expenditure'),
    edit_block.find('.ff_spend').val() || 'N/A'
  )

  budget = $('<li/>').append(
    $('<span/>').text('Current Budget'),
    edit_block.find('.ff_budget').val() || 'N/A'
  )

  return $('<ul/>').append(
    $('<li/>').append(
      $('<span/>').text('Funder'),
      organization || 'N/A'
    ),
    spend,
    budget
  )
};

var close_activity_funding_sources_fields = function (fields) {
  $.each(fields, function () {
    var element = $(this);
    var edit_block = element.find('.edit_block');
    var preview_block = element.find('.preview_block');
    var manage_block = element.find('.manage_block');

    edit_block.hide();
    preview_block.html('');
    preview_block.append(build_activity_funding_source_row(edit_block))
    preview_block.show();

    manage_block.find('.edit_button').remove();
    manage_block.prepend(
      $('<a/>').attr({'class': 'edit_button', 'href': '#'}).text('Edit')
    )
  });
};

var before_add_fields_callback = function (association) {
  if (association === 'funding_sources') {
    close_activity_funding_sources_fields($('.funding_sources .fields'));
  }
};

var after_add_fields_callback = function (association) {
  // show the jquery autocomplete combobox instead of
  // standard dropdowns
  $( ".js_combobox" ).combobox();
};

/* Nested model forms END */

/* Ajax CRUD BEGIN */

var getRowId = function (element) {
  return element.parents('tr').attr('id');
};

var getResourceId = function (element) {
  return Number(getRowId(element).match(/\d+/)[0]);
};

var getResourceName = function (element) {
  return element.parents('.resources').attr("data-resource");
};

var getForm = function (element) {
  return element.parents('form');
};

var addNewForm = function (resources, data) {
  resources.find('.placer').html(data);
};

var addEditForm = function (rowId, data) {
  $('#' + rowId).html('<td colspan="100">' + data + '</td>').addClass("edit_row");
};

var updateCount = function (resources) {
  var count = resources.find('tbody tr').length;
  resources.find('.count').html(count);
}

var addNewRow = function (resources, data) {
  resources.find('tbody').prepend(data);
  enableElement(resources.find('.new_btn'));
  updateCount(resources);
  var newRow = $(resources.find('tbody tr')[0]);
  newRow.find(".rest_in_place").rest_in_place(); // inplace edit
};

var addExistingRow = function (rowId, data) {
  var row = $('#' + rowId);
  row.replaceWith(data)
  var newRow = $('#' + rowId);
  newRow.find(".rest_in_place").rest_in_place(); // inplace edit
};

var addSearchForm = function (element) {
  if (element.hasClass('enabled')) {
    disableElement(element);
    var resourceName = getResourceName(element);
    $.get(resourceName + '/search.js', function (data) {
      $('#placer').prepend(data);
    });
  }
}

var closeForm = function (element) {
  element.parents('.form_box').remove();
};

var disableElement = function (element) {
  element.removeClass('enabled').addClass('disabled');
};

var enableElement = function (element) {
  element.removeClass('disabled').addClass('enabled');
};

var buildUrl = function (url) {
  var parts = url.split('?');
  if (parts.length > 1) {
    return parts.join('.js?');
  } else {
    return parts[0] + '.js';
  }
};

var buildJsonUrl = function (url) {
  var parts = url.split('?');
  if (parts.length > 1) {
    return parts.join('.json?');
  } else {
    return parts[0] + '.json';
  }
};

var getResources = function (element) {
  return element.parents('.resources');
}

var newResource = function (element) {
  if (element.hasClass('enabled')) {
    var resources = getResources(element);
    disableElement(element);
    $.get(buildUrl(element.attr('href')), function (data) {
      addNewForm(resources, data);
    });
  }
};

var replaceTable = function (data) {
  $("#main_table").replaceWith(data);
  $("#main_table").find(".rest_in_place").rest_in_place(); // inplace edit
};

var searchResources = function (element, type) {
  var resourceName = getResourceName(element);
  var form = getForm(element);
  var q = (type === "reset") ? '' : form.find("#s_q").val();

  $.get(resourceName + '.js?q=' + q, function (data) {
    replaceTable(data);
    if (type === "reset") {
     closeForm(element);
     enableElement($(".search_btn"));
    }
  });
};

var editResource = function (element) {
  var rowId = getRowId(element);
  $.get(buildUrl(element.attr('href')), function (data) {
    addEditForm(rowId, data);
  });
};

var updateResource = function (element) {
  var rowId = getRowId(element);
  var form = getForm(element);
  $.post(buildUrl(form.attr('action')), form.serialize(), function (data, status, response) {
    closeForm(element);
    response.status === 206 ? addEditForm(rowId, data) : addExistingRow(rowId, data);
  });
};

var createResource = function (element) {
  var form = getForm(element);
  var resources = getResources(element);
  $.post(buildUrl(form.attr('action')), form.serialize(), function (data, status, response) {
    closeForm(element);
    response.status === 206 ? addNewForm(resources, data) : addNewRow(resources, data);
  });
};

var showResource = function (element) {
  var rowId = getRowId(element);
  var resourceId = getResourceId(element)
  $.get(element.attr('href') + '/' + resourceId + '.js', function (data) {
    closeForm(element);
    addExistingRow(rowId, data);
  });
};

var destroyResource = function (element) {
  var rowId = getRowId(element);
  var resources = getResources(element);
  $.post(element.attr('href').replace('/delete', '') + '.js', {'_method': 'delete'}, function (data) {
    removeRow(resources, rowId);
  });
};

var sortResources = function (element) {
  var link = element.find('a');
  var resourceName = getResourceName(element);
  var url = resourceName + '.js?' + link.attr('href').replace(/.*\?/, '');
  $.get(url, function (data) {
    replaceTable(data);
  });
}

var getFormType = function (element) {
  // new_form => new; edit_form => edit
  return element.parents('.form_box').attr('class').replace(/form_box /, '').split('_')[0];
}

var ajaxifyResources = function (resources) {
  var block = $(".resources[data-resources='" + resources + "']");
  var newBtn = block.find(".new_btn");
  var editBtn = block.find(".edit_btn");
  var cancelBtn = block.find(".cancel_btn");
  var searchBtn = block.find(".search_btn");
  var submitBtn = block.find(".js_submit_comment_btn");
  var destroyBtn = block.find(".destroy_btn");

  // new
  newBtn.live('click', function (e) {
    e.preventDefault();
    var element = $(this);
    newResource(element);
  });

  // edit
  editBtn.live('click', function (e) {
    e.preventDefault();
    var element = $(this);
    editResource(element);
  });

  // cancel
  cancelBtn.live('click', function (e) {
    e.preventDefault();
    var element = $(this);
    var formType = getFormType(element);

    if (formType === "new") {
      closeForm(element);
      enableElement(newBtn);
    } else if (formType === "edit") {
      showResource(element);
    } else if (formType === "search") {
      closeForm(element);
      enableElement(searchBtn);
    } else {
      throw "Unknown form type:" + formType;
    }
  });

  // submit
  submitBtn.live('click', function (e) {
    e.preventDefault();
    var element = $(this);
    var formType = getFormType(element);

    if (formType === "new") {
      createResource(element);
    } else if (formType === "edit") {
      updateResource(element);
    } else if (formType === "search") {
      searchResources(element);
    } else {
      throw "Unknown form type: " + formType;
    }
  });

  // destroy
  destroyBtn.live('click', function (e) {
    e.preventDefault();
    var element = $(this);
    if (confirm('Are you sure?')) {
      destroyResource(element);
    }
  });
};


/* Ajax CRUD END */

var collapse_expand = function (e, element, type) {
  // if target element is link or the user is selecting text, skip collapsing
  if (e.target.nodeName === 'A' || window.getSelection().toString() !== "") {
    return;
  }

  var next_element = element.next('.' + type + '.entry_main');
  var next_element_visible = next_element.is(':visible');
  $('.' + type + '.entry_main').hide();
  $('.' + type + '.entry_header').removeClass('active');
  if (next_element_visible) {
    next_element.hide();
  } else {
    element.addClass('active');
    next_element.show();
  }
};

var getRowId = function (element) {
  return element.parents('tr').attr('id');
};

var getResourceName = function (element) {
  return element.parents('.resources').attr("data-resources");
};

var getResourceId = function (element) {
  return Number(getRowId(element).match(/\d+/)[0]);
};

var removeRow = function (resources, rowId) {
  resources.find("#" + rowId).remove();
  updateCount(resources);
};

var updateTotalValuesCallback = function (el) {
  updateTotalValue($(el).parents('tr').find('.js_spend'));
  updateTotalValue($(el).parents('tr').find('.js_budget'));
};

var getFieldsTotal = function (fields) {
  var total = 0;

  for (var i = 0; i < fields.length; i++) {
    if (!isNaN(fields[i].value)) {
      total += Number(fields[i].value);
    }
  }

  return total;
}

var updateTotalValue = function (el) {
  if ($(el).hasClass('js_spend')) {
    if ($(el).parents('table').length) {
      // table totals
      var table        = $(el).parents('table');
      var input_fields = table.find('input.js_spend:visible');
      var total_field  = table.find('.js_total_spend .amount');
    } else {
      // classifications tree totals
      var input_fields = $(el).parents('.activity_tree').find('> li > div input.js_spend');
      var total_field  = $('.js_total_spend .amount');
    }
  } else if ($(el).hasClass('js_budget')) {
    if ($(el).parents('table').length) {
      // table totals
      var table = $(el).parents('table');
      var input_fields = table.find('input.js_budget:visible');
      var total_field = table.find('.js_total_budget .amount');
    } else {
      // classifications tree totals
      var input_fields = $(el).parents('.activity_tree').find('> li > div input.js_budget');
      var total_field = $('.js_total_budget .amount');
    }
  } else {
    throw "Element class not valid";
  }

  var fieldsTotal = getFieldsTotal(input_fields);
  total_field.html(fieldsTotal.toFixed(2));
};

var dynamicUpdateTotalsInit = function () {
  $('.js_spend, .js_budget').live('keyup', function () {
    updateTotalValue(this);
  });
};

var admin_responses_index = {
  run: function () {
    // destroy
    $(".destroy_btn").live('click', function (e) {
      e.preventDefault();
      var element = $(this);
      if (confirm('Are you sure?')) {
        destroyResource(element);
      }
    });
  }
};

var admin_responses_empty = {
  run: function () {
    // destroy
    $(".destroy_btn").live('click', function (e) {
      e.preventDefault();
      var element = $(this);
      if (confirm('Are you sure?')) {
        destroyResource(element);
      }
    });
  }
};

var getOrganizationInfo = function (organization_id, box) {
  if (organization_id) {
    $.get(organization_id + '.js', function (data) {
      box.find('.placer').html(data);
    });
  }
};

var displayFlashForReplaceOrganization = function (type, message) {
  $('#content .wrapper').prepend(
    $('<div/>').attr({id: 'flashes'}).append(
      $('<div/>').attr({id: type}).text(message)
    )
  );

  // fade out flash message
  $("#" + type).delay(5000).fadeOut(3000, function () {
    $("#flashes").remove();
  });
}

var removeOrganizationFromLists = function (duplicate_id, box_type) {
  $.each(['duplicate', 'target'], function (i, name) {
    var select_element = $("#" + name + "_organization_id");
    var current_option = select_element.find("option[value='" + duplicate_id + "']");

    // remove element from page
    if (name === box_type) {
      var next_option = current_option.next().val();
      if (next_option) {
        select_element.val(next_option);
        // update info block
        getOrganizationInfo(select_element.val(), $('#' + name));
      } else {
        $('#' + name).html('')
      }
    }

    current_option.remove();
  });
}

var ReplaceOrganizationSuccessCallback = function (message, duplicate_id) {
  removeOrganizationFromLists(duplicate_id, 'duplicate');
  displayFlashForReplaceOrganization('notice', message);
};

var ReplaceOrganizationErrorCallback = function (message) {
  displayFlashForReplaceOrganization('error', message)
}

var replaceOrganization = function (form) {
  var duplicate_id = $("#duplicate_organization_id").val();
  $.post(buildUrl(form.attr('action')), form.serialize(), function (data, status, response) {
    var data = $.parseJSON(data)
    response.status === 206 ? ReplaceOrganizationErrorCallback(data.message) : ReplaceOrganizationSuccessCallback(data.message, duplicate_id);
  });
};

var admin_organizations_duplicate = {
  run: function () {
    $("#duplicate_organization_id, #target_organization_id").change(function() {
      var organization_id = $(this).val();
      var type = $(this).parents('.box').attr('data-type');
      var box = $('#' + type); // type = duplicate; target
      getOrganizationInfo(organization_id, box);
    });

    getOrganizationInfo($("#duplicate_organization_id").val(), $('#duplicate'));
    getOrganizationInfo($("#target_organization_id").val(), $('#target'));

    $("#replace_organization").click(function (e) {
      e.preventDefault();
      var element = $(this);
      var form = element.parents('form')
      if (confirm('Are you sure?')) {
        replaceOrganization(form);
      }
    });
  }
};

var admin_responses_show = {
  run: function (){
    build_data_response_review_screen();
    ajaxifyResources('comments');
  }
};

var reports_index = {
  run: function () {
    ajaxifyResources('comments');
    drawPieChart('code_spent', _code_spent_values, 450, 300);
    drawPieChart('code_budget', _code_budget_values, 450, 300);
  }
};

var responses_review = {
  run: function () {
    build_data_response_review_screen();
    ajaxifyResources('comments');
  }
};

var activity_classification = function () {
  /*
   * Adds collapsible checkbox tree functionality for a tab and validates classification tree
   * @param {String} tab
   *
   */
  var addCollabsibleButtons = function (tab) {
    $('.' + tab + ' ul.activity_tree').collapsibleCheckboxTree({tab: tab});
    $('.' + tab + ' ul.activity_tree').validateClassificationTree();
  };

  //collapsible checkboxes for tab1
  var mode = document.location.search.split("=")[1]
  if (mode != 'locations') {
    addCollabsibleButtons('tab1');
  }
  checkRootNodes('budget');
  checkRootNodes('spend');
  checkAllChildren();

  showSubtotalIcons();

  $('.js_upload_btn').click(function (e) {
    e.preventDefault();
    $(this).parents('.upload').find('.upload_box').toggle();
  });

  $('.js_submit_btn').click(function (e) {
    var ajaxLoader = $(this).closest('ol').find('.ajax-loader');
    ajaxLoader.show();
    checkRootNodes('spend');
    checkRootNodes('budget');
    if ($('.invalid_node').size() > 0){
      e.preventDefault();
      alert('The classification tree could not be saved.  Please correct all errors and try again')
      ajaxLoader.hide();
    };
  });


  $('#js_budget_to_spend').click(function (e) {
    e.preventDefault();
    if ($(this).find('img').hasClass('approved')) {
      alert('Classifications for an approved activity cannot be changed');
    } else if (confirm('This will overwrite all Past Expenditure percentages with the Current Budget percentages. Are you sure?')) {
      $('.js_budget input').each(function () {
        var element = $(this);
        element.parents('.js_values').find('.js_spend input').val(element.val());
      });
      checkRootNodes('spend');
      checkAllChildren();
    };
  });

  $('#js_spend_to_budget').click(function (e) {
    e.preventDefault();
    if ($(this).find('img').hasClass('approved')) {
      alert('Classifications for an approved activity cannot be changed');
    } else if (confirm('This will overwrite all Current Budget percentages with the Past Expenditure percentages. Are you sure?')) {
      $('.js_spend input').each(function () {
        var element = $(this);
        element.parents('.js_values').find('.js_budget input').val(element.val());
      });
      checkRootNodes('budget');
      checkAllChildren();
    };
  });

  $(".percentage_box").keyup(function(event) {
    var element = $(this);
    var isSpend = element.parents('div:first').hasClass('spend')
    var type = (isSpend) ? 'spend' : 'budget';
    var childLi = element.parents('li:first').children('ul:first').children('li');

    updateSubTotal(element);
    updateTotalValue(element);

    if (element.val().length == 0 && childLi.size() > 0) {
      clearChildNodes(element, event, type);
    }

    var period = 190;
    var bksp = 46;
    var del = 8;
    //update parent nodes if: numeric keys, backspace/delete, period or undefined (i.e. called from another function)
    if (typeof event.keyCode == 'undefined' || (event.keyCode >= 48 && event.keyCode <= 57 ) || event.keyCode == period || event.keyCode == del || event.keyCode == bksp || event.keyCode >= 37 && event.keyCode <= 40){
      updateParentNodes(element, type)
    }
    //check whether children (1 level deep) are equal to my total
    if (childLi.size() > 0){
      compareChildrenToParent(element, type);
    };

    //check whether root nodes are = 100%
    checkRootNodes(type);

  });

  numericInputField(".percentage_box, .js_spend, .js_budget");

  var updateParentNodes = function(element, type){
    type = '.' + type + ':first'
    var parentElement = element.parents('ul:first').prev('div:first').find(type).find('input');
    var siblingLi = element.parents('ul:first').children('li');

    var siblingValue = 0;
    var siblingTotal = 0;
    siblingLi.each(function (){
      siblingValue = parseFloat($(this).find(type).find('input:first').val());
      if ( !isNaN(siblingValue) ) {
        siblingTotal = siblingTotal + siblingValue;
      }; 
    });
    if ( siblingTotal !== 0 ) {
      parentElement.val(siblingTotal);
      parentElement.trigger('keyup');
    }
  }

  var clearChildNodes = function(element, event, type){
    var bksp = 46;
    var del = 8;
    type = '.' + type + ':first'

    if ( (event.keyCode == bksp || event.keyCode == del) ){
      childNodes = element.parents('li:first').children('ul:first').find('li').find(type).find('input');

      var childTotal = 0;
      childNodes.each(function (){
        childValue = parseFloat($(this).val())
        if (!isNaN(childValue)) {
          childTotal = childTotal + childValue
        };
      });

      if ( childTotal > 0 && confirm('Would you like to clear the value of all child nodes?') ){
        childNodes.each(function(){
          if ( $(this).val !== '' ){
            $(this).val(' ');
            updateSubTotal($(this));
          }
        });
      }
    }
  }

  var updateSubTotal = function(element){
    var activity_budget = parseFloat(element.parents('ul:last').attr('activity_budget'));
    var activity_spend = parseFloat(element.parents('ul:last').attr('activity_spend'));
    var activity_currency = element.parents('ul:last').attr('activity_currency');
    var elementValue = parseFloat(element.val());
    var subtotal = element.siblings('.subtotal_icon');
    var isSpend = element.parents('div:first').hasClass('spend')

    if ( elementValue > 0 ){
      subtotal.removeClass('hidden')
      subtotal.attr('title', (isSpend ? activity_spend : activity_budget * (elementValue/100)).toFixed(2) + ' ' + activity_currency);
    } else {
      subtotal.attr('title','');
      subtotal.addClass('hidden');
    }
  };
}

var checkAllChildren = function(){
  var inputs = $('.percentage_box')
  inputs.each(function(){
    if ( $(this).val !== '' ){
      var type = $(this).hasClass('js_spend') ? 'spend' : 'budget'
      compareChildrenToParent($(this), type);
    }
  });
}

var compareChildrenToParent = function(parentElement, type){
  var childValue = 0;
  var childTotal = 0;
  var childLi = parentElement.parents('li:first').children('ul:first').children('li');
  type = '.' + type + ':first'

  childLi.each(function (){
    childValue = parseFloat($(this).find(type).find('input:first').val())
    if (!isNaN(childValue)) {
      childTotal = childTotal + childValue
    };
  });

  var parentValue = parseFloat(parentElement.val()).toFixed(2)
  childTotal = childTotal.toFixed(2)

  if ( (Math.abs(childTotal - parentValue) > ALLOWED_VARIANCE) && childTotal > 0){
    parentElement.addClass('invalid_node tooltip')
    var message = "This amount is not the same as the sum of the amounts underneath (" ;
    message += parentValue + "% - " + childTotal + "% = " + (parentValue - childTotal) + "%)";
    parentElement.attr('original-title', message) ;
  } else {
    parentElement.removeClass('invalid_node tooltip')
  };
};

var checkRootNodes = function(type){
  var topNodes =  $('.activity_tree').find('li:first').siblings().andSelf();
  var total = 0;
  var value = 0;
  type = '.' + type + ':first'

  topNodes.each(function(){
    value = $(this).find(type).find('input').val();
    if (!isNaN(parseFloat(value))){
      total += parseFloat($(this).find(type).find('input').val());
    };
  });

  $('.totals').find(type).find('.amount').html(total);

  if ( (Math.abs(total - 100.00) > ALLOWED_VARIANCE) && total > 0){
    topNodes.each(function(){
      rootNode = $(this).find(type).find('input');
      if (rootNode.val().length > 0 && (!(rootNode.hasClass('invalid_node tooltip')))){
        rootNode.addClass('invalid_node tooltip');
      }
      var message = "The root nodes do not add up to 100%";
      rootNode.attr('original-title', message) ;
    });
  } else {
    topNodes.each(function(){
      rootNode = $(this).find(type).find('input');
      if (rootNode.attr('original-title') != undefined && rootNode.attr('original-title') == "The root nodes do not add up to 100%"){
        rootNode.removeClass('invalid_node tooltip');
        rootNode.attr('original-title', '')
      }
    });

  };
};

var showSubtotalIcons = function(){
  $('.tab1').find('.percentage_box').each(function(){
    if ($(this).val().length > 0) {
      $(this).siblings('.subtotal_icon').removeClass('hidden')
    }
  });
}

var update_use_budget_codings_for_spend = function (e, activity_id, checked) {
  if (!checked || checked && confirm('All your expenditure codings will be deleted and replaced with copies of your budget codings, adjusted for the difference between your budget and spend. Your expenditure codings will also automatically update if you change your budget codings. Are you sure?')) {
    $.post( "/activities/" + activity_id + "/use_budget_codings_for_spend", { checked: checked, "_method": "put" });
  } else {
    e.preventDefault();
  }
};

var data_responses_review = {
  run: function () {
    $(".use_budget_codings_for_spend").click(function (e) {
      var checked = $(this).is(':checked');
      activity_id = Number($(this).attr('id').match(/\d+/)[0], 10);
      update_use_budget_codings_for_spend(e, activity_id, checked);
    })
  }
}

var responses_submit = {
  run: function () {
    $(".collapse").click(function(e){
      e.preventDefault();
      var row_id = $(this).attr('id');
      $("." + row_id).slideToggle("fast");
      var row = row_id.split("_", 3);
      var img = $(this).attr('img');
      var image = row_id + "_image";
      var source = $('.'+image).attr('src');
      var split = source.split("?", 1);
      if (split == "/images/icon_expand.png") {
        $('.' + image).attr('src', "/images/icon_collapse.png");
      } else {
        $('.' + image).attr('src', "/images/icon_expand.png");
      }
    });
  }
}

function drawPieChart(id, data_rows, width, height) {
  if (typeof(data_rows) === "undefined") {
    return;
  }

  var data = new google.visualization.DataTable();
  data.addColumn('string', data_rows.names.column1);
  data.addColumn('number', data_rows.names.column2);
  data.addRows(data_rows.values.length);
  for (var i = 0; i < data_rows.values.length; i++) {
    var value = data_rows.values[i];
    data.setValue(i, 0, value[0]);
    data.setValue(i, 1, value[1]);
  };
  var chart = new google.visualization.PieChart(document.getElementById(id));
  chart.draw(data, {width: width, height: height, chartArea: {width: 360, height: 220}});
};

var reports_districts_show = reports_countries_show = {
  run: function () {
    drawPieChart('budget_i_pie', _budget_i_values, 400, 250);
    drawPieChart('spend_i_pie', _spend_i_values, 400, 250);
  }
};

var reports_districts_classifications = reports_countries_classifications = {
  run: function () {
    if (_pie) {
      drawPieChart('code_spent', _code_spent_values, 450, 300);
      drawPieChart('code_budget', _code_budget_values, 450, 300);
    } else {
      drawTreemapChart('code_spent', _code_spent_values, 'w');
      drawTreemapChart('code_budget', _code_budget_values, 'e');
    }
  }
}

var reports_districts_activities_show = {
  run: function () {
    drawPieChart('spent_pie', _spent_pie_values, 450, 300);
    drawPieChart('budget_pie', _budget_pie_values, 450, 300);
    drawPieChart('code_spent', _code_spent_values, 450, 300);
    drawPieChart('code_budget', _code_budget_values, 450, 300);
  }
};

var admin_currencies_index = {
  run: function () {
    $(".currency_label").live("click", function () {
      var element = $(this);
      var id = element.attr('id');
      element.hide();
      element.parent('td').append($("<input id=\'" + id + "\' class=\'currency\' />"));
    });

    $(".currency").live('focusout', function () {
      element = $(this);
      var input_rate = element.val();
      var url = "/admin/currencies/" + element.attr('id');
      $.post(url, { "rate" : input_rate, "_method" : "put" }, function(data){
        var data = $.parseJSON(data);
        if (data.status == 'success'){
          element.parent('td').children('span').show();
          element.parent('td').children('span').text(data.new_rate);
          element.hide();
        }
      });
    });
  }
}

var reports_districts_activities_index = {
  run: function () {
    drawPieChart('spent_pie', _spent_pie_values, 450, 300);
    drawPieChart('budget_pie', _budget_pie_values, 450, 300);
  }
};

var reports_districts_organizations_index = {
  run: function () {
    drawPieChart('spent_pie', _spent_pie_values, 450, 300);
    drawPieChart('budget_pie', _budget_pie_values, 450, 300);
  }
};

var reports_districts_organizations_show = {
  run: function () {
    drawPieChart('code_spent', _code_spent_values, 450, 300);
    drawPieChart('code_budget', _code_budget_values, 450, 300);
  }
};

var reports_countries_organizations_index = {
  run: function () {
    drawPieChart('spent_pie', _spent_pie_values, 450, 300);
    drawPieChart('budget_pie', _budget_pie_values, 450, 300);
  }
};

var reports_countries_organizations_show = {
  run: function () {
    drawPieChart('code_spent', _code_spent_values, 450, 300);
    drawPieChart('code_budget', _code_budget_values, 450, 300);
  }
};

var reports_countries_activities_index = {
  run: function () {
    drawPieChart('spent_pie', _spent_pie_values, 450, 300);
    drawPieChart('budget_pie', _budget_pie_values, 450, 300);
  }
};

var reports_countries_activities_show = {
  run: function () {
    drawPieChart('code_spent', _code_spent_values, 450, 300);
    drawPieChart('code_budget', _code_budget_values, 450, 300);
  }
};

var validateDates = function (startDate, endDate) {
  var checkDates = function (e) {
    var element = $(e.target);
    var d1 = new Date(startDate.val());
    var d2 = new Date(endDate.val());

    // remove old errors
    startDate.parent('li').find('.inline-errors').remove();
    endDate.parent('li').find('.inline-errors').remove();

    if (startDate.length && endDate.length && d1 >= d2) {
      if (startDate.attr('id') == element.attr('id')) {
        message = "Start date must come before End date.";
      } else {
        message = "End date must come after Start date.";
      }
      element.parent('li').append(
        $('<p/>').attr({"class": "inline-errors"}).text(message)
      );
    }
  };

  startDate.live('change', checkDates);
  endDate.live('change', checkDates);
};


var commentsInit = function () {
  initDemoText($('*[data-hint]'));
  focusDemoText($('*[data-hint]'));
  blurDemoText($('*[data-hint]'));

  var removeInlineErrors = function (form) {
    form.find('.inline-errors').remove(); // remove inline error if present
  }

  $('.js_reply').live('click', function (e) {
    e.preventDefault();
    var element = $(this);
    element.parents('li:first').find('.js_reply_box:first').show();
  })

  $('.js_cancel_reply').live('click', function (e) {
    e.preventDefault();
    var element = $(this);
    element.parents('.js_reply_box:first').hide();
    removeInlineErrors(element.parents('form'));
  })

  // remove demo text when submiting comment
  $('.js_submit_comment_btn').live('click', function (e) {
    e.preventDefault();
    removeDemoText($('*[data-hint]'));

    var element = $(this);
    if (element.hasClass('disabled')) {
      return;
    }

    var form    = element.parents('form');
    var block;
    var ajaxLoader = element.parent('li').nextAll('.ajax-loader');

    element.addClass('disabled');
    ajaxLoader.show();

    $.post(buildJsonUrl(form.attr('action')), form.serialize(),
      function (data, status, response) {
      ajaxLoader.hide();
      element.removeClass('disabled');

      if (response.status === 206) {
        form.replaceWith(data.html)
      } else {
        if (form.find('#comment_parent_id').length) {
          // comment reply
          block = element.parents('li.comment_item:first');

          if (block.find('ul').length) {
            block.find('ul').prepend(data.html);
          } else {
            block.append($('<ul/>').prepend(data.html));
          }
        } else {
          // root comment
          block = $('ul.js_comments_list');
          block.prepend(data.html)
        }
      }

      initDemoText(form.find('*[data-hint]'));
      removeInlineErrors(form);
      form.find('textarea').val(''); // reset comment value to blank
      form.find('.js_cancel_reply').trigger('click'); // close comment block
    });
  });
}

var dropdown = {
  // find the dropdown menu relative to the current element
  menu: function(element){
    return element.parents('.js_dropdown_menu');
  },

  toggle_on: function (menu_element) {
    menu_element.find('.menu_items').slideDown(100);
    menu_element.addClass('persist');
  },

  toggle_off: function (menu_element) {
    menu_element.find('.menu_items').slideUp(100);
    menu_element.removeClass('persist');
  }
};

var projects_index = {
  run: function () {

    // use click() not toggle() here, as toggle() doesnt
    // work when menu items are also toggling it

    $('.js_project_row').hover(
      function(e){
        $(this).find('.js_am_approve').show();
      },
      function(e){
        $(this).find('.js_am_approve').fadeOut(300);
      }

    );

    $('.js_dropdown_trigger').click(function (e){
      e.preventDefault();
      menu = dropdown.menu($(this));
      if (!menu.is('.persist')) {
        dropdown.toggle_on(menu);
      } else {
        dropdown.toggle_off(menu);
      };
    });

    $('.js_dropdown_menu .menu_items a').click(function (e){
      menu = dropdown.menu($(this));
      dropdown.toggle_off(menu);
      $(this).click; // continue with desired click action
    });

    $('.js_upload_btn').click(function (e) {
      e.preventDefault();
      $(this).parents('tbody').find('.upload_box').slideToggle();
    });

    $('#import_export').click(function (e) {
      e.preventDefault();
      $('#import_export_box .upload_box').slideToggle();
    });

    $('.tooltip_projects').tipsy({gravity: $.fn.tipsy.autoWE, live: true, html: true});

    commentsInit();

    approveBudget();

    $('.js_address').address(function() {
      return 'new_' + $(this).html().toLowerCase();
    });

    $.address.externalChange(function() {
      var hash = $.address.path();
      if (hash == '/'){
        if (!($('#projects_listing').is(":visible"))){
          $('.js_toggle_projects_listing').click();
        }
      } else {
        if (hash == '/new_project'){
          hideAll();
          $('#new_project_form').fadeIn();
          validateDates($('.start_date'), $('.end_date'));
        }else if (hash == '/new_activity'){
          hideAll();
          $('#new_activity_form').fadeIn();
          activity_form();
        }
        else if (hash == '/new_other cost'){
          hideAll();
          $('#new_other_cost_form').fadeIn();
        }
      };
    });

    $('.js_toggle_project_form').click(function (e) {
      e.preventDefault();
      hideAll();
      $('#new_project_form').fadeIn();
      $('#new_project_form #project_name').focus();
    });


    $('.js_toggle_activity_form').click(function (e) {
      e.preventDefault();
      hideAll();
      $('#new_activity_form').fadeIn();
      $('#new_activity_form #activity_name').focus();
      activity_form();
    });

    $('.js_toggle_other_cost_form').click(function (e) {
      e.preventDefault();
      hideAll();
      $('#new_other_cost_form').fadeIn();
      $('#new_other_cost_form #other_cost_name').focus();
    });

    $('.js_toggle_projects_listing').click(function (e) {
      e.preventDefault();
      hideAll();
      $.address.path('/');
      $( "form" )[ 0 ].reset()
      $('#projects_listing').fadeIn();
      $("html, body").animate({ scrollTop: 0 }, 0);
    });

    dynamicUpdateTotalsInit();
    numericInputField(".js_spend, .js_budget");
  }
};

var hideAll = function() {
  $('#projects_listing').hide();
  $('#new_project_form').hide();
  $('#new_activity_form').hide();
  $('#new_other_cost_form').hide();
  $('.js_total_budget .amount, .js_total_spend .amount').html(0);
};

var initDemoText = function (elements) {
  elements.each(function(){
    var element = $(this);
    var demo_text = element.attr('data-hint');

    if (demo_text != null) {
      element.attr('title', demo_text);
      if (element.val() == '' || element.val() == demo_text) {
        element.val( demo_text );
        element.addClass('input_hint');
      }
    }
  });
};


var focusDemoText = function (elements) {
  elements.live('focus', function(){
    var element = $(this);
    var demo_text = element.attr('data-hint');
    if (demo_text != null) {
      if (element.val() == demo_text) {
        element.val('');
        element.removeClass('input_hint');
      }
    }
  });
};

var removeDemoText = function (elements) {
  elements.each(function () {
    var element = $(this);
    var demo_text = element.attr('data-hint');
    if (demo_text != null) {
      if (element.val() == demo_text) {
        element.val('');
      }
    }
  });
};


var blurDemoText = function (elements) {
  elements.live('blur', function(){
    var element = $(this);
    var demo_text = element.attr('data-hint');
    if (demo_text != null) {
      if (element.val() == '') {
        element.val( demo_text );
        element.addClass('input_hint');
      }
    }
  });
};

var toggle_collapsed = function (elem, indicator) {
  var is_visible = elem.is(':visible');
  if (is_visible) {
    indicator.removeClass('collapsed');
  } else {
    indicator.addClass('collapsed');
  };
};

var unsaved_warning = function () {
  return 'You have projects that have not been saved.  Saved projects show a green checkmark next to them.  Are you sure you want to leave this page?'
};

var projects_import = {
  run: function () {
    $('.activity_box .header').live('click', function (e) {
      e.preventDefault();
      var activity_box = $(this).parents('.activity_box');
      //collapse the others, in an accordion style
      $.each($.merge(activity_box.prevAll('.activity_box'), activity_box.nextAll('.activity_box')), function () {
        $(this).find('.main').hide();
        toggle_collapsed($(this).find('.main'), $(this).find('.header span'));
      });

      activity_box.find('.main').toggle();
      toggle_collapsed(activity_box.find('.main'), activity_box.find('.header span'));
    });

    $('.header:first').trigger('click'); // expand the first one on page load

    $(window).bind('beforeunload',function (e) {
      if ($('.js_unsaved').length > 0) {
        return unsaved_warning();
      }
    });

    $('.save_btn').live('click', function (e) {
      e.preventDefault();
      var element = $(this);
      var form = element.parents('form');
      var ajaxLoader = element.next('.ajax-loader');
      var activity_box = element.parents('.activity_box');

      ajaxLoader.show();

      $.post(buildUrl(form.attr('action')), form.serialize(), function (data) {
        activity_box.html(data.html);
        activity_box.find(".js_combobox").combobox();
        ajaxLoader.hide();
        if (data.status == 'success') {
           activity_box.find('.saved_tick').show();
           activity_box.find('.saved_tick').removeClass('js_unsaved');
           activity_box.find('.saved_tick').addClass('js_saved');

           activity_box.find('.main').toggle();
           toggle_collapsed(activity_box.find('.main'), activity_box.find('.header span'));

           $('.js_unsaved:first').parents('.activity_box').find('.main').toggle();
           toggle_collapsed($('.js_unsaved:first').parents('.activity_box').find('.main'), $('.js_unsaved:first').parents('.activity_box').find('.header span'));
         }
      });
    });
  }
}

// Post approval for an activity
//
// approval types;
//   'activity_manager_approve'
//   'sysadmin_approve'
// success text
//
//

var approveBudget = function() {
  $(".js_am_approve").click(function (e) {
    e.preventDefault();
    approveActivity($(this), 'activity_manager_approve', 'Budget Approved');
  })
};

var approveAsAdmin = function() {
  $(".js_sysadmin_approve").click(function (e) {
    e.preventDefault();
    approveActivity($(this), 'sysadmin_approve', 'Admin Approved');
  })
};

var approveActivity = function (element, approval_type, success_text) {
   var activity_id = element.attr('activity-id');
   var response_id = element.attr('response-id');

   element.parent('li').find(".ajax-loader").show();
   var url = "/responses/" + response_id + "/activities/" + activity_id + "/" + approval_type
   $.post(url, {approve: true, "_method": "put"}, function (data) {
     element.parent('li').find(".ajax-loader").hide();
     if (data.status == 'success') {
       element.parent('li').html('<span>' + success_text + '</span>');
     }
   })
};

var activities_new = activities_create = activities_edit = activities_update = other_costs_edit = other_costs_new = other_costs_create = other_costs_update = {
  run: function () {
    var mode = document.location.search.split("=")[1]
    activity_classification();
    activity_form();
    if ($('.js_target_field').size() == 0) {
      $(document).find('.js_add_nested').trigger('click');
    }
    numericInputField(".js_implementer_spend, .js_implementer_budget");

    $('.ui-autocomplete-input').live('focusin', function () {
      var element = $(this).siblings('select');
      if(element.children('option').length < 2) { // because there is already one in to show default
        element.append(selectOptions);
      }
    });
  }
};

var activity_form = function () {

  $('#activity_project_id').change(function () {
    update_funding_source_selects();
  });

  $('#activity_name').live('keyup', function() {
    var parent = $(this).parent('li')
    var remaining = $(this).attr('data-maxlength') - $(this).val().length;
    $('.remaining_characters').html("(?) <span class=\"red\">" + remaining + " Characters Remaining</span>")
  });

  $('.js_implementer_select').live('change', function(e) {
    e.preventDefault();
    var element = $(this);
    if (element.val() == "-1") {
      $('.js_implementer_container').hide();
      $('.add_organization').show();
    }
  });

  $('.cancel_organization_link').live('click', function(e) {
    e.preventDefault();
    $('.organization_name').attr('value', '');
    $('.add_organization').hide();
    $('.js_implementer_container').show();
    $('.js_implementer_select').val(null);
  });

  $('.add_organization_link').live('click', function(e) {
    e.preventDefault();
    var name = $('.organization_name').val();
    $.post("/organizations.js", { "name" : name }, function(data){
      var data = $.parseJSON(data);
      $('.js_implementer_container').show();
      $('.add_organization').hide();
      if (isNaN(data.organization.id)) {
        $('.js_implementer_select').val(null);
      } else {
        $('.js_implementer_select').prepend("<option value=\'"+ data.organization.id + "\'>" + data.organization.name + "</option>");
        $('.js_implementer_select').val(data.organization.id);
      }
    });
    $('.organization_name').attr('value', '');
    $('.add_organization').slideToggle();
  });

  $('.js_target_field').live('keydown', function (e) {
    var block = $(this).parents('.js_targets');

    if (e.keyCode === 13) {
      e.preventDefault();
      block.find('.js_add_nested').trigger('click');
      block.find('.js_target_field:last').focus()
    }
  });

  $('.edit_button').live('click', function (e) {
    e.preventDefault();
    var element = $(this).parents('.fields');
    var fields = $.merge(element.prevAll('.fields'), element.nextAll('.fields'));

    element.find('.edit_block').show();
    element.find('.preview_block').hide();
    close_activity_funding_sources_fields(fields);
  });

  $('.js_implementer_spend').live('keyup', function(e) {
    var page_spend = parseFloat($('body').attr('page_spend'));
    var current_spend = implementer_page_total('spend');
    var difference = page_spend - current_spend;
    var total = parseFloat($('body').attr('total_spend'));
    $('.js_total_spend').find('.amount').html((total - difference).toFixed(2))
  });

  $('.js_implementer_budget').live('keyup', function(e) {
    var page_budget = parseFloat($('body').attr('page_budget'));
    var current_budget = implementer_page_total('budget');
    var difference = page_budget - current_budget;
    var total = parseFloat($('body').attr('total_budget'));
    $('.js_total_budget').find('.amount').html((total - difference).toFixed(2))
  });

  approveBudget();
  approveAsAdmin();
  commentsInit();
  dynamicUpdateTotalsInit();
  close_activity_funding_sources_fields($('.funding_sources .fields'));
  store_implementer_page_total();
};

var store_implementer_page_total = function(){
  $('body').attr('total_spend', $('.js_total_spend').find('.amount').html() )
  $('body').attr('total_budget', $('.js_total_budget').find('.amount').html() )

  if( $('.js_implementer_budget').length > 0 ){
    page_budget = implementer_page_total('budget')
    $('body').attr('page_budget',page_budget);
  }

  if( $('.js_implementer_spend').length > 0 ){
    page_spend = implementer_page_total('spend')
    $('body').attr('page_spend',page_spend);
  }
};

var implementer_page_total = function(type){
  var page_total = 0;
    inputs = (type == 'budget') ? $('.js_implementer_budget') : $('.js_implementer_spend');
    inputs.each(function(){
      float_val = parseFloat($(this).val());
      if( !(isNaN(float_val)) ){
        page_total += parseFloat($(this).val());
      }
    });
    return page_total
}

var admin_activities_new = admin_activities_create = admin_activities_edit = admin_activities_update = {
  run: function () {
    activity_form();
  }
};

var admin_users_new = admin_users_create = admin_users_edit = admin_users_update = {
  run: function () {
    var toggleMultiselect = function (element) {
      var ac_selected = $('#user_roles option[value="activity_manager"]:selected').length > 0;
      var dm_selected = $('#user_roles option[value="district_manager"]:selected').length > 0;
      if (element.val() && ac_selected) {
        $(".organizations").show().css('visibility', 'visible');
        $(".js_manage_orgs").slideDown();
      } else {
        $(".js_manage_orgs").slideUp();
        $(".organizations").hide().css('visibility', 'hidden');
      }

      if (element.val() && dm_selected) {
        $(".locations").show().css('visibility', 'visible');
        $(".js_manage_districts").slideDown();
      } else {
        $(".locations").hide().css('visibility', 'hidden');
        $(".js_manage_districts").slideUp();
      }
    };

    // choose either the full version
    $(".multiselect").multiselect({sortable: false});
    // or disable some features
    //$(".multiselect").multiselect({sortable: false, searchable: false});

    toggleMultiselect($('#user_roles'));

    $('#user_roles').change(function () {
      toggleMultiselect($(this));
    });
  }
}


var dashboard_index = {
  run: function () {
    $('.dropdown_trigger').click(function (e) {e.preventDefault()});
    if (typeof(_code_spent_values) !== 'undefined' || typeof(_code_budget_values) !== 'undefined') {
      drawPieChart('code_spent', _code_spent_values, 450, 300);
      drawPieChart('code_budget', _code_budget_values, 450, 300);
    }

    $('.dropdown_menu').hover(function (e){
      e.preventDefault();
      $('ul', this).slideDown(100);
      $('.dropdown_trigger').addClass('persist');
    }, function(e) {
      e.preventDefault();
      $('ul', this).slideUp(100);
      $('.dropdown_trigger').removeClass('persist');
    });
  }
};

var admin_organizations_create = admin_organizations_edit = {
  run: function () {
    $(".js_combobox" ).combobox();
    jsAutoTab();
  }
};

var projects_new = projects_create = projects_edit = projects_update = {
  run: function () {
    commentsInit();
    validateDates($('.start_date'), $('.end_date'));
    dynamicUpdateTotalsInit();
    numericInputField(".js_spend, .js_budget");
  }
}

// Autotabs a page using javascript
var jsAutoTab = function () {
  var tabindex = 1;
  $('input, select, textarea, checkbox').each(function() {
    if (this.type != "hidden") {
      var $input = $(this);
      $input.attr("tabindex", tabindex);
      tabindex++;
    }
  });
}

// DOM LOAD
$(function () {

  // prevent going to top when tooltip clicked
  $('.tooltip').live('click', function (e) {
    if ($(this).attr('href') === '#') {
      e.preventDefault();
    }
  });

  //combobox everywhere!
  $( ".js_combobox" ).combobox();

  // keep below combobox
  jsAutoTab();

  // tipsy tooltips everywhere!
  $('.tooltip').tipsy({gravity: $.fn.tipsy.autoWE, fade: true, live: true, html: true});

  //jquery tools overlays
  $(".overlay").overlay();

  var id = $('body').attr("id");
  if (id) {
    controller_action = id;
    if (typeof(window[controller_action]) !== 'undefined' && typeof(window[controller_action]['run']) === 'function') {
      window[controller_action]['run']();
    }
  }

  //observe form changes and alert user if form has unsaved data
  observeFormChanges($('.js_form'));

  $(".closeFlash").click(function (e) {
    e.preventDefault();
    $(this).parents('div:first').fadeOut("slow", function() {
      $(this).show().css({display: "none"});
    });
  });

  $('#page_tips_open').click(function (e) {
    e.preventDefault();
    $('#page_tips .desc').toggle();
    $('#page_tips .nav').toggle();
  });

  $('#page_tips_close').click(function (e) {
    e.preventDefault();
    $('#page_tips .desc').toggle();
    $('#page_tips .nav').toggle();
    $("#page_tips_open_link").effect("highlight", {}, 1500);
  });

  // Date picker
  $('.date_picker').live('click', function () {
    $(this).datepicker('destroy').datepicker({
      changeMonth: true,
      changeYear: true,
      yearRange: '2000:2025',
      dateFormat: 'dd-mm-yy'
    }).focus();
  });

  // Inplace edit
  $(".rest_in_place").rest_in_place();

  // clickable table rows
  $('.clickable tbody tr').click(function (e) {
    e.preventDefault();
    var element = $(e.target);

    if (element.attr('href')) {
      var href = element.attr('href');
    } else {
      var href = $(this).find("a").attr("href");
    }

    if (href) {
      window.location = href;
    }
  });

  // CSV file upload
  $("#csv_file").click( function(e) {
    e.preventDefault();
    $("#import").slideToggle();
  });

  // Show/hide getting started tips
  $('.js_tips_hide').click(function (e) {
    e.preventDefault();
    $('.js_tips_container').fadeOut();
    $.post('/profile/disable_tips', { "_method": "put" });
  });
});

