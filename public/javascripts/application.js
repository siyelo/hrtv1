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
};

function add_fields(link, association, content) {
  // before callback
  before_add_fields_callback(association);

  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).parent().before(content.replace(regexp, new_id));

  after_add_fields_callback(association);
};

var build_project_in_flow_row = function (edit_block, type, type_name, display_funder) {
  var total = edit_block.find('.js_' + type).val();

  var values = jQuery.map(edit_block.find(".js_" + type + "_quarters input"), function (e) {
    return $(e).val();
  });
  var labels = jQuery.map(edit_block.find(".js_" + type + "_quarters label"), function (e) {
    return $(e).text();
  });

  if (display_funder) {
    var organization = edit_block.find('.ff_from option:selected').text();
    var funder = $('<li/>').append(
      $('<span/>').text('Funder'),
      organization || 'N/A'
    );
  } else {
    var funder = $('<li/>');
  }

  var ul = $('<ul/>');
  for (var i = 0; i < values.length; i++) {
    ul.append(
      $('<li/>').append(
        $('<span/>').text(labels[i]),
        values[i] || 'N/A'
      )
    )
  }

  return $('<ul/>').append(
    funder,
    $('<li/>').append(
      $('<span/>').text(type_name),
      total || 'N/A'
    ),
    $('<li/>').append(ul)
  )
};

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


var close_project_in_flow_fields = function (fields) {
  $.each(fields, function () {
    var element = $(this);
    var edit_block = element.find('.edit_block');
    var preview_block = element.find('.preview_block');
    var manage_block = element.find('.manage_block');

    edit_block.hide();
    preview_block.html('');

    preview_block.append(build_project_in_flow_row(edit_block, 'spend', 'Spend', true))
    preview_block.append(build_project_in_flow_row(edit_block, 'budget', 'Budget', false))

    preview_block.show();

    manage_block.find('.edit_button').remove();
    manage_block.prepend(
      $('<a/>').attr({'class': 'edit_button', 'href': '#'}).text('Edit')
    )
  });
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
  if (association === 'in_flows') {
    close_project_in_flow_fields($('.funding_flows .fields'));
  }
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
  var submitBtn = block.find(".js_submit_btn");
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

var calculate_total_from_quarters = function (quarterInputs, total_box) {
  var total_ammount = 0;

  for (var i = 0; i < quarterInputs.length; i++) {
    var quarter_value = Number($(quarterInputs[i]).val());

    if (!isNaN(quarter_value)) {
      total_ammount += quarter_value;
    }
  }

  total_box.val(total_ammount);
};

var split_total_across_quarters = function (quarterInputs, value) {
  value = value.replace(",","");

  if (!isNaN(value)) {
    var quarter_value = value / quarterInputs.length;

    for (var i = 0; i < quarterInputs.length; i++) {
      $(quarterInputs[i]).val(quarter_value);
    }
  }
};

var quartersSplit = function (elements) {
  elements.live('keyup', function () {
    split_total_across_quarters($(this).parents("li:first").next().find('.js_fy_quarter'), $(this).val());
  });
};

var quartersSum = function (quarters) {
  quarters.live('keyup', function () {
    calculate_total_from_quarters($(this).parents('ul:first').find('.js_fy_quarter'), $(this).parents('li.js_row').prev().find('input'));
  });
};

var quartersInit = function () {
  quartersSplit($(".js_budget, .js_spend"));
  quartersSum($('.js_fy_quarter'));
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

var destroyOrganization = function (organization_id, type) {
  $.post('/admin/organizations/' + organization_id + '.js', {'_method': 'delete'}, function (data, status, response) {
    var data = $.parseJSON(data)
    response.status === 206 ? displayFlashForReplaceOrganization('error', data.message) : removeOrganizationFromLists(organization_id, type);
  });
}

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

    $(".destroy_btn").click(function (e) {
      e.preventDefault();
      var element = $(this);
      var type = element.parents('.box').attr('data-type');
      var select_element;

      select_element = (type === 'duplicate') ? $("#duplicate_organization_id") : $("#target_organization_id");

      if (confirm('Are you sure you want to delete "' + select_element.find('option:selected').text() + '"?')) {
        destroyOrganization(select_element.val(), type);
      }
    });
  }
};


var get_chart_element_id = function (element_type, options) {
  return element_type + "_" + options.id + "_" + options.chart_type + '_pie';
};

