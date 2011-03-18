// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery.noConflict()

function remove_fields(link) {
  jQuery(link).prev("input[type=hidden]").val("1");
  jQuery(link).closest(".fields").hide();
  //jQuery(link).parent().next().hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  jQuery(link).parent().before(content.replace(regexp, new_id));
}


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
  jQuery('#' + rowId).html('<td colspan="100">' + data + '</td>').addClass("edit_row");
};

var updateCount = function (resources) {
  var count = resources.find('tbody tr').length;
  resources.find('.count').html(count);
}

var addNewRow = function (resources, data) {
  resources.find('tbody').prepend(data);
  enableElement(resources.find('.new_btn'));
  updateCount(resources);
  var newRow = jQuery(resources.find('tbody tr')[0]);
  newRow.find(".rest_in_place").rest_in_place(); // inplace edit
};

var addExistingRow = function (rowId, data) {
  var row = jQuery('#' + rowId);
  row.replaceWith(data)
  var newRow = jQuery('#' + rowId);
  newRow.find(".rest_in_place").rest_in_place(); // inplace edit
};

var addSearchForm = function (element) {
  if (element.hasClass('enabled')) {
    disableElement(element);
    var resourceName = getResourceName(element);
    jQuery.get(resourceName + '/search.js', function (data) {
      jQuery('#placer').prepend(data);
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

var getResources = function (element) {
  return element.parents('.resources');
}

var newResource = function (element) {
  if (element.hasClass('enabled')) {
    var resources = getResources(element);
    disableElement(element);
    jQuery.get(buildUrl(element.attr('href')), function (data) {
      addNewForm(resources, data);
    });
  }
};

var replaceTable = function (data) {
  jQuery("#main_table").replaceWith(data);
  jQuery("#main_table").find(".rest_in_place").rest_in_place(); // inplace edit
};

var searchResources = function (element, type) {
  var resourceName = getResourceName(element);
  var form = getForm(element);
  var q = (type === "reset") ? '' : form.find("#s_q").val();

  jQuery.get(resourceName + '.js?q=' + q, function (data) {
    replaceTable(data);
    if (type === "reset") {
     closeForm(element);
     enableElement(jQuery(".search_btn"));
    }
  });
};

var editResource = function (element) {
  var rowId = getRowId(element);
  jQuery.get(buildUrl(element.attr('href')), function (data) {
    addEditForm(rowId, data);
  });
};

var updateResource = function (element) {
  var rowId = getRowId(element);
  var form = getForm(element);
  jQuery.post(buildUrl(form.attr('action')), form.serialize(), function (data, status, response) {
    closeForm(element);
    response.status === 206 ? addEditForm(rowId, data) : addExistingRow(rowId, data);
  });
};

var createResource = function (element) {
  var form = getForm(element);
  var resources = getResources(element);
  jQuery.post(buildUrl(form.attr('action')), form.serialize(), function (data, status, response) {
    closeForm(element);
    response.status === 206 ? addNewForm(resources, data) : addNewRow(resources, data);
  });
};

var showResource = function (element) {
  var rowId = getRowId(element);
  var resourceId = getResourceId(element)
  jQuery.get(element.attr('href') + '/' + resourceId + '.js', function (data) {
    closeForm(element);
    addExistingRow(rowId, data);
  });
};

var destroyResource = function (element) {
  var rowId = getRowId(element);
  var resources = getResources(element);
  jQuery.post(element.attr('href').replace('/delete', '') + '.js', {'_method': 'delete'}, function (data) {
    removeRow(resources, rowId);
  });
};

var sortResources = function (element) {
  var link = element.find('a');
  var resourceName = getResourceName(element);
  var url = resourceName + '.js?' + link.attr('href').replace(/.*\?/, '');
  jQuery.get(url, function (data) {
    replaceTable(data);
  });
}

var getFormType = function (element) {
  // new_form => new; edit_form => edit
  return element.parents('.form_box').attr('class').replace(/form_box /, '').split('_')[0];
}

var ajaxifyResources = function (resources) {
  var block = jQuery(".resources[data-resources='" + resources + "']");
  var newBtn = block.find(".new_btn");
  var editBtn = block.find(".edit_btn");
  var cancelBtn = block.find(".cancel_btn");
  var searchBtn = block.find(".search_btn");
  var submitBtn = block.find(".submit_btn");
  var destroyBtn = block.find(".destroy_btn");

  // new
  newBtn.live('click', function (e) {
    e.preventDefault();
    var element = jQuery(this);
    newResource(element);
  });

  // edit
  editBtn.live('click', function (e) {
    e.preventDefault();
    var element = jQuery(this);
    editResource(element);
  });

  // cancel
  cancelBtn.live('click', function (e) {
    e.preventDefault();
    var element = jQuery(this);
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
    var element = jQuery(this);
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
    var element = jQuery(this);
    if (confirm('Are you sure?')) {
      destroyResource(element);
    }
  });
};


/* Ajax CRUD END */

var collapse_expand = function (e, element, type) {
  // if target element is link, skip collapsing
  if (e.target.nodeName === 'A') {
    return;
  }

  var next_element = element.next('.' + type + '.entry_main');
  var next_element_visible = next_element.is(':visible');
  jQuery('.' + type + '.entry_main').hide();
  jQuery('.' + type + '.entry_header').removeClass('active');
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
    jQuery(".destroy_btn").live('click', function (e) {
      e.preventDefault();
      var element = jQuery(this);
      if (confirm('Are you sure?')) {
        destroyResource(element);
      }
    });
  }
};

var admin_responses_empty = {
  run: function () {
    // destroy
    jQuery(".destroy_btn").live('click', function (e) {
      e.preventDefault();
      var element = jQuery(this);
      if (confirm('Are you sure?')) {
        destroyResource(element);
      }
    });
  }
};

var getOrganizationInfo = function (organization_id, box) {
  jQuery.get(organization_id + '.js', function (data) {
    box.find('.placer').html(data);
  });
};

var displayFlashForReplaceOrganization = function (type, message) {
  jQuery('#content .wrapper').prepend(
    jQuery('<div/>').attr({id: 'flashes'}).append(
      jQuery('<div/>').attr({id: type}).text(message)
    )
  );

  // fade out flash message
  jQuery("#" + type).delay(5000).fadeOut(3000, function () {
    jQuery("#flashes").remove();
  });
}

var removeOrganizationFromLists = function (duplicate_id, box_type) {
  jQuery.each(['duplicate', 'target'], function (i, name) {
    var select_element = jQuery("#" + name + "_organization_id");
    var current_option = select_element.find("option[value='" + duplicate_id + "']");

    // remove element from page
    if (name === box_type) {
      var next_option = current_option.next().val();
      if (next_option) {
        select_element.val(next_option);
      }

      // update info block
      getOrganizationInfo(select_element.val(), jQuery('#' + name));
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
  var duplicate_id = jQuery("#duplicate_organization_id").val();
  jQuery.post(buildUrl(form.attr('action')), form.serialize(), function (data, status, response) {
    var data = jQuery.parseJSON(data)
    response.status === 206 ? ReplaceOrganizationErrorCallback(data.message) : ReplaceOrganizationSuccessCallback(data.message, duplicate_id);
  });
};

var destroyOrganization = function (organization_id, type) {
  jQuery.post('/admin/organizations/' + organization_id + '.js', {'_method': 'delete'}, function (data, status, response) {
    var data = jQuery.parseJSON(data)
    response.status === 206 ? displayFlashForReplaceOrganization('error', data.message) : removeOrganizationFromLists(organization_id, type);
  });
}

var admin_organizations_duplicate = {
  run: function () {
    jQuery("#duplicate_organization_id, #target_organization_id").change(function() {
      var organization_id = jQuery(this).val();
      var type = jQuery(this).parents('.box').attr('data-type');
      var box = jQuery('#' + type); // type = duplicate; target
      getOrganizationInfo(organization_id, box);
    });

    getOrganizationInfo(jQuery("#duplicate_organization_id").val(), jQuery('#duplicate'));
    getOrganizationInfo(jQuery("#target_organization_id").val(), jQuery('#target'));

    jQuery("#replace_organization").click(function (e) {
      e.preventDefault();
      var element = jQuery(this);
      var form = element.parents('form')
      if (confirm('Are you sure?')) {
        replaceOrganization(form);
      }
    });

    jQuery(".destroy_btn").click(function (e) {
      e.preventDefault();
      var element = jQuery(this);
      var type = element.parents('.box').attr('data-type');
      var select_element;

      select_element = (type === 'duplicate') ? jQuery("#duplicate_organization_id") : jQuery("#target_organization_id");

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
  jQuery.getJSON(urlEndpoint, function (response) {
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

  jQuery('.tooltip').tipsy({gravity: 'w'});
  jQuery('.comments_tooltip').tipsy({fade: true, gravity: 'w', html: true});
  jQuery('.treemap_tooltip').tipsy({fade: true, gravity: 'sw', html: true, live: true});

  jQuery('.project.entry_header').click(function (e) {
    collapse_expand(e, jQuery(this), 'project');
  });

  jQuery('.activity.entry_header').click(function (e) {
    collapse_expand(e, jQuery(this), 'activity');
  });

  jQuery('.sub_activity.entry_header').click(function (e) {
    collapse_expand(e, jQuery(this), 'sub_activity');
  });

  // bind click events for tabs
  jQuery(".classifications ul li").live('click', function (e) {
    e.preventDefault();
    var element = jQuery(this);
    if (element.attr("id")) {
      jQuery(".classifications ul li").removeClass('selected');
      element.addClass('selected');
      jQuery("#activity_classification > div").hide();
      jQuery('#activity_classification > div.' + element.attr("id")).show();
    }
  });

  // bind click events for tabs
  // Assumes this convention
  //  .tabs_nav
  //    ul > li, li, li
  // tab content
  //  .tabs > .tab1, .tab2, .tab3
  // BUT if you supply an id (e.g. tab1), it will use that
  // (useful if tab nav has non-clickable items in the list)
  jQuery(".tabs_nav ul li").live('click', function (e) {
    e.preventDefault();
    var element = jQuery(this);
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
  jQuery(".tabs ul.inline_tab li").live('click', function (e) {
    e.preventDefault();
    var element = jQuery(this);
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
  createPieChart("data_response", {id: _dr_id, title: "Cost Category Budget", chart_type: 'cc_budget', codings_type: 'CodingBudgetCostCategorization', code_type: 'CostCategory'});
  createPieChart("data_response", {id: _dr_id, title: "Cost Category Expenditure", chart_type: 'cc_spend', codings_type: 'CodingSpendCostCategorization', code_type: 'CostCategory'});
  //createPieChart("data_response", {id: _dr_id, title: "Cost Category Expenditure", chart_type: 'cc_spend', codings_type: 'CodingSpend', code_type: 'CostCategory'});
  //createPieChart("data_response", {id: _dr_id, title: "HSSPII Strat Program Budget", chart_type: 'stratprog_budget', codings_type: 'HsspBudget', code_type: 'HsspStratProg'});
  //createPieChart("data_response", {id: _dr_id, title: "HSSPII Strat Objective Budget", chart_type: 'stratobj_budget', codings_type: 'HsspBudget', code_type: 'HsspStratObj'});
  //createPieChart("data_response", {id: _dr_id, title: "HSSPII Strategic Program Expenditure", chart_type: 'stratprog_spend', codings_type: 'HsspSpend', code_type: 'HsspStratProg'});
  //createPieChart("data_response", {id: _dr_id, title: "HSSPII Strategic Objective Expenditure", chart_type: 'stratobj_spend', codings_type: 'HsspSpend', code_type: 'HsspStratObj'});

  // Project charts
  jQuery.each(_projects, function (i, id) {
    createPieChart("project", {id: id, title: "MTEF Budget", chart_type: 'mtef_budget', codings_type: 'CodingBudget', code_type: 'Mtef'});
    createPieChart("project", {id: id, title: "MTEF Expenditure", chart_type: 'mtef_spend', codings_type: 'CodingSpend', code_type: 'Mtef'});
    createPieChart("project", {id: id, title: "NSP Budget", chart_type: 'nsp_budget', codings_type: 'CodingBudget', code_type: 'Nsp'});
    createPieChart("project", {id: id, title: "NSP Expenditure", chart_type: 'nsp_spend', codings_type: 'CodingSpend', code_type: 'Nsp'});
  createPieChart("project", {id: id, title: "Cost Category Budget", chart_type: 'cc_budget', codings_type: 'CodingBudgetCostCategorization', code_type: 'CostCategory'});
  createPieChart("project", {id: id, title: "Cost Category Expenditure", chart_type: 'cc_spend', codings_type: 'CodingSpendCostCategorization', code_type: 'CostCategory'});
    //createPieChart("project", {id: id, title: "HSSPII Strat Program Budget", chart_type: 'stratprog_budget', codings_type: 'HsspBudget', code_type: 'HsspStratProg'});
    //createPieChart("project", {id: id, title: "HSSPII Strat Objective Budget", chart_type: 'stratobj_budget', codings_type: 'HsspBudget', code_type: 'HsspStratObj'});
    //createPieChart("project", {id: id, title: "HSSPII Strategic Program Expenditure", chart_type: 'stratprog_spend', codings_type: 'HsspSpend', code_type: 'HsspStratProg'});
    //createPieChart("project", {id: id, title: "HSSPII Strategic Objective Expenditure", chart_type: 'stratobj_spend', codings_type: 'HsspSpend', code_type: 'HsspStratObj'});
  });

  approve_activity_checkbox();

  // Ajax load of classifications for activities
  jQuery.each(jQuery('.activity_classifications'), function (i, element) {
    element = jQuery(element);
    var activity_id = element.attr('data-activity_id');
    var response_id = element.attr('data-response_id');
    var other_cost = element.attr('data-other_costs');
    var url =  '/responses/' + response_id + '/activities/' + 
      activity_id + '/classifications?other_costs=' + other_cost;
    jQuery.get(url, function (data) {element.html(data)});
  });

};

var admin_responses_show = {
  run: function (){
    build_data_response_review_screen();
    ajaxifyResources('comments');
  }
};

var reporter_responses_show = {
  run: function () {
    build_data_response_review_screen();
    ajaxifyResources('comments');
  }
};

var policy_maker_data_responses_show = {
  run: function () {
    build_data_response_review_screen();
    ajaxifyResources('comments');
  }
};

var approve_activity_checkbox = function () {
  jQuery(".approve_activity").click(function (e) {
    e.preventDefault();
    e.stopPropagation();
    //activity_id = Number(jQuery(this).attr('id').match(/\d+/)[0], 10);
    activity_id = jQuery(this).attr('data-id');
    response_id = jQuery(this).attr('data-response_id');
    var url =  '/responses/' + response_id + '/activities/' + activity_id + '/approve'
    jQuery.post(url, {checked: jQuery(this).is(':checked'), "_method": "put"});
  })
};

var code_assignments_show = {
  run: function () {

    /*
     * Adds collapsible checkbox tree functionality for a tab and validates classification tree
     * @param {String} tab
     *
     */
    var addCollabsibleButtons = function (tab) {
      jQuery('.' + tab + ' ul.activity_tree').collapsibleCheckboxTree({tab: tab});
      jQuery('.' + tab + ' ul.activity_tree').validateClassificationTree();
    };

    /*
     * Appends tab content
     * @param {String} tab
     * @param {String} response
     *
     */
    var appendTab = function (tab, response) {
      jQuery("#activity_classification ." + tab).html(response);
      addCollabsibleButtons(tab);
    };

    jQuery('.submit_btn').live('click', function (e) {
      e.preventDefault();

      var element = jQuery(this);
      var form = getForm(element);
      var tab = jQuery("#activity_classification > div:visible");

      // add ajax loader image
      element.after(jQuery('<img/>').attr({id: 'ajax-loader', src: '/images/ajax-loader.gif'}));

      jQuery.post(buildUrl(form.attr('action')) + '&tab=' + tab.attr('class'), form.serialize(), function (data, status, response) {

        // replace tab form
        tab.html('');
        appendTab(tab.attr('class'), data.tab);

        // replace nav
        jQuery(".inline_tab").replaceWith(data.tab_nav);
        jQuery('#' + tab.attr('class')).click(); // click the current tab

        // replace activity description
        jQuery("#activity_description").replaceWith(data.activity_description);

        // flash messages
        jQuery('#flashes').remove();
        var flashes = jQuery('<div/>').attr({id: 'flashes'});
        jQuery('#content .wrapper').prepend(flashes);
        flashes.delay(5000).fadeOut(3000, function () {
          jQuery(this).remove();
        });

        // bottom flash message in tab
        var coding_flash_below = jQuery('<div/>').attr({'class': 'coding_flash'});

        if (data.message.notice) {
          flashes.append(jQuery('<div/>').attr({id: 'notice'}).text(data.message.notice));
          coding_flash_below.append(jQuery('<div/>').attr({'class': 'notice'}).text(data.message.notice));
        }

        if (data.message.error) {
          flashes.append(jQuery('<div/>').attr({id: 'error'}).text(data.message.error));
          coding_flash_below.append(jQuery('<div/>').attr({'class': 'error'}).text(data.message.error));
        }

        tab.append(coding_flash_below);
        coding_flash_below.delay(5000).fadeOut(3000, function (element) {
          jQuery(this).remove();
        });
      });
    });

    // collapsible checkboxes for tab1
    //addCollabsibleButtons('tab1');

    var tab_codings = [['tab1', 'CodingBudget'], ['tab2', 'CodingBudgetDistrict'],
     ['tab3', 'CodingBudgetCostCategorization'], ['tab4', 'CodingSpend'],
     ['tab5', 'CodingSpendDistrict'], ['tab6', 'CodingSpendCostCategorization']]

    for(var i = 0; i < tab_codings.length; i++) {
      var tab         = tab_codings[i][0];
      var coding_type = tab_codings[i][1];
      var url = '/activities/' + _activity_id + 
        '/code_assignments?coding_type=' + coding_type + '&tab=' + tab;

      var element = jQuery("#activity_classification ." + tab);

      if (element.length) {
        // closure to 'catch' the actual tab
        (function (url, tab) {
          jQuery.get(url, function (response) {
            appendTab(tab, response);
          });
        })(url, tab);
      }
    }

    // bind click events for tabs
    jQuery(".nav2 ul li").live('click', function (e) {
      e.preventDefault();
      var element = jQuery(this);
      if (element.attr("id")) {
        jQuery(".nav2 ul li").removeClass('selected');
        element.addClass('selected');
        jQuery("#activity_classification > div").hide();
        jQuery('#activity_classification > div.' + element.attr("id")).show();
      }
    });
    approve_activity_checkbox();
  }
};

var update_use_budget_codings_for_spend = function (e, activity_id, checked) {
  if (!checked || checked && confirm('All your expenditure codings will be deleted and replaced with copies of your budget codings, adjusted for the difference between your budget and spend. Your expenditure codings will also automatically update if you change your budget codings. Are you sure?')) {
    jQuery.post( "/activities/" + activity_id + "/use_budget_codings_for_spend", { checked: checked, "_method": "put" });
  } else {
    e.preventDefault();
  }
};

var data_responses_review = {
  run: function () {
    jQuery(".use_budget_codings_for_spend").click(function (e) {
      var checked = jQuery(this).is(':checked');
      activity_id = Number(jQuery(this).attr('id').match(/\d+/)[0], 10);
      update_use_budget_codings_for_spend(e, activity_id, checked);
    })
  }
}

function drawPieChart(id, data_rows) {
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
  chart.draw(data, {width: 450, height: 300, chartArea: {width: 360, height: 220}});
};

var drawTreemapChart = function (id, data_rows, treemap_gravity) {
  if (typeof(data_rows) === "undefined") {
    return;
  }

  var chart_element = jQuery("#" + id);
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

var reports_districts_show = {
  run: function () {
    if (_treemap) {
      drawTreemapChart('code_spent', _code_spent_values, 'w');
      drawTreemapChart('code_budget', _code_budget_values, 'e');
    } else {
      drawPieChart('code_spent', _code_spent_values);
      drawPieChart('code_budget', _code_budget_values);
    }
  }
};

var reports_districts_activities_show = {
  run: function () {
    drawPieChart('spent_pie', _spent_pie_values);
    drawPieChart('budget_pie', _budget_pie_values);
    if (_treemap) {
      drawTreemapChart('code_spent', _code_spent_values, 'w');
      drawTreemapChart('code_budget', _code_budget_values, 'e');
    } else {
      drawPieChart('code_spent', _code_spent_values);
      drawPieChart('code_budget', _code_budget_values);
    }
  }
};

var reports_districts_activities_index = {
  run: function () {
    drawPieChart('spent_pie', _spent_pie_values);
    drawPieChart('budget_pie', _budget_pie_values);
  }
};

var reports_districts_organizations_index = {
  run: function () {
    drawPieChart('spent_pie', _spent_pie_values);
    drawPieChart('budget_pie', _budget_pie_values);
  }
};

var reports_districts_organizations_show = {
  run: function () {
    if (_treemap) {
      drawTreemapChart('code_spent', _code_spent_values, 'w');
      drawTreemapChart('code_budget', _code_budget_values, 'e');
    } else {
      drawPieChart('code_spent', _code_spent_values);
      drawPieChart('code_budget', _code_budget_values);
    }
  }
};

var reports_countries_show = {
  run: function () {
    if (_treemap) {
      drawTreemapChart('code_spent', _code_spent_values, 'w');
      drawTreemapChart('code_budget', _code_budget_values, 'e');
    } else {
      drawPieChart('code_spent', _code_spent_values);
      drawPieChart('code_budget', _code_budget_values);
    }
  }
}

var reports_countries_organizations_index = {
  run: function () {
    drawPieChart('spent_pie', _spent_pie_values);
    drawPieChart('budget_pie', _budget_pie_values);
  }
};

var reports_countries_organizations_show = {
  run: function () {
    if (_treemap) {
      drawTreemapChart('code_spent', _code_spent_values, 'w');
      drawTreemapChart('code_budget', _code_budget_values, 'e');
    } else {
      drawPieChart('code_spent', _code_spent_values);
      drawPieChart('code_budget', _code_budget_values);
    }
  }
};

var reports_countries_activities_index = {
  run: function () {
    drawPieChart('spent_pie', _spent_pie_values);
    drawPieChart('budget_pie', _budget_pie_values);
  }
};

var reports_countries_activities_show = {
  run: function () {
    if (_treemap) {
      drawTreemapChart('code_spent', _code_spent_values, 'w');
      drawTreemapChart('code_budget', _code_budget_values, 'e');
    } else {
      drawPieChart('code_spent', _code_spent_values);
      drawPieChart('code_budget', _code_budget_values);
    }
  }
};

var activities_new = activities_create = activities_edit = activities_update = {
  run: function () {
    jQuery('#activity_project_id').change(function () {
      var element = jQuery('#project_sub_form');
      var _project_id = jQuery(this).val();
      if (_project_id) {
        var url = '/responses/' + _response_id + 
        '/activities/project_sub_form?' + 'project_id=' + _project_id;
        if (_activity_id) {
          url += '&activity_id=' + _activity_id;
        }
        jQuery.get(url, function (data) {
          element.html(data);
          element.show();
        });
      } else {
        element.hide().html('');
      }
    });
  }
}


jQuery(function () {

  // tipsy tooltips everywhere!
  jQuery('.tooltip').tipsy({gravity: 'w'});

  var id = jQuery('body').attr("id");
  if (id) {
    controller_action = id;
    if (typeof(window[controller_action]) !== 'undefined' && typeof(window[controller_action]['run']) === 'function') {
      window[controller_action]['run']();
    }
  }

  jQuery("#closeFlash").click(function(){
    jQuery("#flashes").fadeOut("slow");
  });

  jQuery('#page_tips_open').click(function (e) {
    e.preventDefault();
    jQuery('#page_tips .desc').toggle();
    jQuery('#page_tips .nav').toggle();
  });

  jQuery('#page_tips_close').click(function (e) {
    e.preventDefault();
    jQuery('#page_tips .desc').toggle();
    jQuery('#page_tips .nav').toggle();
    jQuery("#page_tips_open_link").effect("highlight", {}, 1500);
  });

  // Date picker
  jQuery('.date_picker').live('click', function () {
    jQuery(this).datepicker('destroy').datepicker({
      changeMonth: true,
      changeYear: true,
      yearRange: '2000:2025',
      dateFormat: 'yy-mm-dd'
    }).focus();
  });

  // Inplace edit
  jQuery(".rest_in_place").rest_in_place();

  // clickable table rows
  jQuery('.clickable tbody tr').click(function (e) {
    e.preventDefault();
    var element = jQuery(e.target);

    if (element.attr('href')) {
      var href = element.attr('href');
    } else {
      var href = jQuery(this).find("a").attr("href");
    }

    if (href) {
      window.location = href;
    }
  });

});

