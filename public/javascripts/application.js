// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery.noConflict()

/* Ajax CRUD BEGIN */

var get_row_id = function (element) {
  return element.parents('tr').attr('id');
};

var get_resource_id = function (element) {
  return Number(get_row_id(element).match(/\d+/)[0]);
};

var get_resource_name = function (element) {
  return element.parents('.resources').attr("data-resource");
};

var get_form = function (element) {
  return element.parents('form');
};

var add_new_form = function (element, data) {
  element.parents('.resources').find('.placer').prepend(data)
};

var add_edit_form = function (row_id, data) {
  jQuery('#' + row_id).html('<td colspan="100">' + data + '</td>').addClass("edit_row");
};

var add_new_row = function (resources, data) {
  resources.find('tbody').prepend(data);
  enable_element(resources.find('.new_btn'));
};

var add_existing_row = function (row_id, data) {
  var row = jQuery('#' + row_id);
  row.replaceWith(data)
  var new_row = jQuery('#' + row_id);
  new_row.find(".rest_in_place").rest_in_place(); // inplace edit
};

var add_form = function (data, row_id) {
  if (row_id) {
  } else {
  }
};

var add_search_form = function (element) {
  if (element.hasClass('enabled')) {
    disable_element(element);
    var resource_name = get_resource_name(element);
    jQuery.get(resource_name + '/search.js', function (data) {
      jQuery('#placer').prepend(data);
    });
  }
}

var close_form = function (element) {
  element.parents('.form_box').remove();
};

var remove_row = function (row_id) {
  jQuery("#" + row_id).remove();
};

var disable_element = function (element) {
  element.removeClass('enabled').addClass('disabled');
};