var get_pie_chart_element_endpoint = function (element_type, options) {
  return '/charts/' + element_type + '_pie?id=' + options.id + "&codings_type=" + options.codings_type + "&code_type=" + options.code_type;
};

var createPieChart = function (element_type, options) {
  var domId = get_chart_element_id(element_type, options)
  var urlEndpoint = get_pie_chart_element_endpoint(element_type, options)

  var so = new SWFObject("/ampie/ampie.swf", "ampie", "600", "300", "8", "#FFFFFF");
  so.addVariable("path", "/ampie/");
  so.addVariable("settings_file", encodeURIComponent("/ampie/ampie_settings.xml"));
  so.addVariable("data_file", encodeURIComponent(urlEndpoint));
  so.addVariable("additional_chart_settings", encodeURIComponent(
    '<settings>' +
      '<labels>' +
        '<label lid="0">' +
          '<text>' + options.title + '</title>' +
        '</label>' +
      '</labels>' +
    '</settings>')
  );
  so.write(domId);
};

var get_treemap_chart_element_endpoint = function (element_type, chart_type, id) {
  return '/charts/' + element_type + '_treemap?id=' + id + '&chart_type=' + chart_type;
};

var drawTreemap = function (element_type, element_id, chart_type, chart_element) {
  var urlEndpoint = get_treemap_chart_element_endpoint(element_type, chart_type, element_id);
  $.getJSON(urlEndpoint, function (response) {
    var data_rows = response;

    // Create and populate the data table.
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'Code');
    data.addColumn('string', 'Parent');
    data.addColumn('number', 'Market trade volume (size)');
    data.addColumn('number', 'Market increase/decrease (color)');
    data.addRows(data_rows)

    // Create and draw the visualization.
    var tree = new google.visualization.TreeMap(chart_element[0]);
    tree.draw(data, {
      minColor: '#35ff35',
      midColor: '#09c500',
      maxColor: '#08a100',
      headerHeight: 20,
      fontColor: 'black',
      fontSize: '12',
      headerColor: '#E6EDF3',
      showScale: false,
      showTooltips: false
    });

    // manual tipsy
    chart_element.tipsy({gravity: 'e', trigger: 'manual'})

    google.visualization.events.addListener(tree, 'onmouseover', function (e) {
      chart_element.attr('title', data_rows[e.row][0]);
      chart_element.tipsy('show');
    });

    google.visualization.events.addListener(tree, 'onmouseout', function (e) {
      chart_element.attr('title', '');
      chart_element.tipsy('hide');
    });
  });
};

