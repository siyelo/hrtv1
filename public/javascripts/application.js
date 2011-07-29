/* Nested model forms BEGIN */
function inspect(obj)
{
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

function getNodeText($el){
  var nodeContent;
  var nContents = $el.contents().filter(function() {
    // remove empty text nodes and comments
    return (this.nodeType == 1) || (this.nodeType == 3 && $.trim(this.nodeValue).length>0);
  });
  // return either an empty string or the node's value
  if (nContents[0] && nContents[0].nodeType == 3) {
    // Text node : take it's value
    nodeContent = nContents[0].nodeValue;
  } else if (nContents[0] && nContents[0].nodeType == 1) {
    // Element node : take the contents
    nodeContent = $(nContents[0]).text();
  } else {
    nodeContent = "";
  }
  return $.trim(nodeContent);
};

var build_funding_source_row = function (edit_block) {
  var organization = edit_block.find('.ff_organization option:selected').text();
  var spend = '';
  var budget = '';

  spend = $('<li/>').append(
    $('<span/>').text('Past Expenditure'),
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


var close_funding_flow_fields = function (fields) {
  $.each(fields, function () {
    var element = $(this);
    var edit_block = element.find('.edit_block');
    var preview_block = element.find('.preview_block');
    var manage_block = element.find('.manage_block');

    edit_block.hide();
    preview_block.html('');

    preview_block.append(build_funding_source_row(edit_block))

    preview_block.show();

    manage_block.find('.edit_button').remove();
    manage_block.prepend(
      $('<a/>').attr({'class': 'edit_button', 'href': '#'}).text('Edit')
    )
  });
};


var register_funding_flow_edit_event = function () {
  $('.edit_button').live('click', function (e) {
    e.preventDefault();
    var element = $(this).parents('.fields');
    var fields = $.merge(element.prevAll('.fields'), element.nextAll('.fields'));

    element.find('.edit_block').show();
    element.find('.preview_block').hide();
    close_funding_flow_fields(fields);
  });
};

var before_add_fields_callback = function (association) {
  if (association === 'in_flows') {
    close_funding_flow_fields($('.funding_flows .fields'));
  }
  if (association === 'funding_sources') {
    close_funding_flow_fields($('.funding_sources .fields'));
  }
};

var after_add_fields_callback = function (association) {
  // show the jquery autocomplete combobox instead of
  // standard dropdowns
  $( ".combobox" ).combobox();
  $( ".ui-autocomplete-input" ).attr('id', 'theCombobox');
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


var organizationCombobox = function (rootElement) {
  // show the jquery autocomplete combobox instead of
  // standard dropdown
  // setting the id for cucumber tests
  rootElement.find( ".combobox" ).combobox();
  rootElement.find( ".ui-autocomplete-input" ).attr('id', 'theCombobox');

  rootElement.find('.organization_select').live('change', function(e) {
    e.preventDefault();
    var element = $(this);
    if(element.val() == "-1"){
      rootElement.find('.implementer_container').hide();
    }
  });
}

// The route is members/index but the controller is users
var users_index = users_create = {
  run: function () {
    $('#js_user_create_btn').live('click', function (e) {
      e.preventDefault();
      var form = $('.js_new_member')
      $(this).parents('.buttons').find('.ajax-loader').show();

      $.post(buildJsonUrl(form.attr('action')), form.serialize(), function (data, status, response) {
        if (data.status === 'error') {
          $('.js_new_member').replaceWith(data.form);
        } else {
          $('#js_organiations_tbl tbody').prepend(data.row);
          $('.js_new_member').replaceWith(data.form);
          var message = $('#js_user_create_form .js_message');
          message.text(data.message)
          setTimeout(function () {
            message.fadeOut(3000, function () {
              message.show();
            })
          }, 3000);
        }
        // trigger organiazion combobox widget
        organizationCombobox($('#js_user_create_form'));
      });
    });

    // trigger organiazion combobox widget
    organizationCombobox($('#js_user_create_form'));
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

  approve_activity_checkbox();

  // Ajax load of classifications for activities
  $.each($('.activity_classifications'), function (i, element) {
    element = $(element);
    var activity_id = element.attr('data-activity_id');
    var response_id = element.attr('data-response_id');
    var other_cost = element.attr('data-other_costs');
    var url =  '/responses/' + response_id + '/activities/' +
      activity_id + '/classifications?other_costs=' + other_cost;
    $.get(url, function (data) {element.html(data)});
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
    $( ".combobox" ).combobox(); // for pretty currency select
  }
};

var policy_maker_data_responses_show = {
  run: function () {
    build_data_response_review_screen();
    ajaxifyResources('comments');
  }
};

var code_assignments_show = {
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

    approve_activity_checkbox();

    // prevent going to top on click on tool
    $('.tooltip').live('click', function (e) {
      e.preventDefault();
    });

    $('.js_upload_btn').click(function (e) {
      e.preventDefault();
      $(this).parents('.upload').find('.upload_box').toggle();
    });

    $('.js_submit_btn').click(function (e) {
      $(this).next('.ajax-loader').show();
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

    drawPieChart('budget_ufs_pie', _budget_ufs_values, 400, 250);
    drawPieChart('budget_fa_pie', _budget_fa_values, 400, 250);
    drawPieChart('budget_i_pie', _budget_i_values, 400, 250);
    drawPieChart('spend_ufs_pie', _spend_ufs_values, 400, 250);
    drawPieChart('spend_fa_pie', _spend_fa_values, 400, 250);
    drawPieChart('spend_i_pie', _spend_i_values, 400, 250);

    if (_pie) {
      drawPieChart('code_spent', _code_spent_values, 450, 300);
      drawPieChart('code_budget', _code_budget_values, 450, 300);
    } else {
      drawTreemapChart('code_spent', _code_spent_values, 'w');
      drawTreemapChart('code_budget', _code_budget_values, 'e');
    }
  }
};

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

var reports_countries_show = {
  run: function () {
    drawPieChart('budget_ufs_pie', _budget_ufs_values, 400, 250);
    drawPieChart('budget_fa_pie', _budget_fa_values, 400, 250);
    drawPieChart('budget_i_pie', _budget_i_values, 400, 250);
    drawPieChart('spend_ufs_pie', _spend_ufs_values, 400, 250);
    drawPieChart('spend_fa_pie', _spend_fa_values, 400, 250);
    drawPieChart('spend_i_pie', _spend_i_values, 400, 250);

    if (_pie) {
      drawPieChart('code_spent', _code_spent_values, 450, 300);
      drawPieChart('code_budget', _code_budget_values, 450, 300);
    } else {
      drawTreemapChart('code_spent', _code_spent_values, 'w');
      drawTreemapChart('code_budget', _code_budget_values, 'e');
    }
  }
}

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

var projects_new = projects_create = projects_edit = projects_update = {
  run: function () {

    // show the jquery autocomplete combobox instead of standard dropdown
    $( ".combobox" ).combobox(); // for currency dropdown
                                // the nested funding source init should be
                                // handled by the "add row" js callback
    $( ".ui-autocomplete-input" ).attr('id', 'theCombobox'); //cucumber

    validateDates($('#project_start_date'), $('#project_end_date'));

    register_funding_flow_edit_event();
    close_funding_flow_fields($('.funding_flows .fields'));

    $('#project_name').keydown(function (e) {
      var project_name_input = $(this);
      var inline_errors = project_name_input.parents('li:first').find('.inline-errors');

      if (project_name_input.val().length > 50) {
        if (inline_errors.length == 0) {
        project_name_input.next().after('<p class="inline-errors">is too long (maximum is 50 characters)</p>');
        }
      } else {
        inline_errors.remove();
      }
    });
  }
};

var import_export = {
  // find the purpose 'row' closest relative to given link
  init: function() {
    $('.js_upload_btn').click(function (e) {
      e.preventDefault();
      $(this).parents('td').find('.upload_box').slideToggle();
    });

    $('#import_export').click(function (e) {
      e.preventDefault();
      $('#import_export_box .upload_box').slideToggle();
    });
  }
};


var projects_index = {
  run: function () {
    import_export.init();
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
        activityBox.html(data);
        initDemoText(activityBox.find('*[data-hint]'));
      });
    });


    $('.activity_project_id').live('change', function () {
      var element = $(this);
      var _project_id = element.val();
      var form = element.parents('form');
      var matches = form.attr('action').match(/responses\/(.*)\/activities\/?(.*)/);
      var activityBox = element.parents('.activity_box');
      _response_id = matches[1];
      _activity_id = matches[2];

      if (_project_id) {
        var url = '/responses/' + _response_id +
        '/activities/project_sub_form?' + 'project_id=' + _project_id;
        if (_activity_id) {
          url += '&activity_id=' + _activity_id;
        }
        $.get(url, function (data) {
          activityBox.find('.project_sub_form_fields').html(data)
          activityBox.find('.project_sub_form_fields').show();
          activityBox.find('.project_sub_form_hint').hide();
        });
      } else {
        activityBox.find('.project_sub_form_fields').hide();
        activityBox.find('.project_sub_form_hint').show();
      }
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



var activity_form = function () {
  $('#activity_project_id').change(function () {
    update_funding_source_selects();

    var element = $('#project_sub_form');
    var _project_id = $(this).val();
    if (_project_id) {
      var url = '/responses/' + _response_id +
      '/activities/project_sub_form?' + 'project_id=' + _project_id;
      if (_activity_id) {
        url += '&activity_id=' + _activity_id;
      }
      $.get(url, function (data) {
        $('#project_sub_form_fields').html(data)
        $('#project_sub_form_fields').show();
        $('#project_sub_form_hint').hide();
      });
    } else {
      $('#project_sub_form_fields').hide();
      $('#project_sub_form_hint').show();
    }
  });

  // show the jquery autocomplete combobox instead of
  // standard dropdown
  // setting the id for cucumber tests
  $( ".combobox" ).combobox();
  $( ".ui-autocomplete-input" ).attr('id', 'theCombobox');

  $('.implementer_select').live('change', function(e) {
    e.preventDefault();
    var element = $(this);
    if(element.val() == "-1"){
      $('.implementer_container').hide();
    }
  });

  if (typeof(namespace) === 'undefined') {
    validateDates($('#activity_start_date'), $('#activity_end_date'));
  } else {
    // namespace is from project_sub_form,
    // it injects the namespace in the activity form !?
    validateDates($('#' + namespace + '_activity_start_date'), $('#' + namespace + '_activity_end_date'));
  }

  register_funding_flow_edit_event();
  close_funding_flow_fields($('.funding_sources .fields'));
};


var admin_activities_edit = admin_activities_update = {
  run: function () {
    activity_form();


  }
};

var activities_new = activities_create = activities_edit = activities_update = {
  run: function () {
    activity_form();
  }
};

var other_costs_new = other_costs_create = other_costs_edit = other_costs_update = {
  run: function () {
    validateDates($('#other_cost_start_date'), $('#other_cost_end_date'));

    $(".combobox").combobox();
    $(".ui-autocomplete-input").attr('id', 'theCombobox');

  }
};

var changeRowspan = function (element, value) {
  var projectTd = element.parents('tr').prevAll('.js_project_row:first').find('td');
  projectTd.attr('rowspan', projectTd.attr('rowspan') + value);
};

var getTotal = function (amounts) {
  var total = 0;
  for (var i = 0; i < amounts.length; i++) {
    var amount = Number(amounts[i]);
    if (!isNaN(amount)) {
      total += amount;
    }
  }
  return roundAmount(total);
};

var roundAmount = function (amount) {
  return amount ? Math.round(amount * 10) / 10 : 0;
};

var getInputTotal = function (elements) {
  total = 0;

  $.each(elements, function () {
    var element = $(this);
    var amount  = element.text();
    var rate    = element.attr('data-rate');
    if (!isNaN(amount) && !isNaN(rate)) {
      total += amount * rate;
    }
  });

  return roundAmount(total);
};


var updateSpendColumnValues = function (element) {
  var tr = element.parents('tr:first');

  // project total for spend
  var elements = tr.prevAll('.js_project_row:first').nextUntil('.js_project_row').find('.js_spend_column_amount:first');
  var amounts = jQuery.map(elements, function (e) { return $(e).val();});
  tr.nextAll('.js_project_total_row:first').find('.js_project_total_spend_amount').text(getTotal(amounts));

  // all projects total for spend
  var total = getInputTotal($('.js_project_total_spend_amount'));
  $('.js_projects_total_row .js_projects_total_spend_amount').text(total);
};

var updateBudgetColumnValues = function (element) {
  var tr = element.parents('tr:first');

  // project total for budget
  var elements = tr.prevAll('.js_project_row:first').nextUntil('.js_project_row').find('.js_budget_column_amount:first');
  var amounts = jQuery.map(elements, function (e) { return $(e).val();});
  tr.nextAll('.js_project_total_row:first').find('.js_project_total_budget_amount').text(getTotal(amounts));

  // all projects total for budget
  var total = getInputTotal($('.js_project_total_budget_amount'));
  $('.js_projects_total_row .js_projects_total_budget_amount').text(total);
};


var workplans_index = {
  run: function () {

    import_export.init();
    
    $(document).ready(function() {
      $('.js_add_project').trigger('click');
    });

    var updateValues = function (element) {
      var tr = element.parents('tr:first');

      // activity total
      var elements = tr.find('.js_qamount');
      var amounts = jQuery.map(elements, function (e) { return $(e).val();});
      tr.find('.js_activity_total').text(getTotal(amounts));

      // project total
      var elements = tr.prevAll('.js_project_row:first').nextUntil('.js_project_total_row').find('.js_activity_total');
      var amounts = jQuery.map(elements, function (e) { return $(e).text();});
      tr.nextAll('.js_project_total_row:first').find('.js_project_total').text(getTotal(amounts));

      // all projects total
      var elements = $('.js_project_total_row .js_project_total');
      var amounts = jQuery.map(elements, function (e) { return $(e).text();});
      $('.js_projects_total_row .js_projects_total_amount').text(getTotal(amounts));
    };

    initDemoText($('*[data-hint]'));
    focusDemoText($('*[data-hint]'));
    blurDemoText($('*[data-hint]'));

    // quarters sum

    //$('.js_qamount').live('keydown', function (e) {
      //var code = e.keyCode || e.which;

      //// http://www.cambiaresearch.com/c4/702b8cd1-e5b0-42e6-83ac-25f0306e3e25/javascript-char-codes-key-codes.aspx
      //var goodCode = code <= 57; // 0-9

      //if (!goodCode) {
        //e.preventDefault();
      //}
    //});

    $('.js_spend_column_amount').live('keyup', function (e) {
      var element = $(this);
      updateSpendColumnValues(element);
    });

    $('.js_budget_column_amount').live('keyup', function (e) {
      var element = $(this);
      updateBudgetColumnValues(element);
    });

    $('body').click(function (e) {
      if (!$(e.target).parent().hasClass('js_activity_total')) {
        $('.js_activity_row .total_amount input').trigger('blur')
      }
    });

    // activity
    $('.add_activity, .add_other_cost').live('click', function (e) {
      e.preventDefault();
      var element = $(this);
      var type = element.hasClass('add_activity') ? 'activity' : 'other_cost';

      if (element.hasClass('disabled')) {
        return;
      }

      element.addClass('disabled');

      var project_id = element.parents('tr').attr('data-project_id');
      var url = '/responses/' + _response_id + '/activities/new.json?type=' + type + '&project_id=' + project_id;

      $.get(url, function (data) {
        element.addClass('disabled');
        currentTr = element.parents('tr');
        currentTr.before(data.html);
        initDemoText(currentTr.prev('tr').find('*[data-hint]'));
        changeRowspan(element, 1);
        currentTr.prev('tr').find('#activity_name').trigger('focus');
      });
    });

    $('.js_cancel_add_activity').live('click', function (e) {
      e.preventDefault();
      var element = $(this);
      changeRowspan(element, -1);
      element.parents('tr:first').next('tr').find('.add_activity, .add_other_cost').removeClass('disabled');
      element.parents('tr:first').remove();
    });

    $('.js_save_activity').live('click', function (e) {
      e.preventDefault();
      var element = $(this);
      var form = element.parents('.new_activity_form');
      var ajaxLoader = element.parents('ol').find('.ajax-loader');

      removeDemoText(form.find('*[data-hint]'));
      ajaxLoader.show();
      $.post(buildUrl(form.attr('action')), form.serialize(), function (data) {
        if (data.status) {
          var box = element.parents('tr');
          var add_btn = element.parents('tr').next('tr').find('.disabled');

          if (add_btn.hasClass('add_activity')) {
            element.parents('tr').prevAll('.js_other_costs_subheading:first').before(data.html);
          } else if (add_btn.hasClass('add_other_cost')) {
            element.parents('tr').before(data.html);
          }
          ajaxLoader.hide();
          changeRowspan(element, 1);
          var inputs = form.find('*[data-hint]');
          form.find('#activity_name').val('');
          form.find('#activity_description').val('');
          initDemoText(form.find('*[data-hint]'));
          form.find('#activity_name').trigger('focus'); 
          $('#workplan').find('.save_btn').show();
        } else {
          var newTr = $(data.html);
          var box = element.parents('tr');
          box.replaceWith(newTr);
          initDemoText(newTr.find('*[data-hint]'));
        }
      });
    });


    // project
    $('.js_add_project').live('click', function (e) {
      e.preventDefault();
      var element = $(this);

      if (element.hasClass('disabled')) {
        return;
      }

      element.addClass('disabled');

      var url = '/responses/' + _response_id + '/projects/new.json';

      $.get(url, function (data) {
        currentTr = element.parents('tr');
        currentTr.before(data.html);
        initDemoText(currentTr.prev('tr').find('*[data-hint]'));
        //changeRowspan(element, 1);
      });
    });

    $('.cancel_add_project').live('click', function (e) {
      e.preventDefault();
      var element = $(this);
      //changeRowspan(element, -1);
      element.parents('tr').next('tr').find('.js_add_project').removeClass('disabled');
      element.parents('tr').remove();
    });

    $('.save_project').live('click', function (e) {
      e.preventDefault();
      var element = $(this);
      var form = element.parents('.new_project_form');
      var ajaxLoader = element.parents('ol').find('.ajax-loader');

      removeDemoText(form.find('*[data-hint]'));
      ajaxLoader.show();

      $.post(buildUrl(form.attr('action')), form.serialize(), function (data) {
        if (data.status) {
          var box = element.parents('tr');
          element.parents('tr').next('tr').find('.js_add_project').removeClass('disabled');
          box.after(data.html);
          box.remove();
          $('.js_add_project').trigger('click');;
          $('.add_activity').last().trigger('click');;
        } else {
          var newTr = $(data.html);
          var box = element.parents('tr');
          box.replaceWith(newTr);
          initDemoText(newTr.find('*[data-hint]'));
        }
      });
    });
  }
}

var funders_index = {
  run: function () {

    $('.add_funder').live('click', function (e) {
      e.preventDefault();
      var element = $(this);

      if (element.hasClass('disabled')) {
        return;
      }

      element.addClass('disabled');

      var project_id = element.parents('tr').attr('data-project_id');
      var url = '/responses/' + _response_id + '/funders/new.json?type=' + _type + '&project_id=' + project_id;

      $.get(url, function (data) {
        element.addClass('disabled');
        currentTr = element.parents('tr');
        var newTr = $(data.html);
        currentTr.before(newTr);
        newTr.find( ".combobox" ).combobox();
        initDemoText(currentTr.prev('tr').find('*[data-hint]'));
        changeRowspan(element, 1);
      });
    });

    $('.js_cancel_add_funder').live('click', function (e) {
      e.preventDefault();
      var element = $(this);
      changeRowspan(element, -1);
      element.parents('tr').next('tr').find('.add_funder').removeClass('disabled');
      element.parents('tr').remove();
    });

    $('.js_save_funder').live('click', function (e) {
      e.preventDefault();
      var element = $(this);
      var form = element.parents('.new_funder_form');
      var ajaxLoader = element.parents('ol').find('.ajax-loader');

      ajaxLoader.show();

      $.post(buildJsonUrl(form.attr('action')), form.serialize(), function (data) {
        if (data.status) {
          var box = element.parents('tr');
          box.next('tr').find('.add_funder').removeClass('disabled');
          var newTr = $(data.html);
          box.replaceWith(newTr);
          $('#js_funders_form').find('.save_btn').show();
          $('.chosen').chosen();
        } else {
          var newTr = $(data.html);
          var box = element.parents('tr');
          box.replaceWith(newTr);
        }
      });
    });

    $('.js_spend_column_amount').live('keyup', function (e) {
      var element = $(this);
      updateSpendColumnValues(element);
    });

    $('.js_budget_column_amount').live('keyup', function (e) {
      var element = $(this);
      updateBudgetColumnValues(element);
    });

    $(".js_remove_purpose").live('click', function (e) {
      e.preventDefault();
      var destroy_link = $(this)
      var tr = destroy_link.parents('tr:first');
      var id = tr.attr('funding_flow_id');
      var loader = destroy_link.next('.ajax-loader');

      if (confirm('Are you sure?')) {
        if (id) {
          loader.show();
          $.post('/responses/' + _response_id + '/funders/' + id, {'_method': 'delete'}, function (data) {
            if (data.status) {
              tr.empty();
            }
          })
        } else {
          tr.remove();
        }
      }
    });

  }
}

var implementers_index = {
  run: function () {

    $('#sub_activity_implementer_type').live('change', function (e) {
      var selected_type = $(this).val();
      var implementer_dropdown = $(this).parents('ol:first').find("#sub_activity_provider_input");

      var build_select_options = function () {
        var select_options = [];
        var select_options_html = "";

        for (prop in _organizations) {
          if (!_organizations.hasOwnProperty(prop)) {
            //The current property is not a direct property of _organizations
            continue;
          }
          if (prop !== 'Government' && prop !== 'Self') {
            var orgs = _organizations[prop];
            for (var i = 0; i < orgs.length; i++) {
              select_options.push(orgs[i].organization);
            }
          }
        }
       
        for (var i = 0; i < select_options.length; i++) {
          select_options_html += '<option value="'+ select_options[i].id +'">' +
                                  select_options[i].name +
                                 '</option>';
        }

        return select_options_html;
      } 
      
      if (selected_type == 'Self') {
        implementer_dropdown.hide();
        implementer_dropdown.find('select').combobox('destroy');
        implementer_dropdown.find('select').val(_organizations.Self[0].organization.id);
      } else if (selected_type == 'Implementing Partner') {
        implementer_dropdown.find('select').html(build_select_options());
        implementer_dropdown.find('select').combobox();
        implementer_dropdown.show();
      } else if (selected_type == 'Government') {
        implementer_dropdown.hide();
        implementer_dropdown.find('select').combobox('destroy');
        implementer_dropdown.find('select').val(_organizations.Government[0].organization.id);
      }
    });

    $('.add_implementer').live('click', function (e) {
      e.preventDefault();
      var element = $(this);

      if (element.hasClass('disabled')) {
        return;
      }

      element.addClass('disabled');

      var activity_id = element.parents('tr').attr('data-activity_id');
      var url = '/responses/' + _response_id + '/implementers/new.json?type=' + _type + '&activity_id=' + activity_id;

      $.get(url, function (data) {
        element.addClass('disabled');
        currentTr = element.parents('tr');
        var newTr = $(data.html);
        currentTr.before(newTr);
        //newTr.find( ".combobox" ).combobox();
        initDemoText(currentTr.prev('tr').find('*[data-hint]'));
        changeRowspan(element, 1);
      });
    });

    $('.js_cancel_add_implementer').live('click', function (e) {
      e.preventDefault();
      var element = $(this);
      changeRowspan(element, -1);
      element.parents('tr').next('tr').find('.add_implementer').removeClass('disabled');
      element.parents('tr').remove();
    });

    $('.js_save_implementer').live('click', function (e) {
      e.preventDefault();
      var element = $(this);
      var form = element.parents('.new_implementer_form');
      var ajaxLoader = element.parents('ol').find('.ajax-loader');

      ajaxLoader.show();

      $.post(buildJsonUrl(form.attr('action')), form.serialize(), function (data) {
        if (data.status) {
          var box = element.parents('tr')
          box.next('tr').find('.add_implementer').removeClass('disabled');
          var newTr = $(data.html)
          box.replaceWith(newTr)
          $('#js_implementers_form').find('.save_btn').show();
        } else {
          var newTr = $(data.html);
          var box = element.parents('tr');
          box.replaceWith(newTr);
        }
      });
    });

    $('.js_spend_column_amount').live('keyup', function (e) {
      var element = $(this);
      updateSpendColumnValues(element);
    });

    $('.js_budget_column_amount').live('keyup', function (e) {
      var element = $(this);
      updateBudgetColumnValues(element);
    });

    $(".js_remove_purpose").live('click', function (e) {
      e.preventDefault();
      var destroy_link = $(this)
      var tr = destroy_link.parents('tr:first');
      var id = tr.attr('data-implementer_id');
      var loader = destroy_link.next('.ajax-loader');
      if (confirm('Are you sure?')) {
        if (id) {
          loader.show();
          $.post('/responses/' + _response_id + '/implementers/' + id, {'_method': 'delete'}, function (data) {
            if (data.status) {
              tr.empty();
            }
          })
        } else {
          tr.remove();
        }
      }
    });
  }
}

$(function () {

  // tipsy tooltips everywhere!
  $('.tooltip').tipsy({gravity: $.fn.tipsy.autoWE, live: true, html: true});
  
  // chosen everywhere!
  $('.chosen').chosen();

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

