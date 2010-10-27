// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery.noConflict()

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

var admin_data_responses_index = {
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


var createPieChart = function (title, domId, urlEndpoint) {
  var so = new SWFObject("/ampie/ampie.swf", "ampie", "600", "300", "8", "#FFFFFF");
  so.addVariable("path", "/ampie/");
  so.addVariable("settings_file", encodeURIComponent("/ampie/ampie_settings.xml"));
  so.addVariable("data_file", encodeURIComponent(urlEndpoint));
  so.addVariable("additional_chart_settings", encodeURIComponent(
    '<settings>' +
      '<labels>' +
        '<label lid="0">' +
          '<text>' + title + '</title>' +
        '</label>' +
      '</labels>' +
    '</settings>')
  );
  so.write(domId);
};

var drawTreemap = function (type) {
  var chart_id  = _treemap_data[type].chart_id;
  var data_rows = _treemap_data[type].data_rows;

  // Create and populate the data table.
  var data = new google.visualization.DataTable();
  data.addColumn('string', 'Code');
  data.addColumn('string', 'Parent');
  data.addColumn('number', 'Market trade volume (size)');
  data.addColumn('number', 'Market increase/decrease (color)');
  data.addRows(data_rows)

  // Create and draw the visualization.
  var tree = new google.visualization.TreeMap(document.getElementById(chart_id));
  tree.draw(data, {
    minColor: '#99ccff',
    midColor: '#6699cc',
    maxColor: '#336699',
    headerHeight: 15,
    fontColor: 'black',
    showScale: false});
};

var build_data_response_review_screen = function () {

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
  jQuery(".classifications ul li").click(function (e) {
    e.preventDefault();
    var element = jQuery(this);
    if (element.attr("id")) {
      jQuery(".classifications ul li").removeClass('selected');
      element.addClass('selected');
      jQuery("#activity_classification > div").hide();
      jQuery('#activity_classification > div.' + element.attr("id")).show();
    }
  });


  // collapsiable project header
  jQuery("#details").click(function (e) {
    e.preventDefault();
    jQuery(".projects tbody").toggle();
  });

  // bind click events for project chart tabs
  jQuery(".tabs_nav ul li").click(function (e) {
    e.preventDefault();
    var element = jQuery(this);
    if (element.attr("id")) {
      jQuery(".tabs_nav ul li").removeClass('selected');
      element.addClass('selected');
      var tabs = element.parents(".tabs_nav").next(".tabs")
      tabs.find("> div").hide();
      tabs.find('> div.' + element.attr("id")).show();
    }
  });

  // bind click events for project chart sub-tabs (Pie | Tree)
  jQuery(".tabs ul.compact_tab li").click(function (e) {
    e.preventDefault();
    var element = jQuery(this);
    if (element) {
      element.parents('.compact_tab').find('li').removeClass('selected');
      element.addClass('selected');

      // toggle tabs
      if (element.attr("class").match(/_tree/)) {
        // find the tabX parent, toggle it
        element.parent('ul').parent().find(".pie").hide()
        element.parent('ul').parent().find(".tree").show()
      } else {
          element.parent('ul').parent().find(".tree").hide()
          element.parent('ul').parent().find(".pie").show()
      }
      // draw tree map if not already drawn
      if (element.attr("class").match(/mtef_budget_tree/)) {
        // find the tabX parent, toggle it
        if (element.parent('ul').parent().find(".tree iframe").length == 0) {
          drawTreemap('mtef_budget');
        }
      } else if (element.attr("class").match(/mtef_spend_tree/)) {
        if (element.parent('ul').parent().find(".tree iframe").length == 0) {
          drawTreemap('mtef_spend');
        }
      } else if (element.attr("class").match(/nsp_budget_tree/)) {
        if (element.parent('ul').parent().find(".tree iframe").length == 0) {
          drawTreemap('nsp_budget');
        }
      } else if (element.attr("class").match(/nsp_spend_tree/)) {
        if (element.parent('ul').parent().find(".tree iframe").length == 0) {
          drawTreemap('nsp_spend');
        }
      }
    }
   });


  // Data Response charts
  createPieChart("MTEF Budget", "dr_" + _dr_id + "_mtef_budget", "/charts/data_response_pie?codings_type=CodingBudget&code_type=Mtef&data_response_id=" + _dr_id);
  createPieChart("MTEF Expenditure", "dr_" + _dr_id + "_mtef_spend", "/charts/data_response_pie?codings_type=CodingSpend&code_type=Mtef&data_response_id=" + _dr_id);
  createPieChart("NSP Budget", "dr_" + _dr_id + "_nsp_budget", "/charts/data_response_pie?codings_type=CodingBudget&code_type=Nsp&data_response_id=" + _dr_id);
  createPieChart("NSP Expenditure", "dr_" + _dr_id + "_nsp_spend", "/charts/data_response_pie?codings_type=CodingSpend&code_type=Nsp&data_response_id=" + _dr_id);
  createPieChart("HSSPII Strat Program Budget", "dr_" + _dr_id + "_budget_stratprog_coding", "/charts/data_response_pie?codings_type=HsspBudget&code_type=HsspStratProg&data_response_id=" + _dr_id);
  createPieChart("HSSPII Strat Objective Budget", "dr_" + _dr_id + "_budget_stratobj_coding", "/charts/data_response_pie?codings_type=HsspBudget&code_type=HsspStratObj&data_response_id=" + _dr_id);
  createPieChart("HSSPII Strategic Program Expenditure", "dr_" + _dr_id + "_spend_stratprog_coding", "/charts/data_response_pie?codings_type=HsspSpend&code_type=HsspStratProg&data_response_id=" + _dr_id);
  createPieChart("HSSPII Strategic Objective Expenditure", "dr_" + _dr_id + "_spend_stratobj_coding", "/charts/data_response_pie?codings_type=HsspSpend&code_type=HsspStratObj&data_response_id=" + _dr_id);

  // Project charts
  jQuery.each(_projects, function (i, projectId) {
    createPieChart("MTEF Budget", "project_" + projectId + "_mtef_budget", "/charts/project_pie?codings_type=CodingBudget&code_type=Mtef&project_id=" + projectId);
    createPieChart("MTEF Expenditure", "project_" + projectId + "_mtef_spend", "/charts/project_pie?codings_type=CodingSpend&code_type=Mtef&project_id=" + projectId);
    createPieChart("NSP Budget", "project_" + projectId + "_nsp_budget", "/charts/project_pie?codings_type=CodingBudget&code_type=Nsp&project_id=" + projectId);
    createPieChart("NSP Expenditure", "project_" + projectId + "_nsp_spend", "/charts/project_pie?codings_type=CodingSpend&code_type=Nsp&project_id=" + projectId);
    createPieChart("HSSPII Strat Program Budget", "project_" + projectId + "_budget_stratprog_coding", "/charts/project_pie?codings_type=HsspBudget&code_type=HsspStratProg&project_id=" + projectId);
    createPieChart("HSSPII Strat Objective Budget", "project_" + projectId + "_budget_stratobj_coding", "/charts/project_pie?codings_type=HsspBudget&code_type=HsspStratObj&project_id=" + projectId);
    createPieChart("HSSPII Strategic Program Expenditure", "project_" + projectId + "_spend_stratprog_coding", "/charts/project_pie?codings_type=HsspSpend&code_type=HsspStratProg&project_id=" + projectId);
    createPieChart("HSSPII Strategic Objective Expenditure", "project_" + projectId + "_spend_stratobj_coding", "/charts/project_pie?codings_type=HsspSpend&code_type=HsspStratObj&project_id=" + projectId);
  });

};

var admin_data_responses_show = {
  run: function (){
    build_data_response_review_screen();
    ajaxifyResources('comments');
  }
};

var reporter_data_responses_show = {
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

    // collapsible checkboxes for tab1
    jQuery('.tooltip').tipsy({gravity: 'e'});
    addCollabsibleButtons('tab1');

    // load budget districts
    jQuery.get('/activities/' + _activity_id + '/coding?coding_type=CodingBudgetDistrict&tab=tab2', function (response) {
      appendTab('tab2', response);
    });

    // load budget cost categorization
    jQuery.get('/activities/' + _activity_id + '/coding?coding_type=CodingBudgetCostCategorization&tab=tab3', function (response) {
      appendTab('tab3', response);
    });

    // load expenditure
    jQuery.get('/activities/' + _activity_id + '/coding?coding_type=CodingSpend&tab=tab4', function (response) {
      appendTab('tab4', response);
    });

    // load expenditure districts
    jQuery.get('/activities/' + _activity_id + '/coding?coding_type=CodingSpendDistrict&tab=tab5', function (response) {
      appendTab('tab5', response);
    });
    // load expenditure cost categories
    jQuery.get('/activities/' + _activity_id + '/coding?coding_type=CodingSpendCostCategorization&tab=tab6', function (response) {
      appendTab('tab6', response);
    });

    // bind click events for tabs
    jQuery(".nav2 ul li").click(function (e) {
      e.preventDefault();
      var element = jQuery(this);
      if (element.attr("id")) {
        jQuery(".nav2 ul li").removeClass('selected');
        element.addClass('selected');
        jQuery("#activity_classification > div").hide();
        jQuery('#activity_classification > div.' + element.attr("id")).show();
      }
    });

    // remove flash notice
    // jQuery("#notice").fadeOut(3000);

    jQuery("#use_budget_codings_for_spend").click(function () {
      jQuery.post( "/activities/" + _activity_id + "/use_budget_codings_for_spend",
       { checked: jQuery(this).is(':checked'), "_method": "put" }
      );
    })

    jQuery("#approve_activity").click(function () {
      jQuery.post( "/activities/" + _activity_id + "/approve",
       { checked: jQuery(this).is(':checked'), "_method": "put" }
      );
    })
  }
};

var data_responses_review = {
  run: function () {
    jQuery(".use_budget_codings_for_spend").click(function () {
      activity_id = Number(jQuery(this).attr('id').match(/\d+/)[0], 10);
      jQuery.post( "/activities/" + activity_id + "/use_budget_codings_for_spend",
       { checked: jQuery(this).is(':checked'), "_method": "put" }
      );
    })
  }
}

jQuery(function () {
  var id = jQuery('body').attr("id");
  if (id) {
    controller_action = id;
    if (typeof(window[controller_action]) !== 'undefined' && typeof(window[controller_action]['run']) === 'function') {
      window[controller_action]['run']();
    }
  }

  jQuery('#page_tips_open_link').click(function (e) {
    e.preventDefault();
    jQuery('#desc').toggle();
    jQuery('#page_tips_nav').toggle();
  });

  jQuery('#page_tips_close_link').click(function (e) {
    e.preventDefault();
    jQuery('#desc').toggle();
    jQuery('#page_tips_nav').toggle();
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


})