var build_data_response_review_screen = function () {

  $('.tooltip').tipsy({gravity: 'w'});
  $('.comments_tooltip').tipsy({fade: true, gravity: 'w', html: true});
  $('.treemap_tooltip').tipsy({fade: true, gravity: 'sw', html: true, live: true});

  $('.project.entry_header').click(function (e) {
    collapse_expand(e, $(this), 'project');
  });

  $('.activity.entry_header').click(function (e) {
    collapse_expand(e, $(this), 'activity');
  });

  $('.sub_activity.entry_header').click(function (e) {
    collapse_expand(e, $(this), 'sub_activity');
  });

  // bind click events for tabs
  $(".classifications ul li").live('click', function (e) {
    e.preventDefault();
    var element = $(this);
    var root = element.parents('.activity_classifications');
    root.find(".classifications ul li").removeClass('selected');
    element.addClass('selected');
    root.find(".activity_classification > div").hide();
    root.find(".activity_classification > div:eq(" + element.index() + ")").show();
    // same as previous
    //root.find(".activity_classification > div::nth-child(" + (element.index() + 1) + ")").show();
  });

  // bind click events for tabs
  // Assumes this convention
  //  .tabs_nav
  //    ul > li, li, li
  // tab content
  //  .tabs > .tab1, .tab2, .tab3
  // BUT if you supply an id (e.g. tab1), it will use that
  // (useful if tab nav has non-clickable items in the list)
  $(".tabs_nav ul li").live('click', function (e) {
    e.preventDefault();
    var element = $(this);
    var target_tab = 'tab1'

    if (element.attr("id")) {
      target_tab = element.attr("id");
    } else {
      target_tab = "tab" + (element.index() + 1); //there is no tab0
    }
    element.parents('.tabs_nav').find("li").removeClass('selected');
    element.addClass('selected');
    var tabs = element.parents(".tabs_nav").next(".tabs")
    tabs.find("> div").hide();
    tabs.find('> div.' + target_tab).show();
  });

  // bind click events for project chart sub-tabs (Pie | Tree)
  $(".tabs ul.inline_tab li").live('click', function (e) {
    e.preventDefault();
    var element = $(this);
    if (element) {
      element.parents('.inline_tab').find('li').removeClass('selected');
      element.addClass('selected');
      var tab = element.parent('ul').parent();

      var matchArr = element.attr("class").match(/(.*)_tree/);

      // toggle tabs
      if (matchArr) {
        tab.find(".pie").hide()
        tab.find(".tree").show()

        // draw treemap chart
        var treemap_type = matchArr[1];
        if (treemap_type) {
          if (tab.find(".tree iframe").length == 0) {
            var chart_element = tab.find(".tree .chart");
            var element_type = tab.attr('data-chart_type');
            var element_id = tab.attr('data-id');
            drawTreemap(element_type, element_id, treemap_type, chart_element);
          }
        } else {
          throw "Unknown chart type:" + treemap_type;
        }
      } else {
        tab.find(".tree").hide()
        tab.find(".pie").show()
      }
    }
   });

  // Data Response charts
  createPieChart("data_response", {id: _dr_id, title: "MTEF Budget", chart_type: 'mtef_budget', codings_type: 'CodingBudget', code_type: 'Mtef'});
  createPieChart("data_response", {id: _dr_id, title: "MTEF Expenditure", chart_type: 'mtef_spend', codings_type: 'CodingSpend', code_type: 'Mtef'});
  createPieChart("data_response", {id: _dr_id, title: "NSP Budget", chart_type: 'nsp_budget', codings_type: 'CodingBudget', code_type: 'Nsp'});
  createPieChart("data_response", {id: _dr_id, title: "NSP Expenditure", chart_type: 'nsp_spend', codings_type: 'CodingSpend', code_type: 'Nsp'});
  createPieChart("data_response", {id: _dr_id, title: "Input Budget", chart_type: 'cc_budget', codings_type: 'CodingBudgetCostCategorization', code_type: 'CostCategory'});
  createPieChart("data_response", {id: _dr_id, title: "Input Expenditure", chart_type: 'cc_spend', codings_type: 'CodingSpendCostCategorization', code_type: 'CostCategory'});

  // Project charts
  $.each(_projects, function (i, id) {
    createPieChart("project", {id: id, title: "MTEF Budget", chart_type: 'mtef_budget', codings_type: 'CodingBudget', code_type: 'Mtef'});
    createPieChart("project", {id: id, title: "MTEF Expenditure", chart_type: 'mtef_spend', codings_type: 'CodingSpend', code_type: 'Mtef'});
    createPieChart("project", {id: id, title: "NSP Budget", chart_type: 'nsp_budget', codings_type: 'CodingBudget', code_type: 'Nsp'});
    createPieChart("project", {id: id, title: "NSP Expenditure", chart_type: 'nsp_spend', codings_type: 'CodingSpend', code_type: 'Nsp'});
  createPieChart("project", {id: id, title: "Input Budget", chart_type: 'cc_budget', codings_type: 'CodingBudgetCostCategorization', code_type: 'CostCategory'});
  createPieChart("project", {id: id, title: "Input Expenditure", chart_type: 'cc_spend', codings_type: 'CodingSpendCostCategorization', code_type: 'CostCategory'});
    //createPieChart("project", {id: id, title: "HSSPII Strat Program Budget", chart_type: 'stratprog_budget', codings_type: 'HsspBudget', code_type: 'HsspStratProg'});
    //createPieChart("project", {id: id, title: "HSSPII Strat Objective Budget", chart_type: 'stratobj_budget', codings_type: 'HsspBudget', code_type: 'HsspStratObj'});
    //createPieChart("project", {id: id, title: "HSSPII Strategic Program Expenditure", chart_type: 'stratprog_spend', codings_type: 'HsspSpend', code_type: 'HsspStratProg'});
    //createPieChart("project", {id: id, title: "HSSPII Strategic Objective Expenditure", chart_type: 'stratobj_spend', codings_type: 'HsspSpend', code_type: 'HsspStratObj'});
  });
};

var admin_responses_show = {
  run: function (){
    build_data_response_review_screen();
    ajaxifyResources('comments');
  }
};