var enable_element = function (element) {
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

var new_resource = function (element) {
  if (element.hasClass('enabled')) {
    disable_element(element);
    jQuery.get(buildUrl(element.attr('href')), function (data) {
      add_new_form(element, data);
    });
  }
};

var replaceTable = function (data) {
  jQuery("#main_table").replaceWith(data);
  jQuery("#main_table").find(".rest_in_place").rest_in_place(); // inplace edit
};

var search_resources = function (element, type) {
  var resource_name = get_resource_name(element);
  var form = get_form(element);
  var q = (type === "reset") ? '' : form.find("#s_q").val();

  jQuery.get(resource_name + '.js?q=' + q, function (data) {
    replaceTable(data);
    if (type === "reset") {
     close_form(element);
     enable_element(jQuery(".search_btn"));
    }
  });
};

var edit_resource = function (element) {
  var row_id = get_row_id(element);
  jQuery.get(buildUrl(element.attr('href')), function (data) {
    add_edit_form(row_id, data);
  });
};

var update_resource = function (element) {
  var row_id = get_row_id(element);
  var form = get_form(element);
  jQuery.post(buildUrl(form.attr('action')), form.serialize(), function (data, status, response) {
    close_form(element);
    response.status === 206 ? add_edit_form(row_id, data) : add_existing_row(row_id, data);
  });
};

var create_resource = function (element) {
  var form = get_form(element);
  var resources = element.parents('.resources');
  jQuery.post(buildUrl(form.attr('action')), form.serialize(), function (data, status, response) {
    close_form(element);
    response.status === 206 ? add_new_form(element, data) : add_new_row(resources, data);
  });
};

var show_resource = function (element) {
  var row_id = get_row_id(element);
  var resource_id = get_resource_id(element)
  jQuery.get(element.attr('href') + '/' + resource_id + '.js', function (data) {
    close_form(element);
    add_existing_row(row_id, data);
  });
};

var destroy_resource = function (element) {
  var row_id = get_row_id(element);
  jQuery.post(element.attr('href').replace('/delete', '') + '.js', {'_method': 'delete'}, function (data) {
    remove_row(row_id);
  });
};

var sort_resources = function (element) {
  var link = element.find('a');
  var resource_name = get_resource_name(element);
  var url = resource_name + '.js?' + link.attr('href').replace(/.*\?/, '');
  jQuery.get(url, function (data) {
    replaceTable(data);
  });
}

var get_form_type = function (element) {
  // new_form => new; edit_form => edit
  return element.parents('.form_box').attr('class').replace(/form_box /, '').split('_')[0];
}

var ajaxifyResource = function (resources) {
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
    new_resource(element);
  });

  // edit
  editBtn.live('click', function (e) {
    e.preventDefault();
    var element = jQuery(this);
    edit_resource(element);
  });

  // cancel
  cancelBtn.live('click', function (e) {
    e.preventDefault();
    var element = jQuery(this);
    var form_type = get_form_type(element);

    if (form_type === "new") {
      close_form(element);
      enable_element(newBtn);
    } else if (form_type === "edit") {
      show_resource(element);
    } else if (form_type === "search") {
      close_form(element);
      enable_element(searchBtn);
    } else {
      throw "Unknown form type:" + form_type;
    }
  });

  // submit
  submitBtn.live('click', function (e) {
    e.preventDefault();
    var element = jQuery(this);
    var form_type = get_form_type(element);

    if (form_type === "new") {
      create_resource(element);
    } else if (form_type === "edit") {
      update_resource(element);
    } else if (form_type === "search") {
      search_resources(element);
    } else {
      throw "Unknown form type: " + form_type;
    }
  });

  // destroy
  destroyBtn.live('click', function (e) {
    e.preventDefault();
    var element = jQuery(this);
    if (confirm('Are you sure?')) {
      destroy_resource(element);
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

var get_row_id = function (element) {
  return element.parents('tr').attr('id');
};

var get_resource_name = function (element) {
  return element.parents('.resources').attr("data-resources");
};

var get_resource_id = function (element) {
  return Number(get_row_id(element).match(/\d+/)[0]);
};

var remove_row = function (row_id) {
  jQuery("#" + row_id).remove();
};

var admin_data_responses_index = {
  run: function () {
    // destroy
    jQuery(".destroy_btn").live('click', function (e) {
      e.preventDefault();
      var element = jQuery(this);
      if (confirm('Are you sure?')) {
        destroy_resource(element);
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

  //
  // Data Response summary charts
  //
  createPieChart("", "response_total_funding", "/charts/response_total_funding");

  //
  // project charts
  //

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

  jQuery.each(_projects, function (i, projectId) {
    createPieChart("MTEF Budget", "project_" + projectId + "_mtef_budget", "/charts/project_pie?codings_type=CodingBudget&code_type=Mtef&project_id=" + projectId);
    createPieChart("MTEF Expenditure", "project_" + projectId + "_mtef_spend", "/charts/project_pie?codings_type=CodingSpend&code_type=Mtef&project_id=" + projectId);
    createPieChart("NSP Budget", "project_" + projectId + "_nsp_budget", "/charts/project_pie?codings_type=CodingBudget&code_type=Nsp&project_id=" + projectId);
    createPieChart("NSP Expenditure", "project_" + projectId + "_nsp_spend", "/charts/project_pie?codings_type=CodingSpend&code_type=Nsp&project_id=" + projectId);
    createPieChart("HSSPII Strat Program Budget", "project_" + projectId + "_budget_stratprog_coding", "/charts/project_pie?codings_type=budget_stratprog_coding&code_type=Nsp&project_id=" + projectId);
    createPieChart("HSSPII Strat Objective Budget", "project_" + projectId + "_budget_stratobj_coding", "/charts/project_pie?codings_type=budget_stratobj_coding&code_type=Nsp&project_id=" + projectId);
    createPieChart("HSSPII Strategic Program Expenditure", "project_" + projectId + "_spend_stratprog_coding", "/charts/project_pie?codings_type=spend_stratprog_coding&code_type=Nsp&project_id=" + projectId);
    createPieChart("HSSPII Strategic Objective Expenditure", "project_" + projectId + "_spend_stratobj_coding", "/charts/project_pie?codings_type=spend_stratobj_coding&code_type=Nsp&project_id=" + projectId);
  });

};

var admin_data_responses_show = {
  run: function (){
    build_data_response_review_screen();
    ajaxifyResource('comments');
  }
};

var reporter_data_responses_show = {
  run: function (){
    build_data_response_review_screen();
    ajaxifyResource('comments');
  }
};

var policy_maker_data_responses_show = {
  run: function (){
    build_data_response_review_screen();
    ajaxifyResource('comments');
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
    jQuery("#notice").fadeOut(3000);

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