var responses_review = {
  run: function () {
    build_data_response_review_screen();
    ajaxifyResources('comments');
  }
};

var organizations_edit = {
  run: function () {
    $( ".js_combobox" ).combobox(); // for pretty currency select
  }
};

var policy_maker_data_responses_show = {
  run: function () {
    build_data_response_review_screen();
    ajaxifyResources('comments');
  }
};

var classifications_edit = {
  run: function () {

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
    addCollabsibleButtons('tab1');

    // prevent going to top on click on tool
    $('.tooltip').live('click', function (e) {
      if ($(this).attr('href') === '#') {
        e.preventDefault();
      }
    });

    $('.js_upload_btn').click(function (e) {
      e.preventDefault();
      $(this).parents('.upload').find('.upload_box').toggle();
    });

    $('.js_submit_btn').click(function (e) {
      $(this).next('.ajax-loader').show();
    });

    $('#js_budget_to_spend').click(function (e) {
      e.preventDefault();
      if(confirm('This will overwrite all Expenditure amounts with the Budget amounts. Are you sure?')){
        $('.js_budget input').each(function () {
          var element = $(this);
          element.parents('.js_values').find('.js_spend input').val(element.val());
        });
      };
    });

    $('#js_spend_to_budget').click(function (e) {
      e.preventDefault();
      if(confirm('This will overwrite all Budget amounts with the Expenditure amounts. Are you sure?')){
        $('.js_spend input').each(function () {
          var element = $(this);
          element.parents('.js_values').find('.js_budget input').val(element.val());
        });
      };
    });
  }
};

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
      if(split == "/images/icon_expand.png") {
        $('.' + image).attr('src', "/images/icon_collapse.png");
      }else{
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

var drawTreemapChart = function (id, data_rows, treemap_gravity) {
  if (typeof(data_rows) === "undefined") {
    return;
  }

  var chart_element = $("#" + id);
  chart_element.css({width: "450px", height: "300px"});

  var data = new google.visualization.DataTable();
  data.addColumn('string', 'Code');
  data.addColumn('string', 'Parent');
  data.addColumn('number', 'Market trade volume (size)');
  data.addColumn('number', 'Market increase/decrease (color)');
  data.addRows(data_rows)

  // Create and draw the visualization.
  var tree = new google.visualization.TreeMap(chart_element[0]);
  tree.draw(data, {
    minColor: '#35ff35',
    midColor: '#09c500',
    maxColor: '#08a100',
    headerHeight: 20,
    fontColor: 'black',
    fontSize: '12',
    headerColor: '#E6EDF3',
    showScale: false,
    showTooltips: false
  });

  // manual tipsy
  if (typeof(treemap_gravity) === "undefined") {
    treemap_gravity = 'e'
  }
  chart_element.tipsy({gravity: treemap_gravity, trigger: 'manual'})

  google.visualization.events.addListener(tree, 'onmouseover', function (e) {
    chart_element.attr('title', data_rows[e.row][0]);
    chart_element.tipsy('show');
  });

  google.visualization.events.addListener(tree, 'onmouseout', function (e) {
    chart_element.attr('title', '');
    chart_element.tipsy('hide');
  });
}

var reports_districts_show = reports_countries_show = {
  run: function () {
    drawPieChart('budget_i_pie', _budget_i_values, 400, 250);
    drawPieChart('spend_i_pie', _spend_i_values, 400, 250);
  }
};

var reports_districts_funders = reports_countries_funders = {
  run: function () {
    drawPieChart('budget_ufs_pie', _budget_ufs_values, 400, 250);
    drawPieChart('budget_fa_pie', _budget_fa_values, 400, 250);
    drawPieChart('spend_ufs_pie', _spend_ufs_values, 400, 250);
    drawPieChart('spend_fa_pie', _spend_fa_values, 400, 250);
  }
}

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
    if (_pie) {
      drawPieChart('code_spent', _code_spent_values, 450, 300);
      drawPieChart('code_budget', _code_budget_values, 450, 300);
    } else {
      drawTreemapChart('code_spent', _code_spent_values, 'w');
      drawTreemapChart('code_budget', _code_budget_values, 'e');
    }
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
    if (_treemap) {
      drawTreemapChart('code_spent', _code_spent_values, 'w');
      drawTreemapChart('code_budget', _code_budget_values, 'e');
    } else {
      drawPieChart('code_spent', _code_spent_values, 450, 300);
      drawPieChart('code_budget', _code_budget_values, 450, 300);
    }
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
    if (_treemap) {
      drawTreemapChart('code_spent', _code_spent_values, 'w');
      drawTreemapChart('code_budget', _code_budget_values, 'e');
    } else {
      drawPieChart('code_spent', _code_spent_values, 450, 300);
      drawPieChart('code_budget', _code_budget_values, 450, 300);
    }
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
    if (_pie) {
      drawPieChart('code_spent', _code_spent_values, 450, 300);
      drawPieChart('code_budget', _code_budget_values, 450, 300);
    } else {
      drawTreemapChart('code_spent', _code_spent_values, 'w');
      drawTreemapChart('code_budget', _code_budget_values, 'e');
    }
  }
};

var update_funding_source_selects = function () {
  var project_id = $('#activity_project_id').val();
  var fs_selects = $('.ff_organization');
  if (project_id) {
    var options = ['<option value=""></option>'];
    $.each(_funding_sources[project_id], function (i) {
      options.push('<option value="' + this[1] + '">' + this[0] + '</option>');
    });
    var options_string = options.join('\n');

    $.each(fs_selects, function (i) {
      var element = $(this);
      if (element.html() !== options_string) {
        var value = element.val();
        element.html(options_string);
        element.val(value);
      }
    });
  } else {
    $.each(fs_selects, function (i) {
      var element = $(this);
      $(this).html('<option value=""></option>');
    })
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
  $('.js_submit_btn').live('click', function (e) {
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
      if(!menu.is('.persist')){
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

    $('.tooltip_projects').tipsy({gravity: 'e', live: true, html: true});

    commentsInit();

    approveBudget();
  }
};

var projects_bulk_edit = {
  run: function () {

    $('.parent_project').live('change', function(e) {
      e.preventDefault();
      var element = $(this);
      var tableRow = element.parents('tr');
      url = "/responses/" + _response_id + "/projects/" + element.val() + ".js"
      $.get(url, function(data) {
        var data = $.parseJSON(data);
        id = tableRow.find('.funder_project_description').html(data.project.description);
      });
    });
  }
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


var activities_bulk_create = {
  run: function () {

    initDemoText($('*[data-hint]'));

    $('.activity_box .header').live('click', function (e) {
      e.preventDefault();
      var activity_box = $(this).parents('.activity_box');

      $.each($.merge(activity_box.prevAll('.activity_box'), activity_box.nextAll('.activity_box')), function () {
        $(this).find('.main').hide();
      });
      activity_box.find('.main').toggle();
    });

    focusDemoText($('*[data-hint]'));
    blurDemoText($('*[data-hint]'));

    $('.save_btn').live('click', function (e) {
      e.preventDefault();
      var element = $(this);
      var form = element.parents('form');
      var ajaxLoader = element.next('.ajax-loader');
      var activityBox = element.parents('.activity_box');

      // reset input values before submit !!
      form.find('*[data-hint]').each(function() {
        var input = $(this);
        var demo_text = input.attr('data-hint');

        if (input.val() == demo_text) {
          input.val('');
        }
      });

      ajaxLoader.show();

      $.post(buildUrl(form.attr('action')), form.serialize(), function (data) {
        activityBox.html(data.html);
        initDemoText(activityBox.find('*[data-hint]'));
        activityBox.find(".js_combobox").combobox();
      });
    });

    $(".js_combobox").combobox(); // for pretty currency select
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

var activities_new = activities_create = activities_edit = activities_update = {
  run: function () {
    activity_form();
  }
};

var activity_form = function () {
  $('#activity_project_id').change(function () {
    update_funding_source_selects();
  });

  $('.js_implementer_select').live('change', function(e) {
    e.preventDefault();
    var element = $(this);
    if(element.val() == "-1"){
      $('.implementer_container').hide();
      $('.add_organization').show();
    }
  });

  $('.cancel_organization_link').live('click', function(e) {
    e.preventDefault();
    $('.organization_name').attr('value', '');
    $('.add_organization').hide();
    $('.implementer_container').show();
    $('.js_implementer_select').val(null);
  });

  $('.add_organization_link').live('click', function(e) {
    e.preventDefault();
    var name = $('.organization_name').val();
    $.post("/organizations.js", { "name" : name }, function(data){
      var data = $.parseJSON(data);
      $('.implementer_container').show();
      $('.add_organization').hide();
      if(isNaN(data.organization.id)){
        $('.js_implementer_select').val(null);
      }else{
        $('.js_implementer_select').prepend("<option value=\'"+ data.organization.id + "\'>" + data.organization.name + "</option>");
        $('.js_implementer_select').val(data.organization.id);
      }
    });
    $('.organization_name').attr('value', '');
    $('.add_organization').slideToggle();
  });

  if (typeof(namespace) === 'undefined') {
    validateDates($('#activity_start_date'), $('#activity_end_date'));
  } else {
    // it injects the namespace in the activity form !?
    validateDates($('#' + namespace + '_activity_start_date'), $('#' + namespace + '_activity_end_date'));
  }

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

  approveBudget();
  approveAsAdmin();
  commentsInit();
  quartersInit();
  close_activity_funding_sources_fields($('.funding_sources .fields'));
};

var admin_activities_new = admin_activities_create = admin_activities_edit = admin_activities_update = {
  run: function () {
    activity_form();
  }
};

var admin_users_new = admin_users_create = admin_users_edit = admin_users_update = {
  run: function () {
    var toggleMultiselect = function (element) {
      var ac_selected = $('#user_roles option[value="activity_manager"]:selected').length > 0;
      if (element.val() && ac_selected) {
        $(".organizations").show().css('visibility', 'visible');
      } else {
        $(".organizations").hide().css('visibility', 'hidden');
      }

      if (element.val()) {
        $(".locations").show().css('visibility', 'visible');
      } else {
        $(".locations").hide().css('visibility', 'hidden');
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

    $( ".js_combobox" ).combobox();

  }
}

var dashboard_index = {
  run: function () {
    $('.dropdown_trigger').click(function (e) {e.preventDefault()});

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
    $( ".js_combobox" ).combobox();
  }
};


var other_costs_new = other_costs_create = other_costs_edit = other_costs_update = {
  run: function () {
    validateDates($('#other_cost_start_date'), $('#other_cost_end_date'));

    $('.js_implementer_select').live('change', function(e) {
      e.preventDefault();
      var element = $(this);
      if(element.val() == "-1"){
        $('.implementer_container').hide();
        $('.add_organization').show();
      }
    });

    $('.cancel_organization_link').live('click', function(e) {
      e.preventDefault();
      $('.organization_name').attr('value', '');
      $('.add_organization').hide();
      $('.implementer_container').show();
      $('.js_implementer_select').val(null);
    });

    $('.add_organization_link').live('click', function(e) {
      e.preventDefault();
      var name = $('.organization_name').val();
      $.post("/organizations.js", { "name" : name }, function(data){
        var data = $.parseJSON(data);
        $('.implementer_container').show();
        $('.add_organization').hide();
        if(isNaN(data.organization.id)){
          $('.js_implementer_select').val(null);
        }else{
          $('.js_implementer_select').prepend("<option value=\'"+ data.organization.id + "\'>" + data.organization.name + "</option>");
          $('.js_implementer_select').val(data.organization.id);
        }
      });
      $('.organization_name').attr('value', '');
      $('.add_organization').slideToggle();
    });

    approveBudget();
    approveAsAdmin();
    quartersInit();
  }
};

var projects_new = projects_create = projects_edit = projects_update = {
  run: function () {
    $('.edit_button').live('click', function (e) {
      e.preventDefault();
      var element = $(this).parents('.fields');
      var fields = $.merge(element.prevAll('.fields'), element.nextAll('.fields'));

      element.find('.edit_block').show();
      element.find('.preview_block').hide();
      close_project_in_flow_fields(fields);
    });

    commentsInit();
    quartersInit();
    validateDates($('#project_start_date'), $('#project_end_date'));
    close_project_in_flow_fields($('.funding_flows .fields'));
  }
}


$(function () {

  // tipsy tooltips everywhere!
  $('.tooltip').tipsy({gravity: 'w', delayOut: 800, fade: true, live: true, html: true});

  //jquery tools overlays
  $(".overlay").overlay();

  var id = $('body').attr("id");
  if (id) {
    controller_action = id;
    if (typeof(window[controller_action]) !== 'undefined' && typeof(window[controller_action]['run']) === 'function') {
      window[controller_action]['run']();
    }
  }

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
      dateFormat: 'yy-mm-dd'
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
  $('#tips_hide').click(function () {
    $('#gs_container').remove();
    $.post('/profile/disable_tips', { "_method": "put" });
  });
});

